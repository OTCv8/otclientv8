## OTClientV8 Websockets

From version 1.4 OTClientV8 supports websockets and secure websockets. They can be also used in bot.

### Usage
```
local url = "ws://otclient.ovh/"
local websocket = HTTP.WebSocket(url, {
    onOpen = function(message, websocketId)
    
    end,
    onMessage = function(message, websocketId)
    
    end,
    onClose = function(message, websocketId)
    
    end,
    onError = function(message, websocketId)
    
    end
})
-- it returns
print(websocket.id)
print(websocket.url)
websocket.send("Hello")
scheduleEvent(function()
    websocket.close()
end, 5000)
```

If your websocket is only using json then you can use HTTP.WebSocketJSON
```
local url = "wss://otclient.ovh:3000/"
local websocket = HTTP.WebSocketJSON(url, {
    onOpen = function(message, websocketId)
    
    end,
    onMessage = function(message, websocketId)
        -- message is table, after json.decode
    end,
    onClose = function(message, websocketId)
    
    end,
    onError = function(message, websocketId)
        -- will also return json errors
    end
})
-- it returns
print(websocket.id)
print(websocket.url)
websocket.send({message="Hello"})
scheduleEvent(function()
    websocket.close()
end, 5000)
```

A working example with reconnect can be found in `client_entergame/entergame.lua`

### Websockets have 15s timeout by default, you can change it in `corelib/http.lua`

### WebSocket server
Creating websocket server is easy, here are some links:
https://github.com/websockets/ws
https://medium.com/@martin.sikora/node-js-websocket-simple-chat-tutorial-2def3a841b61
https://medium.com/hackernoon/implementing-a-websocket-server-with-node-js-d9b78ec5ffa8

Personally, I use:
https://github.com/uNetworking/uWebSockets
https://github.com/uNetworking/uWebSockets.js

### Example server in nodejs
You need to install nodejs and then `npm install uNetworking/uWebSockets.js#v16.4.0`
Name it server.js and run it by using command: `nodejs server.js`

```
require('uWebSockets.js').App().ws('/*', {
  message: (ws, message, isBinary) => {
    console.log("message");
    let ok = ws.send(message, isBinary);
  }  
}).any('/*', (res, req) => {
  /* Let's deny all Http */
  res.end('Nothing to see here!');  
}).listen(9000, (listenSocket) => {
  if (listenSocket) {
    console.log('Listening to port 9000');
  }
});
```

More examples: https://github.com/uNetworking/uWebSockets.js/tree/master/examples