let ws_handler_registry = {}

export const init_websocket = (path) => {
    let ws
    if (typeof WebSocket === "function") {
        // we're in the browser
        let url = new URL(document.URL)
        let protocol = url.protocol === "http:" ? "ws" : "wss"
        let ws_url = protocol + "://" + url.host + url.pathname + path
        ws = new WebSocket(ws_url)
    } else {
        // we're NOT in the browser, prolly running tests
        ws = {}
    }
    console.log("ws init", ws)
    ws.onopen = () => console.log("ws", ws.url, "opened")
    ws.onclose = () => {
        console.log("ws", ws.url, "closed");
        delete ws_handler_registry[ws.url]
    }
    ws.onmessage = event => ws_handler_registry[ws.url](event.data)
    ws.onerror = error => console.log("ws", ws.url, "error", error)
    return ws
}

export const register_websocket_handler = (ws, handler) => {
    ws_handler_registry[ws.url] = handler
    console.log("ws reg", ws_handler_registry)
}

export const send_over_websocket = (ws, msg) => {
    console.log("send", ws, msg)
    ws.send(msg)
}