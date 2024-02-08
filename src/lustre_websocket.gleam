import lustre/effect.{type Effect}
import gleam/option.{Some}
import gleam/result
import gleam/uri.{type Uri, Uri}

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
  InvalidUrl
  OnOpen(WebSocket)
  OnMessage(String)
  OnClose(WebSocketCloseReason)
}

/// Initialize a websocket. These constructs are fully asynchronous, so you must provide a wrapper
/// that takes a `WebSocketEvent` and turns it into a lustre message of your application.
pub fn init(path: String, wrapper: fn(WebSocketEvent) -> a) -> Effect(a) {
  let fun = fn(dispatch) {
    case get_websocket_path(path) {
      Ok(path) -> {
        let ws = do_init(path)
        let on_open = fn() { dispatch(wrapper(OnOpen(ws))) }
        let on_message = fn(in_msg) { dispatch(wrapper(OnMessage(in_msg))) }
        let on_close = fn(code) {
          case code {
            1000 -> Normal
            1001 -> GoingAway
            1002 -> ProtocolError
            1003 -> UnexpectedTypeOfData
            1005 -> NoCodeFromServer
            1006 -> AbnormalClose
            1007 -> IncomprehensibleFrame
            1008 -> PolicyViolated
            1009 -> MessageTooBig
            1010 -> FailedExtensionNegotation
            1011 -> UnexpectedFailure
            1015 -> FailedTLSHandshake
            _ -> OtherCloseReason
          }
          |> OnClose
          |> wrapper
          |> dispatch
        }
        do_register(ws, on_open, on_message, on_close)
      }
      _ ->
        InvalidUrl
        |> wrapper
        |> dispatch
    }
  }
  effect.from(fun)
}

pub fn get_websocket_path(path: String) -> Result(String, Nil) {
  case path {
    "/" <> _ -> {
      let page_url = do_get_page_url()
      use uri <- result.try(uri.parse(page_url))
      use scheme <- result.try(option.to_result(uri.scheme, Nil))
      use scheme <- result.try(convert_scheme(scheme))
      use hostname <- result.try(option.to_result(uri.host, Nil))

      Ok(scheme <> "://" <> hostname <> path)
    }
    _ -> {
      use uri <- result.try(uri.parse(path))
      use scheme <- result.try(option.to_result(uri.scheme, Nil))
      use scheme <- result.try(convert_scheme(scheme))

      Uri(..uri, scheme: Some(scheme))
      |> uri.to_string()
      |> Ok
    }
  }
}

fn convert_scheme(scheme: String) -> Result(String, Nil) {
  case scheme {
    "https" -> Ok("wss")
    "http" -> Ok("ws")
    "ws" | "wss" -> Ok(scheme)
    _ -> Error(Nil)
  }
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

@external(javascript, "./ffi.mjs", "close")
pub fn close(ws ws: WebSocket) -> Effect(a)

@external(javascript, "./ffi.mjs", "get_page_url")
pub fn do_get_page_url() -> String
