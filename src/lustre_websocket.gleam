import lustre/effect.{type Effect}
import gleam/option.{type Option, Some, None}
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

pub fn get_websocket_path(path) -> Result(String, Nil) {
  do_get_websocket_path(path, page_uri())
}

pub fn do_get_websocket_path(path: String, page_uri: Result(Uri, Nil)) -> Result(String, Nil) {
  case uri.parse(path), page_uri {
    Ok(path_uri), Ok(page_uri) -> {
      use merged <- result.try(uri.merge(page_uri, path_uri))
      let assert Some(merged_scheme) = merged.scheme
      Uri(..merged, scheme: convert_scheme(merged_scheme))
      |> uri.to_string
      |> Ok
    }
    _, _ -> Error(Nil)
  }
}

fn convert_scheme(scheme: String) -> Option(String) {
  case scheme {
    "https" -> Some("wss")
    "http" -> Some("ws")
    "ws" | "wss" -> Some(scheme)
    _ -> None
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

pub fn page_uri() -> Result(Uri, Nil) {
  do_get_page_url()
  |> uri.parse
}

@external(javascript, "./ffi.mjs", "get_page_url")
pub fn do_get_page_url() -> String
