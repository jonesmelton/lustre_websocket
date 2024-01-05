import lustre/effect.{type Effect}

pub type WebSocket

pub type WebSocketCloseReason {
  // 1000
  Normal
  // 1001
  GoingAway
  // 1002
  ProtocolError
  // 1003
  UnexpectedTypeOfData
  // 1004 Reserved
  // 1005
  NoCodeFromServer
  // 1006, no close frame
  AbnormalClose
  // 1007
  IncomprehensibleFrame
  // 1008
  PolicyViolated
  // 1009
  MessageTooBig
  // 1010
  FailedExtensionNegotation
  // 1011
  UnexpectedFailure
  // 1015
  FailedTLSHandshake
  // unlisted
  OtherCloseReason
}

pub type WebSocketEvent {
  OnOpen(WebSocket)
  OnMessage(String)
  OnClose(WebSocketCloseReason)
}

/// Initialize a websocket. These constructs are fully asynchronous, so you must provide a wrapper
/// that takes a `WebSocketEvent` and turns it into a lustre message of your application.
pub fn init(path: String, wrapper: fn(WebSocketEvent) -> a) -> Effect(a) {
  let ws = do_init(path)
  let fun = fn(dispatch) {
    let on_open = fn() { dispatch(wrapper(OnOpen(ws))) }
    let on_message = fn(in_msg) { dispatch(wrapper(OnMessage(in_msg))) }
    let on_close = fn(code) {
      case code {
        1000 -> dispatch(wrapper(OnClose(Normal)))
        1001 -> dispatch(wrapper(OnClose(GoingAway)))
        1002 -> dispatch(wrapper(OnClose(ProtocolError)))
        1003 -> dispatch(wrapper(OnClose(UnexpectedTypeOfData)))
        1005 -> dispatch(wrapper(OnClose(NoCodeFromServer)))
        1006 -> dispatch(wrapper(OnClose(AbnormalClose)))
        1007 -> dispatch(wrapper(OnClose(IncomprehensibleFrame)))
        1008 -> dispatch(wrapper(OnClose(PolicyViolated)))
        1009 -> dispatch(wrapper(OnClose(MessageTooBig)))
        1010 -> dispatch(wrapper(OnClose(FailedExtensionNegotation)))
        1011 -> dispatch(wrapper(OnClose(UnexpectedFailure)))
        1015 -> dispatch(wrapper(OnClose(FailedTLSHandshake)))
        _ -> dispatch(wrapper(OnClose(OtherCloseReason)))
      }
    }
    do_register(ws, on_open, on_message, on_close)
  }
  effect.from(fun)
}

@external(javascript, "./ffi.mjs", "init_websocket")
fn do_init(a: path) -> WebSocket

@external(javascript, "./ffi.mjs", "register_websocket_handler")
fn do_register(
  ws ws: WebSocket,
  on_open on_open: fn() -> Nil,
  on_message on_message: fn(String) -> Nil,
  on_close on_close: fn(Int) -> Nil,
) -> Nil

/// Send a text message over the web socket. This is asynchronous. There is no
/// expectation of a reply. See `init`. Only works on an Non-Closed socket.
/// Returns a `Effect(a)` that you must pass as second entry in the lustre `update` return.
pub fn send(ws: WebSocket, msg: String) -> Effect(a) {
  effect.from(fn(_) { do_send(ws, msg) })
}

@external(javascript, "./ffi.mjs", "send_over_websocket")
fn do_send(ws ws: WebSocket, msg msg: String) -> Nil
