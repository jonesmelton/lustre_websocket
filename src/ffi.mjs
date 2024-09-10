export const init_websocket = (url, on_open, on_text, on_binary, on_close) => {
  let ws
  if (typeof WebSocket === "function") {
  } else {
    // we're NOT in the browser, prolly running tests
    ws = {}
  }

  ws.onopen = (_) => on_open(ws)
  ws.onmessage = (event) => {
    if (typeof event.data === "string") {
      on_text(event.data)
    } else {
      on_binary(event.data)
    }
  }
  ws.onclose = (event) => on_close(event.code)
}

export const init_websocket_with_binary_type = (
  url,
  binary_type,
  on_open,
  on_text,
  on_binary,
  on_close
) => {
  let ws
  if (typeof WebSocket === "function") {
    ws = new WebSocket(url)
    ws.binaryType = "arraybuffer"
    console.log(binary_type)
  } else {
    // we're NOT in the browser, prolly running tests
    ws = {}
  }

  ws.onopen = (_) => on_open(ws)
  ws.onmessage = (event) => {
    if (typeof event.data === "string") {
      on_text(event.data)
    } else {
      console.log(binary_type.binary_type)
      let frame = new Uint8Array(event.data)
      on_binary(frame)
    }
  }
  ws.onclose = (event) => on_close(event.code)
}

export const send_over_websocket = (ws, msg) => ws.send(msg)

export const close = (ws) => ws.close()

export const get_page_url = () => document.URL
