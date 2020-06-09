local CRASH_FILE = "exception.dmp"

function init()
  if g_resources.fileExists(CRASH_FILE) then
    local crashLog = g_resources.readFileContents(CRASH_FILE)
    local clientLog = g_logger.getLastLog()
    HTTP.post(Services.crash, {
      version = APP_VERSION,
      build = g_app.getVersion(),
      os = g_app.getOs(),
      platform = g_window.getPlatformType(),
      crash = base64.encode(crashLog),
      log = base64.encode(clientLog)
    }, function(data, err)
      if err then 
        return g_logger.error("Error while reporting crash report: " .. err)
      end
      g_resources.deleteFile(CRASH_FILE)
    end)      
  end
end
