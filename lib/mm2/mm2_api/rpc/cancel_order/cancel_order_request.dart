class CancelOrderRequest {
  CancelOrderRequest({
    this.method = 'cancel_order',
    this.userpass,
    required this.uuid,
  });

  final String method;
  String? userpass;
  final String uuid;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'uuid': uuid,
    };
  }
}
