library wasmlib;

import 'dart:js_interop';

@JS('init_wasm')
external JSPromise initWasm();

@JS('run_mm2')
external JSPromise wasmRunMm2(
  String params,
  JSFunction handleLog,
);

@JS('mm2_status')
external JSAny? wasmMm2Status();

@JS('mm2_version')
external JSString wasmVersion();

@JS('rpc_request')
external JSPromise wasmRpc(String request);

@JS('reload_page')
external void reloadPage();

@JS('changeTheme')
external void changeHtmlTheme(int themeIndex);
