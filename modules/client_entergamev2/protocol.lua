EnterGameV2Protocol = {}
EnterGameV2Protocol.__index = EnterGameV2Protocol

EnterGameV2Protocol.new = function(session)
  if type(session) ~= 'string' then
    return error("You need to specify string session for EnterGameV2Protocol")
  end
  local data = {}
  data.socket = nil
  data.terminated = false
  data.reconnectEvent = nil
  data.connected = false
  data.session = session
  data.sendQueue = {}
  data.sendQueueMsgId = 1
  data.loginTimeoutEvent = nil
  setmetatable(data, EnterGameV2Protocol)
  return data
end

function EnterGameV2Protocol:destroy()
  self.terminated = true
  self.sendQueue = {}

  if self.loginTimeoutEvent then
    removeEvent(self.loginTimeoutEvent)
    self.loginTimeoutEvent = nil
  end

  self:reset()
end

function EnterGameV2Protocol:reset()
  self.connected = false
  if self.reconnectEvent then
    removeEvent(self.reconnectEvent)
    self.reconnectEvent = nil
  end  
  if self.socket then
    self.socket.close()
    self.socket = nil
  end
end

function EnterGameV2Protocol:setUrl(url)
  if self.terminated then 
    return false 
  end
  self:reset()
  if self.url ~= url then
    self.sendQueue = {}
    self.sendQueueMsgId = 1
    if self.loginTimeoutEvent then
      removeEvent(self.loginTimeoutEvent)
      self.loginTimeoutEvent = nil
    end
  end
  if type(url) ~= 'string' or not url:lower():find("ws") then
    g_logger.error("Invalid url for EnterGameV2Protocol:\n" .. url)
    return false
  end
  self.url = url
  self.socket = HTTP.WebSocketJSON(url, {
    onOpen = function(message, websocketId)
      if self.terminated or not self.socket or self.socket.id ~= websocketId then return end
      self.connected = true
      self:sendFirstMessage()
    end,
    onMessage = function(message, websocketId)
      if self.terminated or not self.socket or self.socket.id ~= websocketId then return end
      self:onSocketMessage(message)
    end,
    onClose = function(message, websocketId)
      if self.terminated or not self.socket or self.socket.id ~= websocketId then return end
      self.connected = false
      self:scheduleReconnect()
    end,
    onError = function(message, websocketId)
      if self.terminated or not self.socket or self.socket.id ~= websocketId then return end
      self.connected = false
      self:scheduleReconnect()
    end
  })  
  return true
end

function EnterGameV2Protocol:isConnected()
  return self.socket and self.connected
end

function EnterGameV2Protocol:scheduleReconnect()
  if self.socket then
    self.connected = false
    self.socket.close()
    self.socket = nil
  end
  if self.terminated then return end
  if self.reconnectEvent then return end
  self.reconnectEvent = scheduleEvent(function() self:reconnect() end, 500)
end

function EnterGameV2Protocol:login(account, password, token, callback)  
  self:send({
    type="login",
    account=account,
    password=password,
    token=token,
  })
  if self.loginTimeoutEvent then
    removeEvent(self.loginTimeoutEvent)
  end    
  self.loginTimeoutEvent = scheduleEvent(function()
    self.loginTimeoutEvent = nil
    self.onLogin({error="Connection timeout"})
  end, 10000)
end

function EnterGameV2Protocol:logout()
  self:send({
    type="logout"
  })
end

function EnterGameV2Protocol:register(name, email, password, callback)
  
end

function EnterGameV2Protocol:createCharacter(name, gender, vocation, town)
  self:send({
    type="createcharacter",
    name=name,
    gender=gender,
    vocation=vocation,
    town=town
  })
end

function EnterGameV2Protocol:updateSettings(settings)
  self:send({
    type="settings",
    settings=settings
  })
end

-- private functions
function EnterGameV2Protocol:reconnect()
  if #self.sendQueue > 1 then
    self.sendQueue = {} -- TEMPORARY
  end
  self.reconnectEvent = nil
  if self.terminated then return end
  self:setUrl(self.url)
end

function EnterGameV2Protocol:send(data)
  if type(data) ~= "table" then
    return error("data should be table")
  end
  data["id"] = self.sendQueueMsgId
  table.insert(self.sendQueue, {id=self.sendQueueMsgId, msg=json.encode(data)})
  self.sendQueueMsgId = self.sendQueueMsgId + 1
  if self.socket then
    self.socket.send(self.sendQueue[#self.sendQueue].msg)
  end
end

function EnterGameV2Protocol:sendFirstMessage()
  self.socket.send({type="init", session=self.session})
  for i, msg in ipairs(self.sendQueue) do
    self.socket.send(msg.msg)
  end
end

function EnterGameV2Protocol:onSocketMessage(message)
  local lastId = message["lastId"]
  if type(lastId) == 'number' then -- clear send queue
    while #self.sendQueue > 0 do 
      local id = self.sendQueue[1].id
      if id < lastId then
        break
      end
      table.remove(self.sendQueue, 1)
    end
  end
  if message["type"] == "ping" then
    self.socket.send({type="ping"})
  elseif message["type"] == "login" then
    if self.loginTimeoutEvent then
      removeEvent(self.loginTimeoutEvent)
      self.loginTimeoutEvent = nil
    end    
    if self.onLogin then
      self.onLogin(message)
    end
  elseif message["type"] == "logout" then
    if self.onLogout then
      self.onLogout()
    end
  elseif message["type"] == "qauth" then
    if self.onQAuth then
      self.onQAuth(message["token"])
    end
  elseif message["type"] == "characters" then
    if self.onCharacters then
      self.onCharacters(message["characters"])
    end
  elseif message["type"] == "message" then
    if self.onMessage then
      self.onMessage(message["title"], message["text"])
    end 
  elseif message["type"] == "loading" then
    if self.onMessage then
      self.onLoading(message["title"], message["text"])
    end 
  elseif message["type"] == "news" then
    if self.onNews then
      self.onNews(message["news"])
    end
  elseif message["type"] == "motd" then
    if self.onMotd then
      self.onMotd(message["text"])
    end
  elseif message["type"] == "createcharacter" then
    if self.onMessage then
      self.onCharacterCreate(message["error"], message["message"])
    end 
  end
end
