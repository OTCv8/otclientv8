# OTClientV8

OTClientV8 is highly optimized tile based 2d game engine built with c++, lua, physfs, OpenGL ES 2.0 and OpenAL.
It works well even on 12 years old computers. In 2020 it has been used by more than 90k unique players.
Supported platforms:
- Windows (min. Windows 7)
- Linux
- Android (min. 5.0)

Planned support:
- Mac OS
- iOS
- WebAssembly

On this GitHub you can find free version of OTClientV8. It comes without c++ sources, there are prebuilt executables instead.
In many cases, you won't need access to sources, you can add a lot of custom features in lua.
If you're interested in buying access to sources, contact otclient@otclient.ovh or kondrah#7945 on discord.

## DISCORD: https://discord.gg/feySup6
## Forum: http://otclient.net

# FEATURES
- Rewritten and optimized rendering (60 fps on 11 years old computer)
- Better DirectX9 and DirectX11 support
- Adaptive rendering (automated graphics optimizations)
- Rewritten and optimized light rendering
- Rewritten path finding and auto walking
- Rewritten walking system with animations
- HTTP/HTTPS lua API with JSON support
- WebSocket lua API
- Auto updater with failsafe (recovery) mode
- New filesystem
- File encryption and compression
- Automatic diagnostic system
- Refreshed interface
- New crash and error handler
- New HTTP login protocol
- Ingame shop
- Updated hotkey manager
- Updated and optimized battle list
- Crosshair, floor fading, extra health/mana bars and panels
- Much more client options
- Removed a lot of useless and outdated things
- Advanced bot
- Linux version
- Full tibia 11.00 support
- Layouts
- New login server (with ingame account and character creation)
- Support for proxies to lower latency and protect against DDoS (extra paid option)
- Bot protection (extra paid option)
- [Soon] Mobile application for quick authorization

### And hundreds of smaller features, optimizations and bug fixes!
### Check out directory `tutorials` to see how activate and use new features

### There's github repo of tfs 1.3 with otclientv8 features: https://github.com/OTCv8/otclientv8-tfs

# Quick Start for players

Download whole repository and run one of binary file. 

# Quick Start for server owners

Open `init.lua` and edit:

```
-- CONFIG
APP_NAME = "otclientv8" -- important, change it, it's name for config dir and files in appdata
APP_VERSION = 1337      -- client version for updater and login to indentify outdated client
DEFAULT_LAYOUT = "retro"

-- If you don't use updater or other service, set it to updater = ""
Services = {
  website = "http://otclient.ovh", -- currently not used
  updater = "http://otclient.ovh/api/updater.php",
  news = "http://otclient.ovh/api/news.php",
  stats = "",
  crash = "http://otclient.ovh/api/crash.php",
  feedback = "http://otclient.ovh/api/feedback.php"
}

-- Servers accept http login url or ip:port:version
Servers = {
  OTClientV8 = "http://otclient.ovh/api/login.php",
  OTClientV8proxy = "http://otclient.ovh/api/login.php?proxy=1",
  OTClientV8classic = "otclient.ovh:7171:1099",
  OTClientV8cwithfeatures = "otclient.ovh:7171:1099:25:30:80:90",
}
ALLOW_CUSTOM_SERVERS = true -- if true it will show option ANOTHER on server list
-- CONFIG END
```

Also remember to add your sprite and data file to data/things

That's it, you're ready to use OTClientV8.

DirectX version requires 3 dlls: libEGL.dll libGLESv2.dll d3dcompiler_46.dll

If it can't start (missing dlls) then user need to install visual studio 2019 redistributable x86: https://aka.ms/vs/16/release/vc_redist.x86.exe
