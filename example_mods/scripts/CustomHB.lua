function onCreate()
    makeLuaSprite('customhb', 'healthBarBG', 0, 603)
    setObjectCamera('customhb', 'camHUD')
    addLuaSprite('customhb', true)
    screenCenter('customhb', 'x')

    setObjectOrder('customhb', getObjectOrder('healthBar') + 1)
    scaleObject('healthBar', 1, 1.3)
    setProperty('healthBarBG.visible', false)
    setProperty('healthBar.y', getProperty('healthBar.y') - 1)

    if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') == true then
        setProperty('customhb.y', 63.5)
    end
end