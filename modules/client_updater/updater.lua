Updater = { }

Updater.maxRetries = 5

--[[
HOW IT WORKS:
1. init
2. show
3. generateChecksum and get checksums from url
4. compareChecksums
5. download files with different chekcums
6. call c++ update function
]]--

local filesUrl = ""

local updaterWindow = nil
local initialPanel = nil
local updatePanel = nil
local progressBar = nil
local updateProgressBar = nil
local downloadStatusLabel = nil
local downloadProgressBar = nil
local downloadRetries = 0

local generateChecksumsEvent = nil
local updateableFiles = nil
local binaryChecksum = nil
local binaryFile = ""
local fileChecksums = {}
local checksumIter = 0
local downloadIter = 0
local aborted = false
local statusData = nil
local thingsUpdate = {}
local toUpdate = {}
local thingsUpdateOptionalError = nil

local function onDownload(path, checksum, err)
  if aborted then
    return
  end
  
  if err then
    if downloadRetries > Updater.maxRetries then
      return updateError("Can't download file: " .. path .. ".\nError: " .. err)
    else
      downloadRetries = downloadRetries + 1
      return downloadNextFile(true)
    end
  end
  if statusData["files"][path] == nil then
      return updateError("Invalid file path: " .. path)    
  elseif statusData["files"][path] ~= checksum then
      return updateError("Invalid file checksum.\nFile: " .. path .. "\nShould be:\n" .. statusData["files"][path] .. "\nIs:\n" .. checksum)  
  end
  downloadIter = downloadIter + 1
  updateProgressBar:setPercent(math.ceil((100 * downloadIter) / #toUpdate))
  downloadProgressBar:setPercent(100)
  downloadProgressBar:setText("")
  downloadNextFile(false)
end

local function onDownloadProgress(progress, speed)
  downloadProgressBar:setPercent(progress)
  downloadProgressBar:setText(speed .. " kbps")  
end

local function gotStatus(data, err)
  if err then
    return updateError(err)
  end
  if data["error"] ~= nil and data["error"]:len() > 0 then
    return updateError(data["error"])     
  end
  if data["url"] == nil or data["files"] == nil or data["binary"] == nil then
    return updateError("Invalid json data from server")    
  end
  if data["things"] ~= nil then
    for file, checksum in pairs(data["things"]) do
      if #checksum > 1 then
        for thingtype, thingdata in pairs(thingsUpdate) do
          if string.match(file:lower(), thingdata[1]:lower()) then
            data["files"][file] = checksum
            break
          end
        end    
      end
    end
  end  
  statusData = data
  if checksumIter == 100 then
    compareChecksums()
  end
end

-- public functions
function Updater.init()
  updaterWindow = g_ui.displayUI('updater')
  updaterWindow:hide()
  
  initialPanel = updaterWindow:getChildById('initialPanel')
  updatePanel = updaterWindow:getChildById('updatePanel')
  progressBar = initialPanel:getChildById('progressBar')
  updateProgressBar = updatePanel:getChildById('updateProgressBar')
  downloadStatusLabel = updatePanel:getChildById('downloadStatusLabel')
  downloadProgressBar = updatePanel:getChildById('downloadProgressBar')
  updatePanel:hide()
    
  scheduleEvent(Updater.show, 200)
end

function Updater.terminate()
  updaterWindow:destroy()
  updaterWindow = nil
  
  removeEvent(generateChecksumsEvent)
end

local function clear()
  removeEvent(generateChecksumsEvent)

  updateableFiles = nil
  binaryChecksum = nil
  binaryFile = ""
  fileChecksums = {}
  checksumIter = 0
  downloadIter = 0
  aborted = false
  statusData = nil
  toUpdate = {}  
  progressBar:setPercent(0)
  updateProgressBar:setPercent(0)
  downloadProgressBar:setPercent(0)
  downloadProgressBar:setText("")
end

function Updater.show()
  if not g_resources.isLoadedFromArchive() or Services.updater == nil or Services.updater:len() < 4 then
    return Updater.hide()
  end  
  if updaterWindow:isVisible() then
    return
  end
  updaterWindow:show()  
  updaterWindow:raise()
  updaterWindow:focus()
  if EnterGame then
    EnterGame.hide()
  end

  clear()
  
  updateableFiles = g_resources.listUpdateableFiles()
  if #updateableFiles < 1 then
    return updateError("Can't get list of files")
  end
  binaryChecksum = g_resources.selfChecksum():lower()
  if binaryChecksum:len() ~= 32 then
    return updateError("Invalid binary checksum: " .. binaryChecksum)  
  end
  
  local data = {
    version = APP_VERSION,
    platform = g_window.getPlatformType(),
    uid = G.UUID,
    build_version = g_app.getVersion(),
    build_revision = g_app.getBuildRevision(),
    build_commit = g_app.getBuildCommit(),
    build_date = g_app.getBuildDate(),
    os = g_app.getOs(),
    os_name = g_platform.getOSName()
  }
  HTTP.postJSON(Services.updater, data, gotStatus)
  if generateChecksumsEvent == nil then
	  generateChecksumsEvent = scheduleEvent(generateChecksum, 5)
  end
end

function Updater.isVisible()
  return updaterWindow:isVisible()
end

function Updater.updateThings(things, optionalError)
  thingsUpdate = things
  thingsUpdateOptionalError = optionalError
  Updater:show()
end

function Updater.hide()
  updaterWindow:hide()
  if thingsUpdateOptionalError then
    local msgbox = displayErrorBox("Updater error", thingsUpdateOptionalError:trim())
    msgbox.onOk = function() if EnterGame then EnterGame.show() end end
    thingsUpdateOptionalError = nil
  elseif EnterGame then
    EnterGame.show()
  end
end

function Updater.abort()
  aborted = true
  Updater:hide()
end

function generateChecksum()
  local entries = #updateableFiles
  local fromEntry = math.floor((checksumIter) * (entries / 100))
  local toEntry = math.floor((checksumIter + 1) * (entries / 100))
  if checksumIter == 99 then
    toEntry = #updateableFiles
  end
  for i=fromEntry+1,toEntry do
    local fileName = updateableFiles[i]
    fileChecksums[fileName] = g_resources.fileChecksum(fileName):lower()
  end
    
  checksumIter = checksumIter + 1
  if checksumIter == 100 then
    generateChecksumsEvent = nil
    gotChecksums()
  else
    progressBar:setPercent(math.ceil(checksumIter * 0.95))
    generateChecksumsEvent = scheduleEvent(generateChecksum, 5)
  end
end

function gotChecksums()
  if statusData ~= nil then
    compareChecksums()
  end
end

function compareChecksums()
  for file, checksum in pairs(statusData["files"]) do
    checksum = checksum:lower()
    if file == statusData["binary"] then
      if binaryChecksum ~= checksum then
        binaryFile = file
        table.insert(toUpdate, binaryFile)
      end      
    else
      local localChecksum = fileChecksums[file]
      if localChecksum ~= checksum then
        table.insert(toUpdate, file)
      end
    end
  end
  if #toUpdate == 0 then
    return upToDate()
  end  
  -- outdated
  filesUrl = statusData["url"]
  initialPanel:hide()
  updatePanel:show()
  updatePanel:getChildById('updateStatusLabel'):setText(tr("Updating %i files", #toUpdate))
  updaterWindow:setHeight(190)
  downloadNextFile(false)
end

function upToDate()
  Updater.hide()
end

function updateError(err)
  Updater.hide()
  local msgbox = displayErrorBox("Updater error", err)
  msgbox.onOk = function() if EnterGame then EnterGame.show() end end
end

function urlencode(url)
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", function(c) string.format("%%%02X", string.byte(c)) end)
  url = url:gsub(" ", "+")
  return url
end

function downloadNextFile(retry) 
  if aborted then
    return
  end
  
  updaterWindow:show()
  updaterWindow:raise()
  updaterWindow:focus()
 
  if downloadIter == #toUpdate then    
    return downloadingFinished()
  end
  
  if retry then
    retry = " (" .. downloadRetries .. " retry)"
  else
    retry = ""
  end    
   
  local file = toUpdate[downloadIter + 1]
  downloadStatusLabel:setText(tr("Downloading %i of %i%s:\n%s", downloadIter + 1, #toUpdate, retry, file))
  downloadProgressBar:setPercent(0)
  downloadProgressBar:setText("")
  HTTP.download(filesUrl .. urlencode(file), file, onDownload, onDownloadProgress)
end

function downloadingFinished()
  thingsUpdateOptionalError = nil
  UIMessageBox.display(tr("Success"), tr("Download complate.\nUpdating client..."), {}, nil, nil) 
  scheduleEvent(function()
      local files = {}
      for file, checksum in pairs(statusData["files"]) do
        table.insert(files, file)
      end
      g_settings.save()
      g_resources.updateClient(files, binaryFile) 
      g_app.quick_exit()
    end, 1000)
end
