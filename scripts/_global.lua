local toCustomFreeplay = false

function onUpdate(elapsed)
	if keyboardJustPressed('ESCAPE') then
		toCustomFreeplay = true
	end
end

function onPause()
	if toCustomFreeplay then
		loadSong('freeplay')
		return Function_Stop
	end
end