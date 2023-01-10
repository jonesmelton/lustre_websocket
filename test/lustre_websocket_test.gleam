import gleeunit
import lustre_websocket as ws

pub fn main() {
  gleeunit.main()
}

pub type Wrapper {
  Wrapper(String)
}

pub fn compilation_test() {
  let socket = ws.init("/blah")
  ws.register(socket, Wrapper)

  // We cannot run the resulting lustre.Cmd, but we can at least ensure it can be used/compiled this way
  ws.send(socket, "hello")
}
