import 'dart:js_interop';
import 'package:web_dex/mm2/rpc.dart';
import 'package:web_dex/platform/platform.dart';

class RPCWeb extends RPC {
  const RPCWeb();

  @override
  Future<dynamic> call(String reqStr) async {
    final JSAny? response = await wasmRpc(reqStr).toDart;
    return response;
  }
}
