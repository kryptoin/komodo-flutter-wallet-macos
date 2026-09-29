abstract class RPC {
  const RPC();
  Future<dynamic> call(String reqStr);
}
