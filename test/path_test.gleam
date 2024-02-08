import lustre_websocket.{do_get_websocket_path}
import gleam/uri
import gleeunit/should

// Needs a test with a broken path, but uri.parse is too forgiving

pub fn relative_no_path_test() {
  do_get_websocket_path("hello", uri.parse("http://example.org/"))
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn relative_on_file_test() {
  do_get_websocket_path("hello", uri.parse("http://example.org/path/index.html"))
  |> should.equal(Ok("ws://example.org/path/hello"))
}

pub fn relative_on_dir_test() {
  do_get_websocket_path("hello", uri.parse("http://example.org/path/"))
  |> should.equal(Ok("ws://example.org/path/hello"))
}

pub fn absolute_test() {
  do_get_websocket_path("/hello", uri.parse("http://example.org/"))
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn absolute_on_file_test() {
  do_get_websocket_path("/hello", uri.parse("http://example.org/path/index.html"))
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn absolute_on_dir_test() {
  do_get_websocket_path("/hello", uri.parse("http://example.org/path"))
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn https_wss_test() {
  do_get_websocket_path("/hello", uri.parse("https://example.org/path"))
  |> should.equal(Ok("wss://example.org/hello"))
}

pub fn full_ws_test() {
  do_get_websocket_path("ws://example.com/hello", uri.parse("https://example.org/path"))
  |> should.equal(Ok("ws://example.com/hello"))
}

pub fn full_wss_test() {
  do_get_websocket_path("wss://example.com/hello", uri.parse("http://example.org/path"))
  |> should.equal(Ok("wss://example.com/hello"))
}
