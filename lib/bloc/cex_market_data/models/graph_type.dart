/// Enum for the different types of graphs that can be displayed in
/// the portfolio growth screen.
enum GraphType {
  /// The profit/loss graph for an individual coin/asset.
  profitLoss,

  /// The balance growth graph for an individual coin/asset.
  balanceGrowth,

  /// The profit/loss graph for the entire portfolio.
  portfolioProfitLoss,

  /// The balance growth graph for the entire portfolio.
  portfolioGrowth;

  static GraphType fromName(String key) {
    switch (key) {
      case 'profitLossGraph':
        return GraphType.profitLoss;
      case 'balanceGrowthGraph':
        return GraphType.balanceGrowth;
      case 'portfolioProfitLossGraph':
        return GraphType.portfolioProfitLoss;
      case 'portfolioGrowthGraph':
        return GraphType.portfolioGrowth;
      default:
        throw ArgumentError('Invalid key: $key');
    }
  }

  String get title {
    switch (this) {
      case GraphType.profitLoss:
        return 'Profit/Loss';
      case GraphType.balanceGrowth:
        return 'Balance Growth';
      case GraphType.portfolioProfitLoss:
        return 'Portfolio Profit/Loss';
      case GraphType.portfolioGrowth:
        return 'Portfolio Growth';
    }
  }

  String get name {
    switch (this) {
      case GraphType.profitLoss:
        return 'profitLossGraph';
      case GraphType.balanceGrowth:
        return 'balanceGrowthGraph';
      case GraphType.portfolioProfitLoss:
        return 'portfolioProfitLossGraph';
      case GraphType.portfolioGrowth:
        return 'portfolioGrowthGraph';
    }
  }

  String get tableName {
    switch (this) {
      case GraphType.profitLoss:
        return 'profit_loss';
      case GraphType.balanceGrowth:
        return 'balance_growth';
      case GraphType.portfolioProfitLoss:
        return 'portfolio_profit_loss';
      case GraphType.portfolioGrowth:
        return 'portfolio_growth';
    }
  }
}
