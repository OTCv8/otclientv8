-- sponsored by kivera-global.com

local preyWindow
local preyButton
local msgWindow
local bankGold = 0
local inventoryGold = 0
local rerollPrice = 0
local bonusRerolls = 0

local PREY_BONUS_DAMAGE_BOOST = 0
local PREY_BONUS_DAMAGE_REDUCTION = 1
local PREY_BONUS_XP_BONUS = 2
local PREY_BONUS_IMPROVED_LOOT = 3
local PREY_BONUS_NONE = 4 

local PREY_ACTION_LISTREROLL = 0
local PREY_ACTION_BONUSREROLL = 1
local PREY_ACTION_MONSTERSELECTION = 2
local PREY_ACTION_REQUEST_ALL_MONSTERS = 3
local PREY_ACTION_CHANGE_FROM_ALL = 4
local PREY_ACTION_LOCK_PREY = 5


function bonusDescription(bonusType, bonusValue, bonusGrade)
  if bonusType == PREY_BONUS_DAMAGE_BOOST then
    return "Damage bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_DAMAGE_REDUCTION then
    return "Damage reduction bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_XP_BONUS then
    return "XP bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_IMPROVED_LOOT then
    return "Loot bonus (" .. bonusGrade .. "/10)"
  elseif bonusType == PREY_BONUS_DAMAGE_BOOST then
    return "-"
  end
  return "Uknown bonus"
end

function timeleftTranslation(timeleft, forPreyTimeleft) -- in seconds
  if timeleft == 0 then
    if forPreyTimeleft then
      return tr("infinite bonus")
    end
    return tr("Available now")
  end
  local minutes = math.ceil(timeleft / 60)
  local hours = math.floor(minutes / 60)
  minutes = minutes - hours * 60
  if hours > 0 then
    if forPreyTimeleft then
      return "" .. hours .. "h " .. minutes .. "m"    
    end
    return tr("Available in") .. " " .. hours .. "h " .. minutes .. "m"
  end   
  if forPreyTimeleft then
    return "" .. minutes .. "m"
  end
  return tr("Available in") .. " " .. minutes .. "m"
end  
function init()
  connect(g_game, {
    onGameStart = check,
    onGameEnd = hide,
    onResourceBalance = onResourceBalance,
    onPreyFreeRolls = onPreyFreeRolls,
    onPreyTimeLeft = onPreyTimeLeft,
    onPreyPrice = onPreyPrice,
    onPreyLocked = onPreyLocked,
    onPreyInactive = onPreyInactive,
    onPreyActive = onPreyActive,
    onPreySelection = onPreySelection
  })

  preyWindow = g_ui.displayUI('prey')
  preyWindow:hide()
  if g_game.isOnline() then
    check()
  end
end

function terminate()
  disconnect(g_game, {
    onGameStart = check,
    onGameEnd = hide,
    onResourceBalance = onResourceBalance,
    onPreyFreeRolls = onPreyFreeRolls,
    onPreyTimeLeft = onPreyTimeLeft,
    onPreyPrice = onPreyPrice,
    onPreyLocked = onPreyLocked,
    onPreyInactive = onPreyInactive,
    onPreyActive = onPreyActive,
    onPreySelection = onPreySelection
  })
  
  if preyButton then
    preyButton:destroy()
  end
  preyWindow:destroy()
  if msgWindow then
    msgWindow:destroy()
    msgWindow = nil
  end
end

function check()
  if g_game.getFeature(GamePrey) then
    if not preyButton then
      preyButton = modules.client_topmenu.addRightGameToggleButton('preyButton', tr('Preys'), '/images/topbuttons/prey', toggle)
    end
  elseif preyButton then
    preyButton:destroy()
    preyButton = nil
  end
end

function hide()
  preyWindow:hide()
  if msgWindow then
    msgWindow:destroy()
    msgWindow = nil
  end
end

function show()
  if not g_game.getFeature(GamePrey) then
    return hide()
  end
  preyWindow:show()
  preyWindow:raise()
  preyWindow:focus()
  --g_game.preyRequest() -- update preys, it's for tibia 12
end

function toggle()
  if preyWindow:isVisible() then
    return hide()
  end
  show()
end

function onPreyFreeRolls(slot, timeleft)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  if prey.state ~= "active" and prey.state ~= "selection" then
    return
  end
  prey.bottomLabel:setText(tr("Free list reroll") .. ": \n" .. timeleftTranslation(timeleft * 60))
end

function onPreyTimeLeft(slot, timeleft)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  if prey.state ~= "active" then
    return
  end
  prey.description:setText(tr("Time left") .. ": " .. timeleftTranslation(timeleft, true))  
end

function onPreyPrice(price)
  rerollPrice = price
  preyWindow.rerollPrice:setText(tr("Reroll price") .. ":\n" .. price)
end

function onPreyLocked(slot, unlockState, timeUntilFreeReroll)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  prey.state = "locked"
  prey.title:setText(tr("Prey Locked"))
  prey.list:hide()
  prey.listScrollbar:hide()
  prey.creature:hide()
  prey.description:hide()
  prey.bonuses:hide()
  prey.button:hide()
  prey.bottomLabel:show()
  if unlockState == 0 then
    prey.bottomLabel:setText(tr("You need to have premium account and buy this prey slot in the game store."))
  elseif unlockState == 1 then
    prey.bottomLabel:setText(tr("You need to buy this prey slot in the game store."))
  else
    prey.bottomLabel:setText(tr("You can't unlock it."))
    prey.bottomButton:hide()
  end
  if (unlockState == 0 or unlockState == 1) and modules.game_shop then
    prey.bottomButton:setText("Open game store")
    prey.bottomButton.onClick = function() hide() modules.game_shop.show() end
    prey.bottomButton:show()
  end
end

function onPreyInactive(slot, timeUntilFreeReroll)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  prey.state = "inactive"
  prey.title:setText(tr("Prey Inactive"))
  prey.list:hide()
  prey.listScrollbar:hide()
  prey.creature:hide()
  prey.description:hide()
  prey.bonuses:hide()
  prey.button:hide()
  prey.bottomLabel:hide()
  
  prey.bottomLabel:setText(tr("Free list reroll")..": \n" .. timeleftTranslation(timeUntilFreeReroll * 60)) 
  prey.bottomLabel:show()
  if timeUntilFreeReroll > 0 then
    prey.bottomButton:setText(tr("Buy list reroll"))
  else
    prey.bottomButton:setText(tr("Free list reroll"))
  end
  prey.bottomButton:show()
  prey.bottomButton.onClick = function()
    g_game.preyAction(slot, PREY_ACTION_LISTREROLL, 0)
  end  
end

function onPreyActive(slot, currentHolderName, currentHolderOutfit, bonusType, bonusValue, bonusGrade, timeLeft, timeUntilFreeReroll)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  prey.state = "active"
  prey.title:setText(currentHolderName)
  prey.list:hide()
  prey.listScrollbar:hide()
  prey.creature:show()
  prey.creature:setOutfit(currentHolderOutfit)
  prey.description:setText(tr("Time left") .. ": " .. timeleftTranslation(timeLeft, true))
  prey.description:show()
  prey.bonuses:setText(bonusDescription(bonusType, bonusValue, bonusGrade))
  prey.bonuses:show()
  prey.button:setText(tr("Bonus reroll"))
  prey.button:show()
  prey.bottomLabel:setText(tr("Free list reroll")..": \n" .. timeleftTranslation(timeUntilFreeReroll * 60)) 
  prey.bottomLabel:show()
  if timeUntilFreeReroll > 0 then
    prey.bottomButton:setText(tr("Buy list reroll"))
  else
    prey.bottomButton:setText(tr("Free list reroll"))
  end
  prey.bottomButton:show()
  
  prey.button.onClick = function()
    if bonusRerolls == 0 then
      return showMessage(tr("Error"), tr("You don't have any bonus rerolls.\nYou can buy them in ingame store."))
    end    
    g_game.preyAction(slot, PREY_ACTION_BONUSREROLL, 0)
  end

  prey.bottomButton.onClick = function()
    g_game.preyAction(slot, PREY_ACTION_LISTREROLL, 0)
  end
end

function onPreySelection(slot, bonusType, bonusValue, bonusGrade, names, outfits, timeUntilFreeReroll)
  local prey = preyWindow["slot" .. (slot + 1)]
  if not prey then return end
  prey.state = "selection"
  prey.title:setText(tr("Select monster"))
  prey.list:show()
  prey.listScrollbar:show()
  prey.creature:hide()
  prey.description:hide()
  prey.bonuses:hide()
  prey.button:setText(tr("Select"))
  prey.button:show()
  prey.bottomLabel:setText("Free list reroll: \n" .. timeleftTranslation(timeUntilFreeReroll * 60)) 
  prey.bottomLabel:show()
  prey.bottomButton:hide()
  prey.list:destroyChildren()
  for i, name in ipairs(names) do
    local label = g_ui.createWidget("PreySelectionLabel", prey.list)
    label:setText(name)  
    label.creature:setOutfit(outfits[i])
  end
  prey.button.onClick = function()
    local child = prey.list:getFocusedChild()
    if not child then 
          return showMessage(tr("Error"), tr("Select monster to proceed."))
    end
    local index = prey.list:getChildIndex(child)
    g_game.preyAction(slot, PREY_ACTION_MONSTERSELECTION, index - 1)
  end
end

function onResourceBalance(type, balance)
  if type == 0 then -- bank gold
    bankGold = balance
  elseif type == 1 then -- inventory gold
    inventoryGold = balance
  elseif type == 10 then -- bonus rerolls
    bonusRerolls = balance
    preyWindow.bonusRerolls:setText(tr("Available bonus rerolls") .. ":\n" .. balance)
  end
  
  if type == 0 or type == 1 then
    preyWindow.balance:setText(tr("Balance") .. ":\n" .. (bankGold + inventoryGold))
  end
end

function showMessage(title, message)
  if msgWindow then
    msgWindow:destroy()
  end
    
  msgWindow = displayInfoBox(title, message)
  msgWindow:show()
  msgWindow:raise()
  msgWindow:focus()
end