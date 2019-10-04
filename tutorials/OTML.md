## OTClientV8 OTML extension

In many modules which are using OTML, you can see such code:
```
...
spelllistWindow = g_ui.displayUI('spelllist', modules.game_interface.getRightPanel())
spelllistWindow:hide()

nameValueLabel        = spelllistWindow:getChildById('labelNameValue')
formulaValueLabel     = spelllistWindow:getChildById('labelFormulaValue')
vocationValueLabel    = spelllistWindow:getChildById('labelVocationValue')
groupValueLabel       = spelllistWindow:getChildById('labelGroupValue')
typeValueLabel        = spelllistWindow:getChildById('labelTypeValue')
cooldownValueLabel    = spelllistWindow:getChildById('labelCooldownValue')
levelValueLabel       = spelllistWindow:getChildById('labelLevelValue')
manaValueLabel        = spelllistWindow:getChildById('labelManaValue')
premiumValueLabel     = spelllistWindow:getChildById('labelPremiumValue')
descriptionValueLabel = spelllistWindow:getChildById('labelDescriptionValue')
...
```

Calling getChildById for every element in our OTML is annoying, taking unnecessary cpu time and looks awful. That's why there's new feature which creates reference to children automatically so you don't need to use getChildById ever again.
Instead of using:
```
spelllistWindow = g_ui.displayUI('spelllist', modules.game_interface.getRightPanel())
nameValueLabel        = spelllistWindow:getChildById('labelNameValue')
formulaValueLabel     = spelllistWindow:getChildById('labelFormulaValue')
vocationValueLabel    = spelllistWindow:getChildById('labelVocationValue')
```

In OTClientV8 you can use:
```
spelllistWindow = g_ui.displayUI('spelllist', modules.game_interface.getRightPanel())
spelllistWindow.nameValueLabel
spelllistWindow.formulaValueLabel
spelllistWindow.vocationValueLabel
```

It has been added recently so most of the modules don't use this feature, but you can see it in action for example in `modules/game_shop` module.
In `shop.lua` there're 0 calls for getChildById, code looks like this:
```
shop = g_ui.displayUI('shop')
    
connect(shop.categories, { onChildFocusChange = changeCategory })
    
while shop.offers:getChildCount() > 0 do
    local child = shop.offers:getLastChild()
    shop.offers:destroyChildren(child)
end
    
shop.adPanel:setHeight(shop.infoPanel:getHeight())
shop.adPanel.ad:setText("")

category = g_ui.createWidget('ShopCategoryItem', shop.categories)  
category.item:setItemId(data["item"])
category.item:setItemCount(data["count"])
```

So whenever possible, don't use getChildById. Use this new feature which is nicer and faster.
