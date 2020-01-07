--[[
Config. create. load and save config file (.json)
Used by cavebot and other things
]]--

local context = G.botContext
context.Config = {}
local Config = context.Config

Config.exist = function(dir)
  return g_resources.directoryExists(context.configDir .. "/" .. dir)
end

Config.create = function(dir)
  g_resources.makeDir(context.configDir .. "/" .. dir)
  return Config.exist(dir)
end

Config.list = function(dir)
  if not Config.exist(dir) then
    if not Config.create(dir) then
      return contex.error("Can't create config dir: " .. context.configDir .. "/" .. dir)
    end
  end
  return g_resources.listDirectoryFiles(context.configDir .. "/" .. dir)
end

Config.load = function(dir, name)
  local file = context.configDir .. "/" .. dir .. "/" .. name .. ".json"
  if g_resources.fileExists(file) then -- load json
    return json.decode(g_resources.readFileContents(file))
  end 
  file = context.configDir .. "/" .. dir .. "/" .. name .. ".cfg"
  if g_resources.fileExists(file) then -- load cfg
    return g_resources.readFileContents(file)
  end   
  return context.error("Config " .. file .. " doesn't exist")
end

Config.save = function(dir, name, value)
  if not Config.exist(dir) then
    if not Config.create(dir) then
      return contex.error("Can't create config dir: " .. context.configDir .. "/" .. dir)
    end
  end
  local file = context.configDir .. "/" .. dir .. "/" .. name
  if type(value) == 'string' then -- cfg
    g_resources.writeFileContents(file .. ".cfg", value)
  elseif type(value) == 'table' then -- json
    g_resources.writeFileContents(file .. ".json", json.encode(value))    
  end
  return context.error("Invalid config value type: " .. type(value))
end

Config.remove = function(dir, name)
  local file = context.configDir .. "/" .. dir .. "/" .. name .. ".json"
  if g_resources.fileExists(file) then
    return g_resources.deleteFile(file)    
  end 
  file = context.configDir .. "/" .. dir .. "/" .. name .. ".cfg"
  if g_resources.fileExists(file) then
    return g_resources.deleteFile(file)    
  end     
end

-- setup is used for BotConfig widget
-- not done yet
Config.setup = function(dir, widget, callback)  
  local refresh = function()
    --
  end

  widget.switch.onClick = function()
    widget.switch:setOn(not widget.switch:isOn())
  end
  
  widget.add = function()

  end
  
  widget.edit = function()
  
  end
  
  widget.remove = function()
  
  end
  
  --local configs = Config.list(dir)
  --widget.list.

  return {
    isOn = function()
      return widget.switch:isOn()
    end,
    isOff = function()
      return not widget.switch:isOn()    
    end,
    enable = function()
      if not widget.switch:isOn() then
        widget.switch:onClick()
      end
    end,
    disable = function()
      if widget.switch:isOn() then
        widget.switch:onClick()
      end
    end,
    save = function()
    
    end
  }
end