function onSongStart()
    for i = 0,3 do
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
    end
end