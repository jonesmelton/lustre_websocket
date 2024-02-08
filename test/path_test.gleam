import lustre_websocket.{do_get_websocket_path}
import gleam/uri
import gleeunit/should

// Needs a test for InvalidUrl, but uri.parse is too forgiving

pub fn relative_no_path_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/")
  do_get_websocket_path("hello", page_uri)
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn relative_on_file_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/path/index.html")
  do_get_websocket_path("hello", page_uri)
  |> should.equal(Ok("ws://example.org/path/hello"))
}

pub fn relative_on_dir_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/path/")
  do_get_websocket_path("hello", page_uri)
  |> should.equal(Ok("ws://example.org/path/hello"))
}

pub fn absolute_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/")
  do_get_websocket_path("/hello", page_uri)
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn absolute_on_file_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/path/index.html")
  do_get_websocket_path("/hello", page_uri)
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn absolute_on_dir_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/path")
  do_get_websocket_path("/hello", page_uri)
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn https_wss_test() {
  let assert Ok(page_uri) = uri.parse("https://example.org/path")
  do_get_websocket_path("/hello", page_uri)
  |> should.equal(Ok("wss://example.org/hello"))
}

pub fn full_ws_test() {
  let assert Ok(page_uri) = uri.parse("https://example.org/path")
  do_get_websocket_path("ws://example.com/hello", page_uri)
  |> should.equal(Ok("ws://example.com/hello"))
}

pub fn full_wss_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/path")
  do_get_websocket_path("wss://example.com/hello", page_uri)
  |> should.equal(Ok("wss://example.com/hello"))
}

pub fn omit_query_from_doc_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/path?a=b")
  do_get_websocket_path("hello", page_uri)
  |> should.equal(Ok("ws://example.org/hello"))
}

pub fn omit_fragment_from_doc_test() {
  let assert Ok(page_uri) = uri.parse("http://example.org/path#top")
  do_get_websocket_path("ws://example.com/hello", page_uri)
  |> should.equal(Ok("ws://example.com/hello"))
}

pub fn omit_user_from_doc_test() {
  let assert Ok(page_uri) = uri.parse("http://user@example.org/path")
  do_get_websocket_path("/hello", page_uri)
  |> should.equal(Ok("ws://example.org/hello"))
}
