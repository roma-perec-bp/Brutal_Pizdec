local textureDefault = ''

function onSongStart()
    for index = 0, 3 do
        textureDefault = getPropertyFromGroup('strumLineNotes', index, 'texture')
    end
end

function onUpdate()
    if curStep == 2718 then
        for index = 0, 3 do
            setPropertyFromGroup('strumLineNotes', index, 'useRGBShader', false);
         end
    end
    if curStep == 2975 then
        for index = 0, 3 do
            setPropertyFromGroup('strumLineNotes', index, 'useRGBShader', true);
        end
    end
 end

function onStepHit()
    if curStep == 2719 then
        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i, 'texture', 'noteSkins/NOTE_assets-mania')
            scaleObject('strumLineNotes.members['..i..']',1,1)
        end
    end
    if curStep == 2976 then
        for i = 0, 3 do
            callMethod('strumLineNotes.members['..i..'].reloadNote', {''})
            setPropertyFromGroup('strumLineNotes', i, 'texture', textureDefault)
        end
    end
end