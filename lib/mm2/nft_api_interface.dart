import 'package:web_dex/mm2/rpc/nft_transaction/nft_transactions_request.dart';
import 'package:web_dex/mm2/rpc/nft_transaction/nft_transactions_response.dart';

abstract class NftApi {
  Future<NftTxsResponse> getNftTransactions(NftTransactionsRequest request);
}
