-- private variables
local news
local newsPanel
local updateNewsEvent = nil
local ongoingNewsUpdate = false
local lastNewsUpdate = 0
local newsUpdateInterval = 30 -- seconds

-- public functions
function init()
  news = g_ui.displayUI('news')
  newsPanel = news:recursiveGetChildById('newsPanel')

  connect(rootWidget, { onGeometryChange = updateSize })  
  connect(g_game, { onGameStart = hide, onGameEnd = show  })

  if g_game.isOnline() then
    hide()
  else
    show()
  end
end

function terminate()
  disconnect(rootWidget, { onGeometryChange = updateSize })
  disconnect(g_game, { onGameStart = hide, onGameEnd = show  })
  
  removeEvent(updateNewsEvent)
  clearNews()

  news:destroy()
  news = nil
end

function hide()
  news:hide()
end

function show()
  news:show()
  updateSize()
  updateNews()
end

function updateSize() 
  if Services.news == nil or Services.news:len() < 4 or g_game.isOnline() then
    return
  end
  if rootWidget:getWidth() < 790 and news:isVisible() then
    hide()
  elseif news:isHidden() then
    show()
  end
  news:setWidth(math.min(math.max(250, rootWidget:getWidth() / 4), 300)) 
end

function updateNews()
  if Services.news == nil or Services.news:len() < 4 then
    hide()
    return
  end
  if ongoingNewsUpdate or os.time() < lastNewsUpdate + newsUpdateInterval then
    return
  end  
  HTTP.getJSON(Services.news .. "?lang=" .. modules.client_locales.getCurrentLocale().name, onGotNews)
  ongoingNewsUpdate = true
  lastNewsUpdate = os.time()
end

function clearNews()
  while newsPanel:getChildCount() > 0 do
    local child = newsPanel:getLastChild()
    newsPanel:destroyChildren(child)
  end
end

function onGotNews(data, err) 
  ongoingNewsUpdate = false
  if err then
    return gotNewsError("Error:\n" .. err) 
  end
  
  clearNews()
  
  for i, news in pairs(data) do
    local title = news["title"]
    local text = news["text"]
    local image = news["image"]
    if title ~= nil then
      newsLabel = g_ui.createWidget('NewsLabel', newsPanel)
      newsLabel:setText(title)
    end
    if text ~= nil then
      newsText = g_ui.createWidget('NewsText', newsPanel)  
      newsText:setText(text)
    end
    if image ~= nil then
      newsImage = g_ui.createWidget('NewsImage', newsPanel)
      newsImage:setId(imageName)
      newsImage:setImageSourceBase64(image)
      newsImage:setImageFixedRatio(true)
      newsImage:setImageAutoResize(false)
      newsImage:setHeight(200)
    end
  end  
end

function gotNewsError(err)  
  updateNewsEvent = scheduleEvent(function() 
    updateNews()
  end, 3000)

  clearNews()  
  errorLabel = g_ui.createWidget('NewsLabel', newsPanel)
  errorLabel:setText(tr("Error"))
  errorInfo = g_ui.createWidget('NewsText', newsPanel)  
  errorInfo:setText(err)
  ongoingNewsUpdate = true
end