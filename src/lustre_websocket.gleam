import lustre/effect.{type Effect}
import gleam/option.{None, Some}
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

fn code_to_reason(code: Int) -> WebSocketCloseReason {
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
}

pub type WebSocketEvent {
  InvalidUrl
  OnOpen(WebSocket)
  OnMessage(String)
  OnClose(WebSocketCloseReason)
}

/// Initialize a websocket. These constructs are fully asynchronous, so you must provide a wrapper
/// that takes a `WebSocketEvent` and turns it into a lustre message of your application.
/// If the path given is a URL, that is used.
/// If the path is an absolute path, host and port are taken from
/// document.URL, and scheme will become ws for http and wss for https.
/// If the path is a relative path, ditto, but the the path will be
/// relative to the path from document.URL
pub fn init(path: String, wrapper: fn(WebSocketEvent) -> a) -> Effect(a) {
  fn(dispatch) {
    case get_websocket_path(path) {
      Ok(url) ->
        do_init(
          url,
          fn(ws) { dispatch(wrapper(OnOpen(ws))) },
          fn(in_msg) { dispatch(wrapper(OnMessage(in_msg))) },
          fn(code) {
            code
            |> code_to_reason
            |> OnClose
            |> wrapper
            |> dispatch
          },
        )
      _ ->
        InvalidUrl
        |> wrapper
        |> dispatch
    }
  }
  |> effect.from
}

pub fn get_websocket_path(path) -> Result(String, Nil) {
  page_uri()
  |> result.try(do_get_websocket_path(path, _))
}

pub fn do_get_websocket_path(path: String, page_uri: Uri) -> Result(String, Nil) {
  let path_uri =
    uri.parse(path)
    |> result.unwrap(Uri(
      scheme: None,
      userinfo: None,
      host: None,
      port: None,
      path: path,
      query: None,
      fragment: None,
    ))
  use merged <- result.try(uri.merge(page_uri, path_uri))
  use merged_scheme <- result.try(option.to_result(merged.scheme, Nil))
  use ws_scheme <- result.try(convert_scheme(merged_scheme))
  Uri(..merged, scheme: Some(ws_scheme))
  |> uri.to_string
  |> Ok
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
fn do_init(
  a: path,
  on_open on_open: fn(WebSocket) -> Nil,
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
