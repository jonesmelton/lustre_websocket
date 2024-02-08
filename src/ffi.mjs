export const init_websocket = (url, on_open, on_message, on_close) => {
    let ws
    if (typeof WebSocket === "function") {
        ws = new WebSocket(url)
    } else {
        // we're NOT in the browser, prolly running tests
        ws = {}
    }

    ws.onopen = _ => on_open(ws)
    ws.onmessage = event => on_message(event.data)
    ws.onclose = event => on_close(event.code)

    return ws
}

export const send_over_websocket = (ws, msg) => ws.send(msg)

export const close = ws => ws.close()

export const get_page_url = () => document.URL;
