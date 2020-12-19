local function kernel(...)
	_G.sPhone = {
		version = "Beta 1.2.2",
		user = "Guest",
		devMode = false,
		mainTerm = term.current(),
		safeMode = false,
	}
	
	if safemode then
		sPhone.safeMode = true
		safemode = nil
	end
	
	sPhone.defaultApps = {
		["home"] = "sphone.home",
	}
	
	sPhone.theme = { --Default colors
		["header"] = colors.blue,
		["headerText"] = colors.white,
		["text"] = colors.black,
		["background"] = "",
		["backgroundColor"] = colors.white,
		["window.background"] = colors.lightBlue,
		["window.side"] = colors.blue,
		["window.button"] = colors.lightBlue,
		["window.text"] = colors.white,
		["lock.background"] = colors.white,
		["lock.text"] = colors.black,
		["lock.inputBackground"] = colors.white,
		["lock.inputText"] = colors.black,
		["lock.inputSide"] = colors.lightBlue,
		["lock.error"] = colors.red,
	}
	
	sPhone.defaultTheme = sPhone.theme
	
	if not fs.exists("/.sPhone/apis") then
		fs.makeDir("/.sPhone/apis")
	end
	
	for k, v in pairs(fs.list("/.sPhone/apis")) do
		if not fs.isDir("/.sPhone/apis/"..v) then
			os.loadAPI("/.sPhone/apis/"..v)
		end
	end
	
	if not config.write("/.sPhone/config/sPhone","configVersion",1) then
		config.convert("/.sPhone/config/sPhone")
		config.write("/.sPhone/config/sPhone","configVersion",1)
	end
	
	if not fs.exists("/.sPhone/system") then
		fs.makeDir("/.sPhone/system")
	end
	
	for k, v in pairs(fs.list("/.sPhone/system")) do
		if not fs.isDir("/.sPhone/system/"..v) then
			dofile("/.sPhone/system/"..v)
		end
	end

	local sPath = shell.path()
	sPath = sPath..":/bin"
	shell.setPath(sPath)
	
	if not fs.exists("/.sPhone/autorun") then
		fs.makeDir("/.sPhone/autorun")
	end
	
	term.setBackgroundColor(colors.white)
	term.clear()
	term.setCursorPos(1,1)
	for k, v in pairs(fs.list("/.sPhone/autorun")) do
		term.setTextColor(colors.black)
		if not fs.isDir("/.sPhone/autorun/"..v) then
			if not sPhone.safeMode then
				local f = fs.open("/.sPhone/autorun/"..v,"r")
				local script = f.readAll()
				f.close()
				print("Loading script "..v)
				local ok, err = pcall(function() setfenv(loadstring(script),getfenv())() end)
				if not ok then
					term.setTextColor(colors.red)
					print("Script error: "..v..": "..err)
					fs.move("/.sPhone/autorun/"..v, "/.sPhone/autorun/disabled/"..v)
					term.setTextColor(colors.blue)
					print(v.." disabled to prevent errors")
				end
			else
				print("Script "..v.." not loaded because Safe Mode")
			end
		end
	end
	
	if config.read("/.sPhone/config/sPhone","username") then
		sPhone.user = config.read("/.sPhone/config/sPhone","username")
	end
	
	if not fs.exists("/.sPhone/config/sPhone") then
		config.write("/.sPhone/config/sPhone","devMode",false)
	end
	
	sPhone.devMode = config.read("/.sPhone/config/sPhone","devMode")
	
	if sPhone.devMode then
		sPhone.crash = crash
	end
	
	crash = nil
	
	function os.version()
		return "sPhone "..sPhone.version
	end
	
	function sPhone.getSize()
		return term.getSize()
	end
	
	local fileTheme = "/.sPhone/config/theme"
	if fs.exists(fileTheme) then
		sPhone.theme["header"] = (config.read(fileTheme, "header") or sPhone.theme["header"])
		sPhone.theme["headerText"] = (config.read(fileTheme, "headerText") or sPhone.theme["headerText"])
		sPhone.theme["text"] = (config.read(fileTheme, "text") or sPhone.theme["text"]) 
		sPhone.theme["background"] = (config.read(fileTheme, "background") or sPhone.theme["background"])
		sPhone.theme["backgroundColor"] = (config.read(fileTheme, "backgroundColor") or sPhone.theme["backgroundColor"])
		sPhone.theme["window.background"] = (config.read(fileTheme, "window.background") or sPhone.theme["window.background"])
		sPhone.theme["window.side"] = (config.read(fileTheme, "window.side") or sPhone.theme["window.side"])
		sPhone.theme["window.button"] = (config.read(fileTheme, "window.button") or sPhone.theme["window.button"])
		sPhone.theme["window.text"] = (config.read(fileTheme, "window.text") or sPhone.theme["window.text"])
		sPhone.theme["lock.background"] = (config.read(fileTheme, "lock.background") or sPhone.theme["lock.background"])
		sPhone.theme["lock.text"] = (config.read(fileTheme, "lock.text") or sPhone.theme["lock.text"])
		sPhone.theme["lock.inputBackground"] = (config.read(fileTheme, "lock.inputBackground") or sPhone.theme["lock.inputBackground"])
		sPhone.theme["lock.inputText"] = (config.read(fileTheme, "lock.inputText") or sPhone.theme["lock.inputText"])
		sPhone.theme["lock.inputSide"] = (config.read(fileTheme, "lock.inputSide") or sPhone.theme["lock.inputSide"])
		sPhone.theme["lock.error"] = (config.read(fileTheme, "lock.error") or sPhone.theme["lock.error"])
	else
		for k, v in pairs(sPhone.theme) do
			config.write(fileTheme, k, v)
		end
	end
	
	function sPhone.applyTheme(id, value)
		if not value or not id then
			error("bad arguement: double expected, got nil",2)
		end
		sPhone.theme[id] = value
		config.write(fileTheme, id, value)
	end
	
	function sPhone.getTheme(id)
		if not id then
			error("bad arguement: double expected, got nil",2)
		end
		local n = config.read(fileTheme, id)
		if n then
			return n
		end
		return sPhone.defaultTheme[id]
	end
	
	function sPhone.setDefaultApp(app, path)
		if not path then
			error("got nil",2)
		end
		
		sPhone.defaultApps[app] = path
		config.write("/.sPhone/config/defaultApps",app,path)
	end
	
	function sPhone.getDefaultApp(app)
		if not app then
			error("got nil",2)
		end
		
		local n = config.read("/.sPhone/config/defaultApps",app)
		return n
	end
	
	if not fs.exists("/.sPhone/config/defaultApps") then
		sPhone.setDefaultApp("home","sphone.home")
	end
	
	function string.getExtension(name)
		local ext = ""
		local exten = false
		name = string.reverse(name)
		for i = 1, #name do
			local s = string.sub(name,i,i)
			if s == "." then
				ch = i - 1
				exten = true
				break
			end
		end
		if exten then
			ext = string.sub(name, 1, ch)
			return string.reverse(ext)
		else
			return nil
		end
	end
	
	function sPhone.list(path, opt)
		opt = opt or {}
		opt.bg1 = opt.bg1 or sPhone.getTheme("backgroundColor")
		opt.fg1 = opt.fg1 or sPhone.getTheme("text")
		opt.fg1b = opt.fg1b or colors.lime
		opt.bg2 = opt.bg2 or sPhone.getTheme("header")
		opt.fg2 = opt.fg2 or sPhone.getTheme("headerText")
		opt.bg3 = opt.bg3 or sPhone.getTheme("header")
		opt.fg3 = opt.fg3 or sPhone.getTheme("headerText")
		opt.output = opt.output or true
		opt.list = opt.list or false
		opt.pairs = opt.pairs or false
		opt.title = opt.title or false
		if not path then
			path = ""
		end
		if not fs.isDir(path) and not opt.list then
			error("Invalid path")
		end
		local scroll = 0
		local items
		local cho = {}
		local w, h
		local function rebuild()
			local files, dirs = {}, {}
			items = {}
			local flist
			if not opt.list then
				flist = fs.list(path)
			else
				flist = opt.list
			end
			
			local function pair(tab)
				if opt.pairs then
					return pairs(tab)
				end
				return ipairs(tab)
			end
			
			for i, v in pair(flist) do
				if fs.isDir(fs.combine(path, v)) then
					table.insert(dirs, v)
				else
					table.insert(files, v)
				end
			end
			table.sort(files)
			table.sort(dirs)
			for i, v in pair(dirs) do
				table.insert(items, v)
			end
			for i, v in pair(files) do
				table.insert(items, v)
			end
			
			if opt.pairs then
				for k, v in pairs(flist) do
					cho[v] = k
				end
			end
			scroll = 0
		end
		rebuild()
		local setVisible = term.current().setVisible
			or function()end
		local function redraw()
			w, h = term.getSize()
			setVisible(false)
			term.setBackgroundColor(opt.bg1)
			term.clear()
			for i = scroll + 1, h + scroll - 1 do
				local str = items[i]
				if str then
					term.setCursorPos(2, 1 + i - scroll)
					local isDir
					 if not opt.pairs then
						isDir = fs.isDir(fs.combine(path, str))
					 else
						 isDir = false
					 end
					term.setTextColor(isDir and opt.fg1b or opt.fg1)
					local _w = w - (isDir and 2 or 1)
					if #str > _w then
						str = str:sub(1, _w - 2) .. ".."
					end
					if isDir then
						str = str .. "/"
					end
					term.write(str)
				end
			end
			term.setBackgroundColor(opt.bg2)
			term.setTextColor(opt.fg2)
			term.setCursorPos(1, 1)
			term.clearLine()
			local _path = path .. "/"
			if #_path > w - 2 then
				_path = ".." .. _path:sub(-w + 4)
			end
			if opt.title then
				_path = opt.title
			end
			term.write(_path)
			term.setBackgroundColor(opt.bg3)
			term.setTextColor(opt.fg3)
			term.setCursorPos(w, 1)
			term.write("X")
			term.setCursorPos(w, 2)
			term.write("^")
			term.setCursorPos(w, h)
			term.write("v")
			setVisible(true)
		end
		while true do
			redraw()
			local ev = {os.pullEventRaw()}
			if ev[1] == "terminate" then
				return nil
			elseif ev[1] == "mouse_scroll" and ev[4] > 1 then
				scroll = scroll + ev[2]
			elseif ev[1] == "mouse_click" then
				if ev[3] == w and ev[2] == 1 then
					if ev[4] == 1 then
						return nil
					elseif ev[4] == 2 then
						scroll = scroll - 1
					elseif ev[4] == h then
						scroll = scroll + 1
					end
				elseif ev[3] < w and ev[4] == 1 and ev[2] == 1 then
					path = fs.getDir(path)
					if path == ".." then
						path = ""
					end
					rebuild()
				elseif ev[3] < w and ev[4] > 1 then
					local item = items[ev[4] + scroll - 1]
					if item then
						local fullPath = fs.combine(path, item)
						if fs.isDir(fullPath) then
							path = fullPath
							rebuild()
						else
							if opt.output then
								if opt.pairs then
									return cho[fullPath], fullPath, ev[2]
								end
								return fullPath, ev[2]
							end
						end
					end
				end
			end
			scroll = math.min(math.max(0, scroll), math.max(0, #items - h + 1))
		end
	end
	
	function sPhone.read( _sReplaceChar, _tHistory, _fnComplete, _MouseEvent, _presetInput )
    term.setCursorBlink( true )

    local sLine = _presetInput
		
		if type(sLine) ~= "string" then
			sLine = ""
		end
		local nPos = #sLine
    local nHistoryPos
		local _MouseX
		local _MouseY
		local param
		local sEvent
		local usedMouse = false
    if _sReplaceChar then
        _sReplaceChar = string.sub( _sReplaceChar, 1, 1 )
    end

    local tCompletions
    local nCompletion
    local function recomplete()
        if _fnComplete and nPos == string.len(sLine) then
            tCompletions = _fnComplete( sLine )
            if tCompletions and #tCompletions > 0 then
                nCompletion = 1
            else
                nCompletion = nil
            end
        else
            tCompletions = nil
            nCompletion = nil
        end
    end

    local function uncomplete()
        tCompletions = nil
        nCompletion = nil
    end

    local w = term.getSize()
    local sx = term.getCursorPos()

    local function redraw( _bClear )
        local nScroll = 0
        if sx + nPos >= w then
            nScroll = (sx + nPos) - w
        end

        local cx,cy = term.getCursorPos()
        term.setCursorPos( sx, cy )
        local sReplace = (_bClear and " ") or _sReplaceChar
        if sReplace then
            term.write( string.rep( sReplace, math.max( string.len(sLine) - nScroll, 0 ) ) )
        else
            term.write( string.sub( sLine, nScroll + 1 ) )
        end

        if nCompletion then
            local sCompletion = tCompletions[ nCompletion ]
            local oldText, oldBg
            if not _bClear then
                oldText = term.getTextColor()
                oldBg = term.getBackgroundColor()
                term.setTextColor( colors.white )
                term.setBackgroundColor( colors.gray )
            end
            if sReplace then
                term.write( string.rep( sReplace, string.len( sCompletion ) ) )
            else
                term.write( sCompletion )
            end
            if not _bClear then
                term.setTextColor( oldText )
                term.setBackgroundColor( oldBg )
            end
        end

        term.setCursorPos( sx + nPos - nScroll, cy )
    end
    
    local function clear()
        redraw( true )
    end

    recomplete()
    redraw()

    local function acceptCompletion()
        if nCompletion then
            -- Clear
            clear()

            -- Find the common prefix of all the other suggestions which start with the same letter as the current one
            local sCompletion = tCompletions[ nCompletion ]
            sLine = sLine .. sCompletion
            nPos = string.len( sLine )

            -- Redraw
            recomplete()
            redraw()
        end
    end
    while true do
        sEvent, param,_MouseX,_MouseY = os.pullEvent()
        if sEvent == "char" then
            -- Typed key
            clear()
            sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
            nPos = nPos + 1
            recomplete()
            redraw()

        elseif sEvent == "paste" then
            -- Pasted text
            clear()
            sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
            nPos = nPos + string.len( param )
            recomplete()
            redraw()

        elseif sEvent == "key" then
            if param == keys.enter then
                -- Enter
                if nCompletion then
                    clear()
                    uncomplete()
                    redraw()
                end
                break
                
            elseif param == keys.left then
                -- Left
                if nPos > 0 then
                    clear()
                    nPos = nPos - 1
                    recomplete()
                    redraw()
                end
                
            elseif param == keys.right then
                -- Right                
                if nPos < string.len(sLine) then
                    -- Move right
                    clear()
                    nPos = nPos + 1
                    recomplete()
                    redraw()
                else
                    -- Accept autocomplete
                    acceptCompletion()
                end

            elseif param == keys.up or param == keys.down then
                -- Up or down
                if nCompletion then
                    -- Cycle completions
                    clear()
                    if param == keys.up then
                        nCompletion = nCompletion - 1
                        if nCompletion < 1 then
                            nCompletion = #tCompletions
                        end
                    elseif param == keys.down then
                        nCompletion = nCompletion + 1
                        if nCompletion > #tCompletions then
                            nCompletion = 1
                        end
                    end
                    redraw()

                elseif _tHistory then
                    -- Cycle history
                    clear()
                    if param == keys.up then
                        -- Up
                        if nHistoryPos == nil then
                            if #_tHistory > 0 then
                                nHistoryPos = #_tHistory
                            end
                        elseif nHistoryPos > 1 then
                            nHistoryPos = nHistoryPos - 1
                        end
                    else
                        -- Down
                        if nHistoryPos == #_tHistory then
                            nHistoryPos = nil
                        elseif nHistoryPos ~= nil then
                            nHistoryPos = nHistoryPos + 1
                        end                        
                    end
                    if nHistoryPos then
                        sLine = _tHistory[nHistoryPos]
                        nPos = string.len( sLine ) 
                    else
                        sLine = ""
                        nPos = 0
                    end
                    uncomplete()
                    redraw()

                end

            elseif param == keys.backspace then
                -- Backspace
                if nPos > 0 then
                    clear()
                    sLine = string.sub( sLine, 1, nPos - 1 ) .. string.sub( sLine, nPos + 1 )
                    nPos = nPos - 1
                    recomplete()
                    redraw()
                end

            elseif param == keys.home then
                -- Home
                if nPos > 0 then
                    clear()
                    nPos = 0
                    recomplete()
                    redraw()
                end

            elseif param == keys.delete then
                -- Delete
                if nPos < string.len(sLine) then
                    clear()
                    sLine = string.sub( sLine, 1, nPos ) .. string.sub( sLine, nPos + 2 )                
                    recomplete()
                    redraw()
                end

            elseif param == keys["end"] then
                -- End
                if nPos < string.len(sLine ) then
                    clear()
                    nPos = string.len(sLine)
                    recomplete()
                    redraw()
                end

            elseif param == keys.tab then
                -- Tab (accept autocomplete)
                acceptCompletion()

            end

        elseif sEvent == "term_resize" then
            -- Terminal resized
            w = term.getSize()
            redraw()
				
				elseif sEvent == "mouse_click" and _MouseEvent then
					if nCompletion then
            clear()
            uncomplete()
            redraw()
          end
					usedMouse = true
					break
        end
    end

    local cx, cy = term.getCursorPos()
    term.setCursorBlink( false )
    term.setCursorPos( w + 1, cy )
    print()
		if sEvent == "mouse_click" then
			return sLine, param, _MouseX, _MouseY
		end
    return sLine
	end
	
	local function clear()
		term.setBackgroundColor(sPhone.theme["backgroundColor"])
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(sPhone.theme["text"])
	end
	
	sPhone.forceShutdown = os.shutdown
	sPhone.forceReboot = os.reboot
	
	function os.shutdown()
		local w, h = term.getSize()
		local text = "Shutting down"
		local x = math.ceil(w/2)-math.ceil(#text/2)+1
		local y = math.ceil(h/2)
		sPhone.inHome = false
		os.pullEvent = os.pullEventRaw
		local function printMsg(color)
			term.setBackgroundColor(color)
			term.setTextColor(colors.white)
			term.clear()
			term.setCursorPos(x,y)
			print(text)
			sleep(0.1)
		end
		printMsg(colors.white)
		printMsg(colors.lightGray)
		printMsg(colors.gray)
		printMsg(colors.black)
		sleep(0.6)
		sPhone.forceShutdown()
	end
	
	function os.reboot()
		local w, h = term.getSize()
		local text = "Rebooting"
		local x = math.ceil(w/2)-math.ceil(#text/2)+1
		local y = math.ceil(h/2)
		sPhone.inHome = false
		os.pullEvent = os.pullEventRaw
		local function printMsg(color)
			term.setBackgroundColor(color)
			term.setTextColor(colors.white)
			term.clear()
			term.setCursorPos(x,y)
			print(text)
			sleep(0.1)
		end
		printMsg(colors.white)
		printMsg(colors.lightGray)
		printMsg(colors.gray)
		printMsg(colors.black)
		sleep(0.6)
		sPhone.forceReboot()
	end
  
  function sPhone.header(title, butt)
		
		if not title then
			title = "sPhone"
		end

		local w, h = term.getSize()
		paintutils.drawLine(1,1,w,1, sPhone.theme["header"])
		term.setTextColor(sPhone.theme["headerText"])
		term.setCursorPos(1,1)
		write(" "..title)
		term.setCursorPos(w,1)
		if butt then
			write(butt)
		end
		term.setBackgroundColor(sPhone.theme["backgroundColor"])
		term.setTextColor(sPhone.theme["text"])
		term.setCursorPos(1,3)
  end
  
  function sPhone.menu(items, title, closeButton)
    local function cprint(text)
      if type(text) ~= 'table' then
        text = {text}
      end
	
      local w, h = term.getSize()
	
      for i=1,#text do
        local x, y = term.getCursorPos()
        term.setCursorPos(math.floor(w/2)-math.floor(text[i]:len()/2), y)
        print(text[i])
      end
    end
    local function clear()
      term.clear()
      term.setCursorPos(1, 1)
    end
	
    local termWidth, termHeight = term.getSize()
    local drawSize = termHeight - 2
	
    local function maxPages()
    local itemCount = #items
    local pageCount = 0
		while itemCount > 0 do
			itemCount = itemCount - drawSize
			pageCount = pageCount + 1
		end
		return pageCount
	end
	
	local function iif(cond, trueval, falseval)
		if cond then
			return trueval
		else
			return falseval
		end
	end
	
	local function pagedItems()
		local ret = {}
		for i = 1, maxPages() do
			local tmp = {}
			local nElements = 0
			for j = drawSize*(i-1)+1, iif(drawSize*(i+1) > #items, #items, drawSize*(i+1)) do
				if nElements < drawSize then
					table.insert(tmp, items[j])
					nElements = nElements + 1
				end
			end
			table.insert(ret, tmp)
		end
		return ret
	end
	
	local selected = 1
	if start then
		selected = start
	end
	local page = 1
	
	local function redraw()
		term.setBackgroundColor(sPhone.theme["backgroundColor"])
		term.setTextColor(sPhone.theme["text"])
		term.clear()
    term.setCursorPos(1,1)
		if not title then
			title = ""
		end
		sPhone.header(title,closeButton)
		term.setCursorPos(1,3)
		if moreTitle then
			head = moreTitle
		else
			head = {}
			if not allowNil or allowNil == true then
				--head[3] = 'Terminate to cancel.'
			end
		end
		for i=1,#head do
			print(head[i])
		end
		if maxPages() > 1 then
			pages = "<- (page "..page.." of "..maxPages()..") ->"
			print(pages)
		end
		for i = 1, #pagedItems()[page] do
			if selected == drawSize*(page-1)+i then
				term.setBackgroundColor(sPhone.theme["backgroundColor"])
				term.setTextColor(sPhone.theme["text"])
			else
				term.setBackgroundColor(sPhone.theme["backgroundColor"])
				term.setTextColor(sPhone.theme["text"])
			end
			term.clearLine()
			cprint(iif(selected == drawSize*(page-1)+i,"","").." "..pagedItems()[page][i])
			term.setBackgroundColor(sPhone.theme["backgroundColor"])
			term.setTextColor(sPhone.theme["text"])
		end
	end

	local function changePage(pW)
		if pW == 1 and page < maxPages() then
			page = page + 1
			if selected + drawSize > #items then
				selected = #items
			else
				selected = selected + drawSize
			end
		elseif pW == -1 and page > 1 then
			page = page - 1
			if selected - drawSize < 1 then
				selected = 1
			else
				selected = selected - drawSize
			end
		end
	end
	
	redraw()
	while true do
		local eventData = {os.pullEventRaw()}
		if eventData[1] == 'mouse_click' then
			if eventData[4] == 1 and eventData[3] == termWidth then
				return false, 0
			elseif eventData[4] > 2 then
				clear()
				selected = (eventData[4]-3+((page-1)*drawSize))+1
				if selected then
					return items[selected], selected
				end
			end
		end
	end
end
	
	function sPhone.yesNo(title, desc, hideUser)
		term.setCursorBlink(false)
		term.setBackgroundColor(sPhone.theme["backgroundColor"])
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(sPhone.theme["text"])
		local w, h = term.getSize()
		paintutils.drawLine(1,1,w,1, sPhone.theme["header"])
		term.setTextColor(sPhone.theme["headerText"])
		term.setCursorPos(1,1)
		if not hideUser then
			if not sPhone.user then
				write(" sPhone")
			else
				write(" "..sPhone.user)
			end
		end
		term.setCursorPos(1,3)
		term.setBackgroundColor(sPhone.theme["backgroundColor"])
		term.setTextColor(sPhone.theme["text"])
		visum.align("center", "  "..title, false, 3)
		if desc then
			term.setCursorPos(2,6)
			print(desc)
		end
		paintutils.drawFilledBox(3, 16, 9, 18, colors.green)
		paintutils.drawFilledBox(18, 16, 24, 18, colors.red)
		term.setTextColor(colors.white)
		term.setCursorPos(5,17)
		term.setBackgroundColor(colors.green)
		write("Yes")
		term.setCursorPos(20,17)
		term.setBackgroundColor(colors.red)
		write("No")
		while true do
			local _,_,x,y = os.pullEvent("mouse_click")
			if (x > 2 and y > 15) and (x < 10 and y < 19) then
				return true
			elseif (x > 17 and y > 15) and (x < 25 and y < 19) then
				return false
			end
		end
	end
	
	function sPhone.winOk(fmessage, smessage, bg, side, text, button)
		if not fmessage then
			fmessage = ""
		end
		if not smessage then
			smessage = ""
		end
		if not bg then
			bg = sPhone.theme["window.background"]
		end
		if not text then
			text = sPhone.theme["window.text"]
		end
		if not button then
			button = sPhone.theme["window.button"]
		end
		if not side then
			side = sPhone.theme["window.side"]
		end
		term.setCursorBlink(false)
		if #fmessage >= #smessage then
			local w, h = term.getSize
			term.setBackgroundColor(side)
			paintutils.drawBox(12 - math.ceil(#fmessage / 2), 5, 15 + math.ceil(#fmessage / 2), 10, side)
			term.setBackgroundColor(bg)
			paintutils.drawFilledBox(13 - math.ceil(#fmessage / 2), 6, 14 + math.ceil(#fmessage / 2), 9, bg)
			term.setCursorPos(14 - math.ceil(#fmessage / 2), 7)
			term.setTextColor(text)
			write(fmessage)
			term.setCursorPos(14 - math.ceil(#smessage / 2), 8)
			write(smessage)
		else
			local w, h = term.getSize
			term.setBackgroundColor(side)
			paintutils.drawBox(12 - math.ceil(#smessage / 2), 5, 15 + math.ceil(#smessage / 2), 10, side)
			term.setBackgroundColor(bg)
			paintutils.drawFilledBox(13 - math.ceil(#smessage / 2), 6, 14 + math.ceil(#smessage / 2), 9, bg)
			term.setCursorPos(14 - math.ceil(#fmessage / 2), 7)
			term.setTextColor(text)
			write(fmessage)
			term.setCursorPos(14 - math.ceil(#smessage / 2), 8)
			write(smessage)
		end
		term.setCursorPos(13,10)
		term.setBackgroundColor(button)
		write("Ok")
		while true do
			local e, k, x,y = os.pullEvent()
			if e == "mouse_click" then
				if y == 10 then
					if x == 13 or x == 14 then
						return
					end
				end
			elseif e == "key" then
				if k == 28 then
					return
				end
			end
		end
	end
	
	function sPhone.colorPicker(message, old) -- From Impulse
		local current = math.log(old) / math.log(2)
		-- first line is already code wizardry
		local function redraw()
			term.setBackgroundColour(sPhone.theme["backgroundColor"])
			term.clear()
			sPhone.header(message)
			term.setCursorPos(2,5)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.lime)
			write(" Ok ")
			term.setCursorPos(7,5)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.red)
			write(" Cancel ")
			term.setTextColor(colors.black)
			term.setCursorPos(2, 3)
			for i = 0, 15 do
				term.setBackgroundColour(2^i)
				term.write(i == current and "#" or ":")
			end
		end
		while true do
			redraw()
			local ev = {os.pullEvent()}
			if ev[1] == "key" and ev[2] == keys.enter then
				return 2^current
			elseif ev[1] == "mouse_click" then
				if ev[4] == 3 and ev[3] >= 2 and ev[3] <= 17 then
					current = ev[3] - 2 % 16
				elseif ev[4] == 5 and ev[3] >= 2 and ev[3] <= 6 then
					return 2^current
				elseif ev[4] == 5 and ev[3] >= 7 and ev[3] <= 14 then
					return old
				end
			end
		end
	end
	
	sPhone.colourPicker = sPhone.colorPicker -- For UK
	
	function sPhone.install(spk)
		if not fs.exists("/.sPhone/config/spklist") then
			local f = fs.open("/.sPhone/config/spklist","w")
			f.write("{}")
			f.close()
		end
		if string.getExtension(spk) == "spk" then
			if fs.exists(spk) and not fs.isDir(spk) then
				local f = fs.open(spk,"r")
				local script = f.readAll()
				f.close()
				script = textutils.unserialize(script)
				if not script then
					error("spk corrupted",2)
				end
				
				local function writeFile(patha,contenta)
					local file = fs.open(patha,"w")
					file.write(contenta)
					file.close()
				end
				function writeDown(inputa,dira)
												for i,v in pairs(inputa) do
												if type(v) == "table" then
																writeDown(v,dira.."/"..i)
												elseif type(v) == "string" then
																writeFile(dira.."/"..i,v)
												end
								end
				end
				
				local _config = textutils.unserialize(script.config)
				if not _config.id then
					error("SPK: id not found",2)
				end
				if not _config.main then
					error("SPK: main not found",2)
				end
				writeDown(textutils.unserialize(script.files),"/.sPhone/apps/spk/".._config.id.."/files")
				local f = fs.open("/.sPhone/apps/spk/".._config.id.."/.spk","w")
				f.write(textutils.serialize(_config))
				f.close()
				local f = fs.open("/.sPhone/config/spklist","r")
				local lists = f.readAll()
				f.close()
				lists = textutils.unserialize(lists)
				if not lists then
					error("Cannot open config",2)
				end
				
				if not _config.name then
					_config.name = _config.id
				end
				
				lists[_config.id] = _config.name
				
				local f = fs.open("/.sPhone/config/spklist","w")
				f.write(textutils.serialize(lists))
				f.close()
				return true, _config.id
			else
				return false, "not a spk file"
			end
		else
			return false, "not a spk file"
		end
	end
	
	function sPhone.launch(spk)
		if not fs.exists("/.sPhone/config/spklist") then
			local f = fs.open("/.sPhone/config/spklist","w")
			f.write("{}")
			f.close()
		end
		local f = fs.open("/.sPhone/config/spklist","r")
		local lists = f.readAll()
		f.close()
		lists = textutils.unserialize(lists)
		if not lists then
			error("Cannot open config",2)
		end
		
		if not lists[spk] then
			return false, "not installed"
		end
		
		if not fs.exists("/.sPhone/apps/spk/"..spk.."/.spk") then
			return false, "Invalid SPK, .spk not found"
		end
		
		local f = fs.open("/.sPhone/apps/spk/"..spk.."/.spk","r")
		local script = f.readAll()
		f.close()
		_config = textutils.unserialize(script)
		if not script then
			return false, "config corrupted"
		end
		
		local result = {}
		local ok, err = pcall(function()
			result = {setfenv(loadfile(fs.combine("/.sPhone/apps/spk",_config.id.."/files/".._config.main)), setmetatable({
				spk = {
					getName = function()
						return (_config.name or nil)
					end,
					
					getID = function()
						return (_config.id or nil)
					end,
					
					getPath = function()
						return "/.sPhone/apps/spk/".._config.id
					end,
					
					getDataPath = function()
						return "/.sPhone/apps/spk/".._config.id.."/data"
					end,
					
					getAuthor = function()
						return (_config.author or nil)
					end,
					
					getVersion = function()
						return (_config.version or nil)
					end,
					
					getType = function()
						return (_config.type or nil)
					end,
					
					open = function(file, mode)
						return fs.open("/.sPhone/apps/spk/".._config.id.."/data/"..file,mode)
					end,
				},
				string = string,
				sPhone = sPhone,
			 }, {__index = getfenv()}))()}
		end)
		
		if not ok then
			return false, err
		end
		return true, result
	end
	
	local function home()
		sPhone.inHome = true
		local errorCount = 0
		local ok, err
		local homeID
		local homeSPKs = {
			"sphone.home",
		}
		while true do
			
			
			if not config.read("/.sPhone/config/spklist","sphone.home") then
				sPhone.install("/.sPhone/apps/home.spk")
			end
			os.pullEvent = os.oldPullEvent
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
			term.clear()
			term.setCursorPos(1,1)
			if errorCount >= 5 and errorCount < 10 then
				homeID = "sphone.home"
			elseif errorCount >= 10 then
				error("Cannot load home: "..err,0)
			else
				homeID = sPhone.getDefaultApp("home")
			end
			if not sPhone.safeMode then
				if not config.list("/.sPhone/config/spklist")[homeID] then
					homeID = "sphone.home"
				end
			else
				homeID = "sphone.home"
			end
			temp.set("homePID",task.add(function()
				ok,err = sPhone.launch(homeID)
			end))
			task.run()
			if not ok then
				errorCount = errorCount + 1
			end
			sleep(0)
			
		end
		sPhone.inHome = false
	end
	
	function login()
		if config.read("/.sPhone/config/sPhone","lockEnabled") == nil then
			config.write("/.sPhone/config/sPhone","lockEnabled",true)
		end
		local usingPW = config.read("/.sPhone/config/sPhone","lockEnabled")
		if not usingPW then
			local old = os.pullEvent
			os.pullEvent = os.pullEventRaw
			local fEvents = {
				["mouse_drag"] = true,
				["mouse_click"] = true,
				["key"] = false,
			}
			while true do
				local w,h = term.getSize()
				local clockS = textutils.formatTime(os.time(), not config.read("/.sPhone/config/sPhone","format12time"))
				term.setBackgroundColor(sPhone.theme["lock.background"])
				term.clear()
				term.setCursorPos(1,1)
				sPhone.header(sPhone.user)
				term.setBackgroundColor(sPhone.theme["lock.background"])
				term.setTextColor(sPhone.theme["lock.text"])
				term.setCursorPos(6,4)
				bigfont.bigPrint(clockS)
				visum.align("center"," Slide to unlock",false,h)
				local clockUpdate = os.startTimer(1)
				local e = {os.pullEvent()}
				if fEvents[e[1]] then
					os.pullEvent = old
					break					
				end
			end
			return
		end
		local old = os.pullEvent
		os.pullEvent = os.pullEventRaw
		sPhone.locked = true
		if config.read("/.sPhone/config/sPhone","password") then
			while true do
				term.setBackgroundColor(sPhone.theme["lock.background"])
				term.clear()
				term.setCursorPos(1,1)
				sPhone.header(sPhone.user)
				paintutils.drawBox(7,9,20,11,sPhone.theme["lock.inputSide"])
				if sPhone.wrongPassword then
					term.setTextColor(sPhone.theme["lock.error"])
					term.setBackgroundColor(sPhone.theme["lock.background"])
					visum.align("center","  Wrong Password",false,13)
				end
				term.setTextColor(sPhone.theme["lock.text"])
				term.setBackgroundColor(sPhone.theme["lock.background"])
				visum.align("center","  Insert Password",false,7)
        local loginTerm = window.create(term.native(), 8,10,12,1, true)
        term.redirect(loginTerm)
        term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(sPhone.theme["lock.inputText"])
				local passwordLogin = read("*")
        term.redirect(sPhone.mainTerm)
				local fpw = config.read("/.sPhone/config/sPhone","password")
				if sha256.sha256(passwordLogin) == fpw then
					sPhone.wrongPassword = false
					os.pullEvent = old
					return
				else
					sPhone.wrongPassword = true
				end
			end
		else
			local name
			local pw
			local pwr
			local rServer
			local password1,mouse,x,y
			local w, h = term.getSize()
			local skipped = false
			sPhone.firstBoot = true
			
			for k,v in ipairs(fs.list("/.sPhone/apps/system")) do
				sPhone.install("/.sPhone/apps/system/"..v)
			end
			
			while not skipped do
				
				term.setBackgroundColor(sPhone.theme["lock.background"])
				term.clear()
				term.setCursorPos(1,1)
				sPhone.header("Setup")
				paintutils.drawBox(7,9,20,11,sPhone.theme["lock.inputSide"])
				if sPhone.wrongPassword then
					term.setTextColor(sPhone.theme["lock.error"])
					term.setBackgroundColor(sPhone.theme["lock.background"])
					visum.align("center","  Wrong Password",false,13)
				end
				term.setTextColor(sPhone.theme["lock.text"])
				term.setBackgroundColor(sPhone.theme["lock.background"])
				visum.align("center","  Insert Password",false,7)
				local t = "Skip"
				term.setCursorPos(w-#t+1,h)
				write(t)
        local loginTerm = window.create(term.native(), 8,10,12,1, true)
        term.redirect(loginTerm)
        term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(sPhone.theme["lock.inputText"])
				while true do
					password1,mouse,x,y = sPhone.read("*",nil,nil,true)
					if mouse then
						if y == h and (x >= 23 and x <= w) then
							skipped = true
							config.write("/.sPhone/config/sPhone","lockEnabled",false)
							break
						end
					else
						break
					end
				end
				term.redirect(sPhone.mainTerm)
				if not skipped then
					term.setBackgroundColor(sPhone.theme["lock.background"])
					term.clear()
					term.setCursorPos(1,1)
					sPhone.header("Setup")
					paintutils.drawBox(7,9,20,11,sPhone.theme["lock.inputSide"])
					term.setTextColor(sPhone.theme["lock.text"])
					term.setBackgroundColor(sPhone.theme["lock.background"])
					visum.align("center","  Repeat",false,7)
					local loginTerm = window.create(term.native(), 8,10,12,1, true)
					term.redirect(loginTerm)
					term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
					term.clear()
					term.setCursorPos(1,1)
					term.setTextColor(sPhone.theme["lock.inputText"])
					local password2 = read("*")
					term.redirect(sPhone.mainTerm)
					if password1 == password2 then
						config.write("/.sPhone/config/sPhone", "password",sha256.sha256(password1))
						term.setTextColor(colors.lime)
						visum.align("center","  Password set!",false,13)
						sleep(2)
						break
					else
						sPhone.wrongPassword = true
					end
				end
			end
			
			local name
			
			term.setBackgroundColor(sPhone.theme["backgroundColor"])
			term.clear()
			sPhone.header("Setup")
			term.setCursorPos(1,1)
			term.setTextColor(sPhone.theme["text"])
			term.setCursorPos(2,3)
			visum.align("center","Username",false,3)
			term.setCursorPos(2,5)
			local newUsername = read()
			config.write("/.sPhone/config/sPhone","username",newUsername)
			
			if fs.exists("/.sPhone/config/sPhone") then
				name = config.read("/.sPhone/config/sPhone","username")
			else
				name = "Guest"
			end
			config.write("/.sPhone/config/sPhone","showUpdate",true)
			term.setBackgroundColor(sPhone.theme["backgroundColor"])
			term.clear()
			sPhone.header("Setup")
			term.setCursorPos(1,1)
			term.setTextColor(sPhone.theme["text"])
			sPhone.user = name
			os.setComputerLabel(sPhone.user.."'s sPhone")
			visum.align("center","  All Set!",false,3)
			visum.align("center","  Have fun with sPhone",false,5)
			sleep(2)
			sPhone.locked = false
			sPhone.inHome = true
			sPhone.firstBoot = false
			os.pullEvent = old
			return
		end
	end

	sPhone.lock = login
	sPhone.login = login
	local showUpdate = config.read("/.sPhone/config/sPhone","showUpdate")

	http.request("https://raw.githubusercontent.com/SertexTeam/sPhone/master/src/version")
	local newVersion
	local timeout = os.startTimer(2)
	while true do
		local event,url, sourceText = os.pullEvent()
		if event == "http_success" then
			newVersion = sourceText.readLine()
			sourceText.close()
			break
		elseif event == "http_failure" then
			newVersion = sPhone.version
			break
		end
	end
	
	if newVersion ~= sPhone.version and showUpdate then
		sPhone.newUpdate = true
	else
		sPhone.newUpdate = false
	end
	
	if config.read("/.sPhone/config/sPhone","updated") then
		for k,v in pairs(fs.list("/.sPhone/apps/system")) do
			sPhone.install("/.sPhone/apps/system/"..v)
		end
		config.write("/.sPhone/config/sPhone","updated",false)
	end
	
	if config.read("/.sPhone/config/sPhone","showUpdate") == nil then
		config.write("/.sPhone/config/sPhone","showUpdate", true)
	end
	
	login()
	if sPhone.newUpdate then
		sPhone.winOk("New Update:",newVersion)
	end
	home()

end
if not sPhone then
	kernel({...})
else
	print("sPhone already started")
end
