import 'package:web_dex/bloc/cex_market_data/portfolio_growth/portfolio_growth_repository.dart';
import 'package:web_dex/bloc/cex_market_data/profit_loss/profit_loss_repository.dart';

class CexMarketData {
  static Future<void> ensureInitialized() async {
    await ProfitLossRepository.ensureInitialized();
    await PortfolioGrowthRepository.ensureInitialized();
  }
}
