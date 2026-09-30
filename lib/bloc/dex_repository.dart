import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:rational/rational.dart';
import 'package:web_dex/app_config/app_config.dart';
import 'package:web_dex/mm2/mm2_api/mm2_api.dart';
import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/mm2/mm2_api/rpc/best_orders/best_orders.dart';
import 'package:web_dex/mm2/mm2_api/rpc/best_orders/best_orders_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_maker_vol/max_maker_vol_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_maker_vol/max_maker_vol_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_taker_vol/max_taker_vol_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/max_taker_vol/max_taker_vol_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/min_trading_vol/min_trading_vol.dart';
import 'package:web_dex/mm2/mm2_api/rpc/min_trading_vol/min_trading_vol_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_recent_swaps/my_recent_swaps_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_swap_status/my_swap_status_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/sell/sell_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/sell/sell_response.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trade_preimage/trade_preimage_errors.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trade_preimage/trade_preimage_request.dart';
import 'package:web_dex/mm2/mm2_api/rpc/trade_preimage/trade_preimage_response.dart';
import 'package:web_dex/model/data_from_service.dart';
import 'package:web_dex/model/swap.dart';
import 'package:web_dex/router/state/routing_state.dart';
import 'package:web_dex/model/main_menu_value.dart';
import 'package:web_dex/model/text_error.dart';
import 'package:web_dex/model/trade_preimage.dart';
import 'package:web_dex/services/mappers/trade_preimage_mappers.dart';
import 'package:web_dex/shared/utils/ttl_cache.dart';
import 'package:web_dex/shared/utils/utils.dart';

class DexRepository {
  DexRepository(this._mm2Api);

  final Mm2Api _mm2Api;

  // Short-lived caches that collapse the burst of identical RPCs fired by
  // the taker/maker/bridge/market-maker-bot forms, which all share this
  // repository and poll on their own timers (e.g. max volume every 10s).
  // Errors are never cached (see cacheIf below) so retries always hit the
  // network again.
  final TtlCache<String, BestOrders> _bestOrdersCache =
      TtlCache<String, BestOrders>(
        name: 'best_orders',
        defaultTtl: const Duration(seconds: 10),
      );
  final TtlCache<String, Rational?> _volumeCache = TtlCache<String, Rational?>(
    name: 'trading_volume',
    defaultTtl: const Duration(seconds: 15),
  );
  final TtlCache<String, DataFromService<TradePreimage, BaseError>>
  _preimageCache = TtlCache<String, DataFromService<TradePreimage, BaseError>>(
    name: 'trade_preimage',
    defaultTtl: const Duration(seconds: 5),
  );

  /// Drops every cached DEX value (best orders, volume limits, fee
  /// preimages). Called on logout / form reset so balance-derived values
  /// are never reused across sessions.
  void invalidateCaches() {
    _bestOrdersCache.clear();
    _volumeCache.clear();
    _preimageCache.clear();
  }

  /// Aggregate cache counters, for debugging/logging.
  String cacheStats() => [
    _bestOrdersCache,
    _volumeCache,
    _preimageCache,
  ].map((cache) => cache.statsString()).join('\n');

  Future<SellResponse> sell(SellRequest request) async {
    try {
      final Map<String, dynamic> response = await _mm2Api.sell(request);
      return SellResponse.fromJson(response);
    } catch (e) {
      return SellResponse(error: TextError.fromString(e.toString()));
    }
  }

  Future<DataFromService<TradePreimage, BaseError>> getTradePreimage(
    String base,
    String rel,
    Rational price,
    String swapMethod, [
    Rational? volume,
    bool max = false,
  ]) {
    // Every input that can change the fee estimate is part of the key, so
    // a retry after editing the amount always reaches the network while
    // identical requests (burst validation, 20s bridge fee timer, ...) are
    // served once per TTL.
    final String cacheKey =
        'preimage|$base|$rel|$price|$swapMethod|${volume ?? ''}|$max';
    return _preimageCache.get(
      cacheKey,
      () => _fetchTradePreimage(base, rel, price, swapMethod, volume, max),
      cacheIf: (result) => result.error == null,
    );
  }

  Future<DataFromService<TradePreimage, BaseError>> _fetchTradePreimage(
    String base,
    String rel,
    Rational price,
    String swapMethod,
    Rational? volume,
    bool max,
  ) async {
    final request = TradePreimageRequest(
      base: base,
      rel: rel,
      price: price,
      volume: volume,
      swapMethod: swapMethod,
      max: max,
    );
    final ApiResponse<
      TradePreimageRequest,
      TradePreimageResponseResult,
      Map<String, dynamic>
    >
    response = await _mm2Api.getTradePreimage(request);

    final Map<String, dynamic>? error = response.error;
    final TradePreimageResponseResult? result = response.result;
    if (error != null) {
      return DataFromService(
        error: tradePreimageErrorFactory.getError(error, response.request),
      );
    }
    if (result == null) {
      return DataFromService(error: TextError(error: 'Something wrong'));
    }
    try {
      return DataFromService(
        data: mapTradePreimageResponseResultToTradePreimage(
          result,
          response.request,
        ),
      );
    } catch (e, s) {
      log(
        e.toString(),
        path:
            'swaps_service => getTradePreimage => mapTradePreimageResponseToTradePreimage',
        trace: s,
        isError: true,
      );
      return DataFromService(error: TextError(error: 'Something wrong'));
    }
  }

  Future<Rational?> getMaxTakerVolume(String coinAbbr) {
    return _volumeCache.get('max_taker_vol|$coinAbbr', () async {
      final MaxTakerVolResponse? response = await _mm2Api.getMaxTakerVolume(
        MaxTakerVolRequest(coin: coinAbbr),
      );
      if (response == null) {
        return null;
      }
      return fract2rat(response.result.toJson());
    });
  }

  Future<Rational?> getMaxMakerVolume(String coinAbbr) {
    return _volumeCache.get('max_maker_vol|$coinAbbr', () async {
      final MaxMakerVolResponse? response = await _mm2Api.getMaxMakerVolume(
        MaxMakerVolRequest(coin: coinAbbr),
      );
      if (response == null) {
        return null;
      }
      return fract2rat(response.volume.toFractionalJson());
    });
  }

  Future<Rational?> getMinTradingVolume(String coinAbbr) {
    // The minimum trade volume is node configuration and effectively
    // static, so it can be shared for much longer than the balance-derived
    // max volumes above.
    return _volumeCache.get('min_trading_vol|$coinAbbr', () async {
      final MinTradingVolResponse? response = await _mm2Api.getMinTradingVol(
        MinTradingVolRequest(coin: coinAbbr),
      );
      if (response == null) {
        return null;
      }
      return fract2rat(response.result.toJson());
    }, ttl: const Duration(seconds: 60));
  }

  Future<List<Swap>?> getRecentSwaps(MyRecentSwapsRequest request) async {
    return null;
  }

  Future<BestOrders> getBestOrders(
    BestOrdersRequest request, {
    bool skipCache = false,
  }) async {
    // Only allow best_orders when user is on Swap (DEX) or Bridge pages
    final MainMenuValue current = routingState.selectedMenu;
    final bool isTradingPage =
        current == MainMenuValue.dex || current == MainMenuValue.bridge;
    if (!isTradingPage) {
      // Not an error – we intentionally suppress best_orders away from trading pages
      return BestOrders(result: <String, List<BestOrder>>{});
    }

    // Testing aid: opt-in random failure in debug mode
    if (kDebugMode &&
        kSimulateBestOrdersFailure &&
        Random().nextDouble() < kSimulatedBestOrdersFailureRate) {
      return BestOrders(
        error: TextError(error: 'Simulated best_orders failure (debug)'),
      );
    }

    if (skipCache) return _fetchBestOrders(request);

    final String cacheKey =
        'best_orders|${request.coin}|${request.action}|${request.type.name}|'
        '${request.volume ?? request.number}';
    return _bestOrdersCache.get(
      cacheKey,
      () => _fetchBestOrders(request),
      cacheIf: (orders) => orders.error == null,
    );
  }

  Future<BestOrders> _fetchBestOrders(BestOrdersRequest request) async {
    Map<String, dynamic>? response;
    try {
      response = await _mm2Api.getBestOrders(request);
    } catch (e, s) {
      log(
        'best_orders request failed: $e',
        trace: s,
        path: 'api => getBestOrders',
        isError: true,
      ).ignore();
      return BestOrders(error: TextError.fromString(e.toString()));
    }

    if (response == null) {
      return BestOrders(
        error: TextError(error: 'best_orders returned null response'),
      );
    }

    final String? errorText = response['error'] as String?;
    if (errorText != null && errorText.isNotEmpty) {
      // Map known "no orders" network condition to empty result so UI shows a
      // graceful "Nothing found" instead of an error panel.
      final String? errorType = response['error_type'] as String?;
      final String? errorPath = response['error_path'] as String?;
      final bool isNoOrdersNetworkCondition =
          errorPath == 'best_orders' &&
          errorType == 'P2PError' &&
          errorText.contains('No response from any peer');

      // Mm2Api.getBestOrders may wrap MM2 errors in an Exception() during
      // retry handling, yielding text like: "Exception: No response from any peer"
      // (without error_type/error_path). Treat these as "no orders" as well.
      final bool isWrappedNoOrdersText = errorText.toLowerCase().contains(
        'no response from any peer',
      );

      if (isNoOrdersNetworkCondition || isWrappedNoOrdersText) {
        return BestOrders(result: <String, List<BestOrder>>{});
      }

      log(
        'best_orders returned error: $errorText',
        path: 'api => getBestOrders',
        isError: true,
      ).ignore();
      return BestOrders(error: TextError(error: errorText));
    }

    final Map<String, dynamic>? result =
        response['result'] as Map<String, dynamic>?;
    if (result == null || result.isEmpty) {
      // No error and no result → no liquidity available
      return BestOrders(result: <String, List<BestOrder>>{});
    }

    try {
      return BestOrders.fromJson(response);
    } catch (e, s) {
      log('Error parsing best_orders response: $e', trace: s, isError: true);

      return BestOrders(
        error: TextError(
          error: 'Something went wrong! Unexpected response format.',
        ),
      );
    }
  }

  Future<Swap> getSwapStatus(String swapUuid) async {
    final response = await _mm2Api.getSwapStatus(
      MySwapStatusReq(uuid: swapUuid),
    );

    if (response['error'] != null) {
      throw TextError(error: response['error']);
    }

    return Swap.fromJson(response['result']);
  }

  Future<void> waitOrderbookAvailability({
    int retries = 10,
    int interval = 300,
  }) async {
    BestOrders orders;

    for (int attempt = 0; attempt < retries; attempt++) {
      orders = await getBestOrders(
        BestOrdersRequest(
          coin: defaultDexCoin,
          type: BestOrdersRequestType.number,
          number: 1,
          action: 'sell',
        ),
        // Fresh liquidity is exactly what we are waiting for, so bypass
        // the cache on every retry.
        skipCache: true,
      );

      if (orders.result?.isNotEmpty ?? false) {
        return;
      }

      await Future.delayed(Duration(milliseconds: interval));
    }
  }
}
