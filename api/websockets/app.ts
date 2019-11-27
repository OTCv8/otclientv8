import { App } from 'uWebSockets.js';
import * as Login from './login';
const config = require("./config.json");

let Sessions = new Set();
let Clients = {};
let QuickLogin = {};

App({
    // options for ssl
    key_file_name: 'key.pem',
    cert_file_name: 'cert.pem'
}).ws('/*', {
    compression: 0,
    maxPayloadLength: 64 * 1024,
    idleTimeout: 10,
    open: (ws, req) => {
        ws.uid = null;
        Sessions.add(ws);        
    },
    close: (ws, code, message) => {
        if (ws.uid && Clients[ws.uid] == ws) {
            delete Clients[ws.uid];
            delete QuickLogin[ws.short_code];
            delete QuickLogin[ws.full_code];
        }
        Sessions.delete(ws);
    },
    message: (ws, message, isBinary) => {
        try {
            let data = JSON.parse(String.fromCharCode.apply(null, new Uint8Array(message)));
            if (data["type"] == "init") {
                if (ws.uid || typeof (data["uid"]) != "string" || data["uid"].length < 10) {
                    return ws.end(1, "Invalid init message"); // already has an uid or uid is invalid
                }
                ws.uid = data["uid"];
                ws.version = data["version"]
                if (Clients[ws.uid]) {
                    Clients[ws.uid].close();
                }
                ws.short_code = "XXXX";
                ws.full_code = "Login on server otclient.ovh. XXXX";
                Clients[ws.uid] = ws;
                QuickLogin[ws.short_code] = ws;
                QuickLogin[ws.full_code] = ws;
                return ws.send(JSON.stringify({
                    "type": "quick_login",
                    "code": ws.short_code,
                    "qrcode": ws.full_code,
                    "message": ""
                }));
            }
            if (!ws.uid) {
                return ws.end(2, "Missing uid");
            }
            if (data["type"] == "login") {
                return Login.login(ws, data["account"], data["password"]);
            }
        } catch (e) {
            try {
                return ws.end(3, "Exception");
            } catch (e) {}
        }
    }
}).any('/login', (res, req) => {
    let buffer: string = "";
    res.onData((chunk, last) => {
        try {
            buffer += String.fromCharCode.apply(null, new Uint8Array(chunk));
            if (!last) {
                return;
            }
            const data = JSON.parse(buffer);
            const code = data["code"];
            const client = QuickLogin[code];
            if (!client) {
                return res.end("Invalid code");
            }
            Login.quickLogin(res, client, data);
        } catch (e) {
            res.end("Exception");
        }
    });

    res.onAborted(() => {
        return res.end("Aborted");
    });
}).any('/*', (res, req) => {
    res.end('404');
}).listen(config.port, (listenSocket) => {
    if (listenSocket) {
        console.log(`Listening to port ${config.port}`);
    } else {
        console.log(`Error, can't listen on port ${config.port}`)
    }
});