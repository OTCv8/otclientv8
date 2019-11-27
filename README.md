# OTClientV8

Tibia client design for versions 7.40 - 10.99
It's based on https://github.com/edubart/otclient and it's not backward compatible.

## DISCORD: https://discord.gg/feySup6
## Forum: https://otland.net/forums/otclient.494/

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
- Ingame shop and news
- Updated hotkey manager
- Updated and optimized battle list
- Crosshair, floor fading, extra health/mana bars and panels
- Much more client options
- Removed a lot of useless and outdated things
- Advanced bot (https://github.com/OTCv8/otclientv8_bot)
- Linux version
- Support for proxies to lower latency and protect against DDoS (extra paid option)
- Bot protection (extra paid option)
- [Soon] Mobile application for quick authorization

### And hundreds of smaller features, optimizations and bug fixes!
### Check out directory `tutorials` to see how activate and use new features

### There's github repo of tfs 1.3 with otclientv8 features: https://github.com/OTCv8/otclientv8-tfs

# Paid version
The difference between paid version and this one is that the 1st one comes with c++ sources and has better support.  You may need c++ source if you want to add some more advanced modifications, better encryption, bot protection or some other things. The free version doesn't offer technical support, you need to follow tutorials and in case of any bug or problem you should submit an issue on github. Visit http://otclient.ovh if you want to know more about paid version and other extra services.

# Quick Start

Open `init.lua` and edit:

```
-- CONFIG
APP_NAME = "otclientv8" -- important, change it, it's name for config dir and files in appdata
APP_VERSION = 1337      -- client version for updater and login to indentify outdated client

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
