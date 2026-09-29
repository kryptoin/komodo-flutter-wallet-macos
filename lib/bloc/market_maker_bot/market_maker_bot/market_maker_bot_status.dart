/// Represents the status of the market maker bot.
enum MarketMakerBotStatus {
  /// The bot is starting: loading configuration and creating orders.
  starting,

  /// The bot is stopping: cancelling orders created by the bot.
  stopping,

  /// The bot is running: orders are created and being monitored and updated.
  running,

  /// The bot is stopped: no orders are created or monitored.
  stopped,
}
