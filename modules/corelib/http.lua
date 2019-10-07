HTTP = {
  timeout=5,
  imageId=1000,
  images={},
  operations={}
}

function HTTP.get(url, callback)
  local operation = g_http.get(url, HTTP.timeout)
  HTTP.operations[operation] = {type="get", url=url, callback=callback}  
  return operation
end

function HTTP.getJSON(url, callback)
  local operation = g_http.get(url, HTTP.timeout)
  HTTP.operations[operation] = {type="get", json=true, url=url, callback=callback}  
  return operation
end

function HTTP.post(url, data, callback)
  if type(data) == "table" then
    data = json.encode(data)
  end
  local operation = g_http.post(url, data, HTTP.timeout)
  HTTP.operations[operation] = {type="post", url=url, callback=callback}
  return operation
end

function HTTP.postJSON(url, data, callback)
  if type(data) == "table" then
    data = json.encode(data)
  end
  local operation = g_http.post(url, data, HTTP.timeout)
  HTTP.operations[operation] = {type="post", json=true, url=url, callback=callback}
  return operation
end

function HTTP.download(url, file, callback, progressCallback)
  local operation = g_http.download(url, file, HTTP.timeout)
  HTTP.operations[operation] = {type="download", url=url, file=file, callback=callback, progressCallback=progressCallback}  
  return operation
end

function HTTP.downloadImage(url, callback)
  if HTTP.images[url] ~= nil then
    if callback then
      callback('/downloads/' .. HTTP.images[url], nil)
    end
    return
  end
  local file = "autoimage_" .. HTTP.imageId .. ".png"
  HTTP.imageId = HTTP.imageId + 1
  local operation = g_http.download(url, file, HTTP.timeout)
  HTTP.operations[operation] = {type="image", url=url, file=file, callback=callback}  
  return operation
end

function HTTP.cancel(operationId)
  return g_http.cancel(operationId)
end

function HTTP.onGet(operationId, url, err, data)
  local operation = HTTP.operations[operationId]
  if operation == nil then
    return
  end
  if err and err:len() == 0 then
    err = nil
  end
  if not err and operation.json then
    local status, result = pcall(function() return json.decode(data) end)
    if not status then
      err = "JSON ERROR: " .. result
    end  
    data = result
  end
  if operation.callback then
    operation.callback(data, err)
  end
end

function HTTP.onGetProgress(operationId, url, progress)
  local operation = HTTP.operations[operationId]
  if operation == nil then
    return
  end
  
end

function HTTP.onPost(operationId, url, err, data)
  local operation = HTTP.operations[operationId]
  if operation == nil then
    return
  end
  if err and err:len() == 0 then
    err = nil
  end
  if not err and operation.json then
    local status, result = pcall(function() return json.decode(data) end)
    if not status then
      err = "JSON ERROR: " .. result
    end  
    data = result
  end
  if operation.callback then
    operation.callback(data, err)
  end
end

function HTTP.onPostProgress(operationId, url, progress)
  local operation = HTTP.operations[operationId]
  if operation == nil then
    return
  end
end

function HTTP.onDownload(operationId, url, err, path, checksum)
  local operation = HTTP.operations[operationId]
  if operation == nil then
    return
  end
  if err and err:len() == 0 then
    err = nil
  end
  if operation.callback then
    if operation["type"] == "image" then
      HTTP.images[url] = path
      operation.callback('/downloads/' .. path, err)    
    else
      operation.callback(path, checksum, err)
    end
  end
end

function HTTP.onDownloadProgress(operationId, url, progress, speed)
  local operation = HTTP.operations[operationId]
  if operation == nil then
    return
  end
  if operation.progressCallback then
    operation.progressCallback(progress, speed)
  end
end

connect(g_http, 
  {
    onGet = HTTP.onGet,
    onGetProgress = HTTP.onGetProgress,
    onPost = HTTP.onPost,
    onPostProgress = HTTP.onPostProgress,
    onDownload = HTTP.onDownload,
    onDownloadProgress = HTTP.onDownloadProgress
  })
 