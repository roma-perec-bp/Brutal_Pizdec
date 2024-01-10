function onCreatePost()
    updateIcon(1, getProperty("boyfriend.healthIcon"))
    updateIcon(2, getProperty("dad.healthIcon"))
end

function onEvent(eventName, value1, value2)
    if eventName == "Change Character" then
        local charType = 1
        if stringTrim(value1:lower()) == "dad" or stringTrim(value1:lower()) == "opponent" then
            charType = 2
        else
            charType = tonumber(value1)
            if isnan(charType) then
                charType = 1
            end
        end

        local chars = {"boyfriend", "dad"}
        updateIcon(charType, chars[charType])
    end
end

function isnan(num)
    return num ~= num
end

-- 俺はバカ野郎だ
function updateIcon(num, char)
    local tag = "iconP" .. num

    local name = "icons/" .. char
    if not checkFileExists("images/" .. name .. ".png") and not checkFileExists("assets/images/" .. name .. ".png", true) then
        name = "icons/icon-" .. char
    end
    if not checkFileExists("images/" .. name .. ".png") and not checkFileExists("assets/images/" .. name .. ".png", true) then
        name = "icons/icon-face"
    end
    debugPrint(name)

    loadGraphic(tag, name)
    loadGraphic(tag, name, math.floor(getProperty(tag .. ".width") / 3), math.floor(getProperty(tag .. ".height")));
    updateHitbox(tag)

    -- runHaxeCode("game." .. tag .. ".animation.add(" .. char .. ", [0, 1, 2], 0, false, " .. num == 1 .. ");");
    addAnimation(tag, char, {0, 1, 2}, 0, false)
    setProperty(tag .. ".flipX", num == 1)

    setProperty(tag .. ".antialiasing", getPropertyFromClass("ClientPrefs", "globalAntialiasing"))
    if stringEndsWith(char, "-pixel") then
        setProperty(tag .. ".antialiasing", false)
    end
end

function onUpdatePost(elapsed)
    local health = getProperty("healthBar.percent")

    if health < 20 then
        setProperty("iconP1.animation.curAnim.curFrame", 1)
        setProperty("iconP2.animation.curAnim.curFrame", 2)
    elseif health > 80 then
        setProperty("iconP1.animation.curAnim.curFrame", 2)
        setProperty("iconP2.animation.curAnim.curFrame", 1)
    else
        setProperty("iconP1.animation.curAnim.curFrame", 0)
        setProperty("iconP2.animation.curAnim.curFrame", 0)
    end
end