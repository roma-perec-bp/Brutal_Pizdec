function onCreate()
    makeLuaSprite('sky', 'sky', 0, 0)
    screenCenter('sky')
    setScrollFactor('sky', 0.75, 0.75)
    addLuaSprite('sky')

    makeLuaSprite('home', 'home', -1200, -580)
    scaleObject('home', 1.4, 1.4)
    addLuaSprite('home')
end