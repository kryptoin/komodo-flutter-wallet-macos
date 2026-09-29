enum CoinItemSize {
  small,
  medium,
  large;

  double get segwitIconSize {
    switch (this) {
      case CoinItemSize.small:
        return 14;
      case CoinItemSize.medium:
        return 15;
      case CoinItemSize.large:
        return 16;
    }
  }

  double get subtitleFontSize {
    switch (this) {
      case CoinItemSize.small:
        return 10;
      case CoinItemSize.medium:
        return 11;
      case CoinItemSize.large:
        return 12;
    }
  }

  double get titleFontSize {
    switch (this) {
      case CoinItemSize.small:
        return 11;
      case CoinItemSize.medium:
        return 13;
      case CoinItemSize.large:
        return 14;
    }
  }

  double get coinLogo {
    switch (this) {
      case CoinItemSize.small:
        return 26;
      case CoinItemSize.medium:
        return 30;
      case CoinItemSize.large:
        return 34;
    }
  }

  double get spacer {
    switch (this) {
      case CoinItemSize.small:
        return 3;
      case CoinItemSize.medium:
        return 3;
      case CoinItemSize.large:
        return 4;
    }
  }
}
