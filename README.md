# lustre_websocket

[![Package Version](https://img.shields.io/hexpm/v/lustre_websocket)](https://hex.pm/packages/lustre_websocket)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lustre_websocket/)

Use websockets from your `lustre` application!

## Quick start

Add to your Gleam project:

```sh
gleam add lustre_websocket
```

Typical usage looks like
```
import lustre_websocket as ws

pub type Msg {
  MsgReceived(String)
}

let socket = ws.init("/path")
let init = #(model.init(socket), ws.register(socket, MsgReceived))
```
and then you pass `init` as first argument to `lustre.application`.
But you can create and register a socket at any time.

### Caveat

*This package cannot handle more than 1 socket on a server endpoint*

### TODO:
 * support protocol choice, including one websocket per protocol per endpoint
 * re-open the websocket when it is closed
 * allow client to close the socket
 * provide more information (open/error) to the application?