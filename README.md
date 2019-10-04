# OTClientV8

Preview version of OTClientV8, version v1.0 with tutorials will be released soon.
It's based on https://github.com/edubart/otclient and it's not backward compatible.

# DISCORD
OTClientV8 discord channel: https://discord.gg/feySup6 (new, working link!)

# FEATURES
- Rewrited and optimized rendering (60 fps on 11 years old computer)
- Better DirectX9 and DirectX11 support
- Adaptive rendering (automated graphics optimizations)
- Rewrited light rendering
- Rewrited path finding and auto walking
- Rewrited walking system
- HTTP lua API with JSON support
- Auto updater
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
- Removed a lot of useless and outdated things
- Support for proxies to lower latency and protect against DDoS (extra paid option)

### And hundreds of smaller features, optimizations and bug fixes!
### Check out directory `tutorials` to see how active and use features

### There's github repo of tfs 1.3 with otclientv8 features: https://github.com/OTCv8/otclientv8-tfs

# Facts
### It took almost 1000h to make this project
### OTClientV8 has been used by over 6000 unique players!
### You can check last active players on: http://otclient.ovh/clients.php

# Paid version
The difference between paid version and this one is that the 1st one comes with c++ sources and has professional support.  You may need c++ source if you want to add some more advanced modifications, better encryption, bot protection or some other things. The free version doesn't offer technical support, you need to follow tutorials and in case of any bug or problem you should submit an issue on github. Check http://otclient.ovh if you want more about paid version and other extra services.

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
  OTClientV8c = "otclient.ovh:7171:1099"
}
ALLOW_CUSTOM_SERVERS = true -- if true it will show option ANOTHER on server list
-- CONFIG END
```

Also remember to add your sprite and data file to data/things

That's it, you're ready to use OTClientV8.

DirectX version requires 3 dlls: libEGL.dll libGLESv2.dll d3dcompiler_46.dll

If it can't start (missing dlls) then user need to install visual studio 2019 redistributable x86: https://aka.ms/vs/16/release/vc_redist.x86.exe
