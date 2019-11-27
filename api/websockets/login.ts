import { HttpResponse, WebSocket } from 'uWebSockets.js';
import * as mysql from 'mysql2/promise';
import * as crypto from 'crypto';
const config = require("./config.json");

function hash(algorithm: string, data: string): string {
    return crypto.createHash(algorithm).update(data).digest("hex");
}

function time(): number {
    return new Date().getTime();
}

export async function login(ws: WebSocket, login: string, password: string) {
    let sql : mysql.Connection = null;
    try {
        sql = await mysql.createConnection({
            host: config.sql.host,
            user: config.sql.user,
            password: config.sql.password,
            database: config.sql.database
        });

        let hash_password = password
        if (config.hash == "md5") {
            hash_password = hash("md5", password);
        } else if (config.hash == "sha1") {
            hash_password = hash("sha1", password);
        }

        const [accounts, accountFields] = await sql.execute('SELECT * FROM `accounts` where `name` = ? and `password` = ?', [login, hash_password]);
        if (accounts.length != 1) {
            await sql.end();
            return ws.send(JSON.stringify({"type": "login", "error": "Invalid account/password"}), false);
        }
        const account = accounts[0];
        const [players, playersFields] = await sql.execute('SELECT * FROM `players` where `account_id` = ?', [account.id]);
        await sql.end(); 

        let response = {
            "type": "login",
            "error": "",
            "rsa": config.rsa,
            "version": config.version,
            "things": config.things,
            "customProtocol": config.customProtocol,
            "session": "",
            "characters": [],
            "account": {},
            "options": config.options,
            "features": config.features,
            "proxies": config.proxies
        }

        response["session"] = `${login}\n${password}\n\n${time()}`;

        response["account"]["status"] = 0; // 0=ok, 1=frozen, 2=supsended
        response["account"]["subStatus"] = 1; // 0=free, 1=premium
        response["account"]["premDays"] = 65535;

        for (let i = 0; i < players.length; ++i) {
            response.characters.push({
                "name": players[i].name,
                "worldName": config.serverName,
                "worldIp": config.serverIP,
                "worldPort": config.serverPort
            })
        }

        console.log(response);
        ws.send(JSON.stringify(response), false);
    } catch (e) {
        try {
            await sql.end()
        } catch (e) { };
        try {
            ws.end(5, "Login exception");
        } catch (e) { };
    }
}

export async function quickLogin(res : HttpResponse, ws: WebSocket, data: any) {

}