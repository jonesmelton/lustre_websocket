import lustre/cmd.{Cmd}

pub external type WebSocket

/// Initialize a websocket. These constructs are asynchronous, you must call
/// `register(ws, wrapper)` to receive messages.
pub fn init(path) -> WebSocket {
  do_init(path)
}

external fn do_init(path) -> WebSocket =
  "./ffi.mjs" "init_websocket"

/// Register a dispatcher via the `lustre/cmd` infrastructure, so any
/// message that arrives asynchronously can be passed to the `update`
/// function of your lustre application.
pub fn register(ws: WebSocket, wrapper: fn(String) -> a) -> Cmd(a) {
  let fun = fn(dispatch) {
    let on_message = fn(in_msg) { dispatch(wrapper(in_msg)) }
    do_register(ws, on_message)
  }
  cmd.from(fun)
}

external fn do_register(ws, fun) -> Nil =
  "./ffi.mjs" "register_websocket_handler"

/// Send a message over the web socket. This is asynchronous. There is no
/// expectation of a reply. See `init` and `register`
pub fn send(ws: WebSocket, msg: String) {
  cmd.from(fn(_) { do_send(ws, msg) })
}

external fn do_send(ws: WebSocket, msg: String) -> Nil =
  "./ffi.mjs" "send_over_websocket"
