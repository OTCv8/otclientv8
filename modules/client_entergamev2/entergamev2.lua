local entergameWindow
local characterGroup

function init()
  if not USE_NEW_ENERGAME then return end
  entergameWindow = g_ui.displayUI('entergamev2')
  
  --entergameWindow.news:hide()
  --entergameWindow.quick:hide()
  entergameWindow.registration:hide()
  entergameWindow.characters:hide()
  entergameWindow.createcharacter:hide()
  
  -- entergame
  entergameWindow.entergame.register.onClick = function()
    entergameWindow.registration:show()
    entergameWindow.entergame:hide()
  end
  entergameWindow.entergame.mainPanel.button.onClick = function()
    entergameWindow.entergame:hide()
    entergameWindow.characters:show()
    g_game.setClientVersion(1099) -- for tests
  end
  
  -- registration
  entergameWindow.registration.back.onClick = function()
    entergameWindow.registration:hide()
    entergameWindow.entergame:show()
  end
  
  -- characters
  entergameWindow.characters.logout.onClick = function()
    entergameWindow.characters:hide()
    entergameWindow.entergame:show()  
  end
  entergameWindow.characters.createcharacter.onClick = function()
    entergameWindow.characters:hide()
    entergameWindow.createcharacter:show()
  end
  entergameWindow.characters.mainPanel.autoReconnect.onClick = function()
    entergameWindow.characters.mainPanel.autoReconnect:setOn(not entergameWindow.characters.mainPanel.autoReconnect:isOn())
  end
  
  -- create character
  entergameWindow.createcharacter.back.onClick = function()
    entergameWindow.createcharacter:hide()
    entergameWindow.characters:show()
  end
  
  -- tests  
  characterGroup = UIRadioGroup.create()
  for i=1,20 do
    local character = g_ui.createWidget('EntergameCharacter', entergameWindow.characters.mainPanel.charactersPanel)
    characterGroup:addWidget(character)
    character.outfit:setOutfit({feet=10,legs=10,body=176,type=129,auxType=0,addons=3,head=48})
  end
  characterGroup:selectWidget(entergameWindow.characters.mainPanel.charactersPanel:getFirstChild())
  characterGroup:getSelectedWidget()
  
  for i=1,100 do
    local l = g_ui.createWidget("NewsLabel", entergameWindow.news.content)
    l:setText("test xxx ssss eeee uu u llel " .. i)
  end
end

function terminate()
  if not USE_NEW_ENERGAME then return end
  entergameWindow:destroy()
  if characterGroup then
    characterGroup:destroy()
  end
end