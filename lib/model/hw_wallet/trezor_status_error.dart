class TrezorStatusError {
  TrezorStatusError({
    required this.error,
    required this.errorType,
    required this.errorData,
  });

  factory TrezorStatusError.fromJson(Map<String, dynamic> json) {
    return TrezorStatusError(
      error: json['error'],
      errorType: TrezorStatusErrorType.fromJson(json['error_type']),
      errorData: TrezorStatusErrorData.fromJson(json['error_data']),
    );
  }

  final String error;
  final TrezorStatusErrorType errorType;
  final TrezorStatusErrorData errorData;
}

enum TrezorStatusErrorData {
  noTrezorDeviceAvailable,
  foundMultipleDevices,
  foundUnexpectedDevice,
  invalidPin,
  unknown;

  static TrezorStatusErrorData fromJson(dynamic json) {
    switch (json) {
      case 'NoTrezorDeviceAvailable':
        return TrezorStatusErrorData.noTrezorDeviceAvailable;
      case 'FoundMultipleDevices':
        return TrezorStatusErrorData.foundMultipleDevices;
      case 'FoundUnexpectedDevice':
        return TrezorStatusErrorData.foundUnexpectedDevice;
      case 'InvalidPin':
        return TrezorStatusErrorData.invalidPin;
      default:
        return TrezorStatusErrorData.unknown;
    }
  }
}

enum TrezorStatusErrorType {
  hwError,
  hwContextInitializingAlready,
  internal,
  unknown;

  static TrezorStatusErrorType fromJson(String? json) {
    switch (json) {
      case 'HwError':
        return TrezorStatusErrorType.hwError;
      case 'HwContextInitializingAlready':
        return TrezorStatusErrorType.hwContextInitializingAlready;
      case 'Internal':
        return TrezorStatusErrorType.internal;
      default:
        return TrezorStatusErrorType.unknown;
    }
  }
}
