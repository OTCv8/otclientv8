## OTClientV8 Updater, encryption and compression

OTClientV8 comes with updater, encryption and file compression, here's how to use it.

## Video version: https://www.youtube.com/watch?v=RzEZ__Iq9-s
[![Video tutorial](https://img.youtube.com/vi/RzEZ__Iq9-s/0.jpg)](https://www.youtube.com/watch?v=RzEZ__Iq9-s)


## Encryption and compression
First of all, encryption and compression is basically the same, wherever you encrypt file, first it's being compressed. For example, otcv8 is able to compress Tibia.dat from Tibia 10.99 from 177 MB to 49 MB.

### Steps:
1. First edit init.lua, make sure you set correct APP_NAME (just keep it unique), Services and Servers
2. Copy directory with everything, if you encrypt it by mistake you won't be able to recover it back. From now we work in copied directory
3. Open cmd, run otclient_gl.exe --encrypt
4. Wait 10-30s for message "encryption complete", close this message
5. Now create zip archive with data, modules and init.lua. To create zip archive use default windows feature for that, just select data, modules and init.lua, right click, send to -> Compress (zipped) folder. Rename this archive to data.zip
6. That's it. Copy otclient_gl.exe, otclient_dx.exe, libEGL.dll, libGLESv2.dll, d3dcompiler_46.dll and data.zip to another folder, compress this new folder and send it to players

### Extra steps if you don't want to have data.zip:
7. We will add data.zip to .exe files, because there are 2 exes, if you're using updater and your data.zip is big, let's say bigger than 20MB, remove Tibia.dat and Tibia.spr from data.zip to make it smaller. OTCv8 will download them from updater.
8. Open cmd, and run 2 commands
```
type data.zip >> otclient_gl.exe
type data.zip >> otclient_dx.exe
```
It will append data.zip archive to .exe file, `type` is windows equivalent of linux `cat`.

9. Remove data.zip, send otclient_gl.exe, otclient_dx.exe, libEGL.dll, libGLESv2.dll and d3dcompiler_46.dll to players.

### WARNING: When using data.zip (also inside .exe), all files must be encrypted, otherwise otclient won't start (will display decryption error)

## Updater
1. On your website server, upload somewhere updater.php and set link to updater service in init.lua, for example: `updater = "http://otclient.ovh/test/updater.php"`
2. Now create directory for your files, let's make directory called `files`
3. Upload otclient_gl.exe, otclient_dx.exe, libEGL.dll, libGLESv2.dll, d3dcompiler_46.dll and data.zip (with spr and dat)
4. Unpack data.zip, you can use linux command `unzip data.zip`
5. Open updater.php and configure it, especially:
```
$data_dir = "/var/www/otclient/test/files";
$things_dir = "/data/things"; // files from that dir won't be downloaded automaticly, you can set it to null to download everything automaticly (useful if you have only 1 version of data/sprites)
$files_url = "http://otclient.ovh/test/files";
```
6. Set chmod 777 to dir with updater.php, it must be able to create checksum files, so for example: `chmod 777 /var/www/html/otclient/test`

That's it your updater is configured. If you change something just remember to encrypt it first and then put it to your `files` directory.

### Updated files and binaries are kept in %appdata%\otclientv8\APP_NAME

## OTClientV8 failsafe and startup procedure
Sometimes you may fuckup something, and after update your client won't launch correctly. For your luck there's failsafe mode which can help recover from that state. But before explaing that, let's see how startup procedure looks like:

1. If there's init.lua in directory launch using this init.lua, don't use updater and finish startup sequence.
2. Scan files in %appdata%\otclientv8\APP_NAME, if there's an exe of same type (dx/gl in file name) newer than current running file, launch this exe. If new exe has been launched, wait 10s, if it's still working correctly then finish working, if not, then launch failsafe mode.
3. If there's no any newer exe to launch, check if there's data.zip in %appdata%\otclientv8\APP_NAME, if there is, use that data.zip. If it doesn't exist, use data.zip from current directory and if that doesn't exist too, try to use data.zip inside .exe file.
4. If anything goes wrong, fatal error, crash or anything else within 10s from start, start failsafe mode

In failsafe mode, otcv8 will load data.zip inside .exe file, not from %appdata%\otclientv8\APP_NAME. It will download all files again and create new data.zip in %appdata%\otclientv8\APP_NAME, then it will restart and try to run itself again using data.zip from %appdata%\otclientv8\APP_NAME. 
So if you by mistake uploaded wrong file and otcv8 won't start (for example it won't start if you use data.zip and some files are unencrypted), you still can fix that by uploading correct file. Players won't need to download everything again. 
