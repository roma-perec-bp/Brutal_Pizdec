function onCreate()
    setPropertyFromClass('backend.ClientPrefs', 'data.opponentStrums', false)
end

function onDestroy()
    setPropertyFromClass('backend.ClientPrefs', 'data.opponentStrums', getPropertyFromClass('ClientPrefs', 'opponentStrums'))
  end