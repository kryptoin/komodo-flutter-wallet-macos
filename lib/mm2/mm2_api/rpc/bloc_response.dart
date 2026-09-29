// @deprecated
class BlocResponse<R, E> {
  BlocResponse({this.result, this.error});
  R? result;
  E? error;
}
