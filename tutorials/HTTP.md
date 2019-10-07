## OTClientV8 HTTP protocol

OTClientV8 comes with HTTP/HTTPS and JSON support in lua. 

### Available functions
```
HTTP.get(url, callback)
HTTP.getJSON(url, callback) -- website should return json
HTTP.post(url, data, callback)
HTTP.postJSON(url, data, callback) -- data should be a table {} and website should return json
HTTP.download(url, file, downloadCallback, progressCallback) -- progressCallback can be null
HTTP.downloadImage(url, downloadImageCallback)
HTTP.cancel(operationId)
```

Each function, except `cancel` return operationId, you can use it to cancel http request.
Those functions came from `modules/corelib/http.lua` and they use more advanced g_http API.
Files from download are available in virtual "/downloads" directory. Downloading of images is using cache based on url (so if you change image it won't refresh until restart or change url).

### Callbacks
For get, getJSON, post and postJSON HTTP callback should look like this:
```
function callback(data, err)
    if err then
        -- handle error, if err is not null then err is a string
        return 
    end
    -- handle data
    -- if it's data from getJSON/postJSON then data is a table {}
end
```

For download:
```
function downloadCallback(path, checksum, err)
    if err then
        -- handle error, if err is not null then err is a string
        return 
    end
    -- do something with path and checksum
end

function progressCallback(progress, speed)
    -- progress is from 0 to 100
    -- speed is in kbps
end
```

For downloadImage:
```
function downloadImageCallback(path, err)
    if err then
        -- handle error, if err is not null then err is a string
        return 
    end
    -- do something with path to downloaded image
end
```

### Support for images from base64
If you want to load image from base64 there's special function for it: `Image:setImageSourceBase64(base64code)`
You can find an example of that in `modules/client_news/news.lua`. Only PNG images are supported.

### Timeout
Default timeout for every operations is 5s, you can change it in `modules/corelib/http.lua`. 

### Examples
There are few lua scripts using HTTP api:
```
modules/client_entergame/entergame.lua
modules/client_feedback/feedback.lua
modules/client_news/news.lua
modules/client_updater/updater.lua
modules/game_shop/shop.lua
```

Examples:
```
HTTP.get("https://api.ipify.org/", function(data, err)
    if err then
        g_logger.info("Whoops! Error occured: " .. err)
        return
    end
    g_logger.info("My IP is: " .. data)
end)

HTTP.getJSON("https://api.ipify.org/?format=json", function(data, err)
    if err then
        g_logger.info("Whoops! Error occured: " .. err)
        return
    end
    g_logger.info("My IP is: " .. tostring(data['ip']))
end)
```

### Regex
If you're pro, there's also support for simple regex in lua which look like this:
```
    g_lua.bindGlobalFunction("regexMatch", [](std::string s, const std::string& exp) {
        int limit = 10000;
        std::vector<std::vector<std::string>> ret;
        if (s.empty() || exp.empty())
            return ret;
        try {
            std::smatch m;
            std::regex e(exp);
            while (std::regex_search (s,m,e)) {
                ret.push_back(std::vector<std::string>());
                for (auto x:m)
                    ret[ret.size() - 1].push_back(x);                
                s = m.suffix().str();
                if (--limit == 0)
                    return ret;
            }
        } catch (...) {
        }
        return ret;
    });
```
