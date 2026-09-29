enum TrezorConnectionStatus {
  connected,
  unreachable,
  unknown;

  factory TrezorConnectionStatus.fromString(String status) {
    if (status == 'Connected') return TrezorConnectionStatus.connected;
    if (status == 'Unreachable') return TrezorConnectionStatus.unreachable;

    return TrezorConnectionStatus.unknown;
  }
}
