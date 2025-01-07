-- Script by MiuJoan6952_2
-- recreation of strident crisis category freeplay?????

local configs = {
	bgImage = 'menuDesat',
	font = 'vcr.ttf',
	alignment = 'left',
	music = 'freakyMenu',
	diff = {'mania', 'normal', 'old'},
	curDiff = 2,
	songs = {
		{ -- syntax: {song name, icon name, color hex string},
			{'Tutorial', 'gf', 'ff0000'}, -- there are example.
			{'Adamophobia', 'tushainan', '000000'},
			{'Transfiguration', 'dan', '101010'},
		},
		{
			{'utility', 'mom', '7F7F00'},
			{'what-the-fuck-is-wrong-with-me', 'qxtq', '7a0000'},
			{'descyrling', 'bambi-old', '7a0000'},
			{'Disinclination', 'bambi-old', '7a0000'}
		},
		{
			{'SPURGLEVILLE', 'multicorn', '000000'},
			{'dumasaphobia', 'multicorn', '000000'}
		},
		{
			{'hell', 'bob', '000000'}
		}
	}
}

-- Library for LUA
-- MathEx
local mathEx = {}
function mathEx:round(v)
	if v < 0 then return math.ceil(v - 0.5) end
	return math.floor(v + 0.5)
end

function mathEx:roundDecimal(v, d)
	return self:round(v * (10 ^ d)) / (10 ^ d)
end

function mathEx:floorDecimal(v, d)
	return math.floor(v * (10 ^ d)) / (10 ^ d)
end

function mathEx:warp(v, l, r)
	if v > r then return l end
	if v < l then return r end
	return v
end
-- End of MathEx

-- TableEx
local tableEx = {}
function tableEx:tableLength(t)
	local count = 0
	for _, _ in pairs(t) do
		count = count + 1
	end
	return count
end

function tableEx:isMap(t)
	return self:tableLength(t) == #t -- since #table_name syntax in lua only work for array table.
end
-- End of TableEx

local function makeSprite(tag, image, x, y, front, cam, sizeX, sizeY, scrollX, scrollY)
	makeLuaSprite(tag, image, x or 0, y or 0)
	scaleObject(tag, sizeX or 1, sizeY or 1)
	setScrollFactor(tag, scrollX or 0, scrollY or 0)
	setObjectCamera(tag, cam or '')
	addLuaSprite(tag, front or false)
end

local function makeSpriteGraphic(tag, x, y, width, height, color, front, cam, sizeX, sizeY, scrollX, scrollY)
	makeSprite(tag, nil, x, y, front, cam, sizeX, sizeY, scrollX, scrollY)
	makeGraphic(tag, width, height, color)
end

local function makeText(tag, text, width, x, y, size, cam, color, font, alignment, borderSize, borderColor)
	if stringTrim(font:lower()) == 'alphabet' then
		addHaxeLibrary('Alphabet', version >= '0.7' and 'objects' or '')
		if version >= '0.7' then
			addHaxeLibrary('LuaUtils', 'psychlua')
		else
			addHaxeLibrary('FunkinLua')
		end
		runHaxeCode([[
			var text = new Alphabet(]]..x..[[, ]]..y..[[, ']]..text..[[', true);
			//text.setAlignmentFromString("]]..alignment..[[");
			//text.camera = (]]..version >= '0.7'..[[ ? LuaUtils.cameraFromString("]]..cam..[[") : FunkinLua.getCam("]]..cam..[["));
			//text.scaleX = ]]..size..[[;
			//text.scaleY = ]]..size..[[;
			//text.color = ]]..getColorFromHex(color)..[[;
			game.add(text);
			game.modchartSprites.set(']]..tag..[[', text);
		]])
		setTextSize(tag, size or 16)
		setTextBorder(tag, borderSize or 2, borderColor or '000000')
		setTextColor(tag, color or 'FFFFFF')
		setObjectCamera(tag, cam or '')
		setTextAlignment(tag, alignment or 'left')
		return
	end
	makeLuaText(tag, text or '', width, x or 0, y or 0)
	setTextSize(tag, size or 16)
	setTextBorder(tag, borderSize or 2, borderColor or '000000')
	setTextColor(tag, color or 'FFFFFF')
	setObjectCamera(tag, cam or '')
	setTextAlignment(tag, alignment or 'left')
	setTextFont(tag, font or 'vcr.ttf')
	addLuaText(tag)
end

local function makeIcon(char, image, x, y)
	if not char or #char == 0 then
		char = image:gsub('icon-', '')
	end
	makeSprite('icon_'..char, 'icons/'..image, x, y, false, 'camOther')
	local function checkIconExist()
		runHaxeCode([[
			var obj = game.getLuaObject('icon_]]..char..[[');
			if (obj.graphic == null) {
				setVar('iconImageExists', false);
			} else {
				setVar('iconImageExists', true);
			}
		]])
		return getProperty('iconImageExists')
	end
	if not checkIconExist() then
		removeLuaSprite('icon_'..char)
		image = 'icon-'..image
		makeSprite('icon_'..char, 'icons/'..image, x, y, false, 'camOther')
	end
	if not checkIconExist() then
		removeLuaSprite('icon_'..char)
		image = 'icon-face'
		makeSprite('icon_'..char, 'icons/'..image, x, y, false, 'camOther')
	end
	loadGraphic('icon_'..char, 'icons/'..image, 150, 150)
	local frames = {}
	for i = 0, math.floor(getProperty('icon_'..char..'.frames.frames.length')), 1 do
		table.insert(frames, #frames + 1, i)
	end
	addAnimation('icon_'..char, char, frames, 0, false)
	playAnim('icon_'..char, char)
end

local function removeIcon(char)
	removeLuaSprite('icon_'..char)
end

local function tableToHxArr(t)
	if not t then return '' end
	local str = '['
	for k, v in pairs(t) do
		str = str..'"'..v..'",'
	end
	return str:sub(1, #str - 1)..']'
end

local sections = {'main', 'extra', 'joke', 'hidden'}
local inTheCategory = true
local curCategory, curSong, curDiff = 1, 1, configs.curDiff
local cagX, cagY = 10, 60
local songTxtX, songTxtY = 10, 300

function onCreate()
	luaDebugMode = true

	addHaxeLibrary("MainMenuState", version >= '0.7' and 'state' or '')
	if version >= '0.7' then
		addHaxeLibrary("Difficulty", 'backend')
	else
		addHaxeLibrary("CoolUtil")
	end
	runHaxeCode([[
		if (MainMenuState.psychEngineVersion >= '0.7') {
			Difficulty.copyFrom(]]..tableToHxArr(configs.diff)..[[);
		} else {
			CoolUtil.difficulties = ]]..tableToHxArr(configs.diff)..[[;
		}
	]])
	
	makeLuaSprite('bg', configs.bgImage, 0, 0)
	setObjectCamera('bg', 'camOther')
	addLuaSprite('bg')
	
	precacheMusic(configs.music)
	precacheSound("scrollMenu")
	precacheSound("cancelMenu")
	precacheSound("confirmMenu")

	playMusic(configs.music, 1, true)

	loadCategory()
end

function onStartCountdown()
	return Function_Stop
end

function onUpdatePost(elapsed)
	local up, down = (keyboardJustPressed('W') or keyboardJustPressed('UP')), (keyboardJustPressed('S') or keyboardJustPressed('DOWN'))
	local left, right = (keyboardJustPressed('A') or keyboardJustPressed('LEFT')), (keyboardJustPressed('D') or keyboardJustPressed('RIGHT'))
	if up then
		changeSel(-1)
	end
	if down then
		changeSel(1)
	end
	if inTheCategory then
		if keyboardJustPressed('ESCAPE') or keyboardJustPressed('BACKSPACE') then
			exitSong()
		end
		if keyboardJustPressed('ENTER') then
			inTheCategory = false
			for i, v in ipairs(sections) do
				removeLuaSprite('cag_'..v)
			end
			playSound("confirmMenu", 1)
			loadFreeplay()
		end
	else
		if keyboardJustPressed('ESCAPE') or keyboardJustPressed('BACKSPACE') then
			inTheCategory = true
			if configs.songs[curCategory] then
				for i, v in ipairs(configs.songs[curCategory]) do
					if stringTrim(configs.font:lower()) == 'alphabet' then
						runHaxeCode([[
							game.variables.remove('song_' + "]]..i..[[");
						]])
					else
						removeLuaText('song_'..i)
					end
					removeIcon('song_'..i)
				end
			end
			removeLuaText('diff')
			setProperty('bg.color', -1)
			cancelTween("bgColorTween")
			curSong = 1
			playSound("cancelMenu", 1)
			loadCategory()
		end
		if keyboardJustPressed('ENTER') then
			loadSong(configs.songs[curCategory][curSong][1], curDiff - 1)
		end
		if left then
			curDiff = mathEx:warp(curDiff - 1, 1, #configs.diff)
			setTextString('diff', configs.diff[curDiff]:upper())
			--debugPrint('curDiff: '..curDiff)
		end
		if right then
			curDiff = mathEx:warp(curDiff + 1, 1, #configs.diff)
			setTextString('diff', configs.diff[curDiff]:upper())
			--debugPrint('curDiff: '..curDiff)
		end
	end
	if keyboardJustPressed('R') then
		loadSong('freeplay')
	end
end

function loadFreeplay()
	if inTheCategory then return end
	if not configs.songs[curCategory] then return end
	local songTxtYY = songTxtY
	for i, v in ipairs(configs.songs[curCategory]) do
		makeText('song_'..i, v[1], 0, songTxtX, songTxtYY, 80, 'other', 'FFFFFF', configs.font, 'left', 4)
		setProperty('song_'..i..'.alpha', 0.5)
		makeIcon('song_'..i, v[2], songTxtX + (#v[1] * 47), songTxtYY - 50)
		songTxtYY = songTxtYY + 140
		makeText('diff', configs.diff[curDiff]:upper(), screenWidth, screenWidth - 750, screenHeight - 720, 30, 'other', 'FFFFFF', configs.font, 'center', 2)
	end
	changeSel(0)
end

function loadCategory()
	if not inTheCategory then return end
	local cagYY = cagY
	for _, v in ipairs(sections) do
		local cagSpr = 'cag_'..v
		makeSprite(cagSpr, nil, cagX, cagYY, false, 'camOther')
		loadFrames(cagSpr, 'main_extra_joke_hidden')
		addAnimationByPrefix(cagSpr, v..'_ready', v..' basic instance ', 24, true)
		addAnimationByPrefix(cagSpr, v..'_sel', v..' white instance ', 24, true)
		playAnim(cagSpr, v..'_ready')
		cagYY = cagYY + 160
	end
	changeSel(0)
end

function changeSel(v)
	if inTheCategory then
		local curCategoryBefore = curCategory
		curCategory = mathEx:warp(curCategory + v, 1, #sections)
		playAnim('cag_'..sections[curCategory], sections[curCategory]..'_sel')
		if curCategoryBefore < curCategory or curCategoryBefore > curCategory then
			playAnim('cag_'..sections[curCategoryBefore], sections[curCategoryBefore]..'_ready')
		end
		--debugPrint('curCategory: '..curCategory)
	else
		local curSongBefore = curSong
		curSong = mathEx:warp(curSong + v, 1, #configs.songs[curCategory])
		setProperty('song_'..curSong..'.alpha', 1)
		if curSongBefore < curSong or curSongBefore > curSong then
			setProperty('song_'..curSongBefore..'.alpha', 0.5)
		end
		for i = 1, #configs.songs[curCategory] do
			doTweenY('moveSongTxt'..i, 'song_'..i, getProperty('song_'..i..'.y') - (140 * v), 0.2, 'quadInOut')
			doTweenY('moveIconSong'..i, 'icon_song_'..i, getProperty('icon_song_'..i..'.y') - (140 * v), 0.2, 'quadInOut')
		end
		doTweenColor("bgColorTween", "bg", configs.songs[curCategory][curSong][3]:upper(), 0.5)
		--debugPrint('curSong: '..curSong)
	end
	playSound("scrollMenu", 1)
end