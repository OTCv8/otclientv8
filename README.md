# OTClientV8

Preview version of OTClientV8, it's v0.95 beta, version v1.0 with all tutorial will be released soon
It's based on https://github.com/edubart/otclient. It's not backward compatible

# DISCORD
OTClientV8 discord channel: https://discord.gg/DExGSs

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
Soon I will add tutorial how to activate extra features (there are a lot of them)

DirectX version requires 3 dlls: libEGL.dll libGLESv2.dll d3dcompiler_46.dll

If it can't start (missing dlls) then user need to install visual studio 2019 redistributable x86: https://aka.ms/vs/16/release/vc_redist.x86.exe
