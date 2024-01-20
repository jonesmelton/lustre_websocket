import gleeunit
import lustre_websocket as ws

pub fn main() {
  gleeunit.main()
}

pub type Wrapper {
  Wrapper(ws.WebSocketEvent)
}

pub fn rather_thin_compilation_test() {
  let _effect = ws.init("/blah", Wrapper)
  // We cannot run the resulting lustre.Effect, but we can at least ensure it can be used/compiled this way
}
