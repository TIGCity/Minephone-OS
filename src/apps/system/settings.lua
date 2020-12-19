local pwChange,mouse,x,y
local pwChangeRep
local skipped = false
local w,h = term.getSize()
local password

local menu = {
	"Update",
	"Edit Theme",
	"Change Username",
	"Change Password",
	"Set Label",
	"Clear Label",
	"Default Apps",
}

local function clear()
	term.setBackgroundColor(sPhone.theme["backgroundColor"])
	term.setTextColor(sPhone.theme["text"])
	term.clear()
	term.setCursorPos(1,1)
end

local function changeUsername()
	local newUsername = sPhone.user
	term.setBackgroundColor(sPhone.theme["backgroundColor"])
	term.clear()
	term.setCursorPos(1,1)
	sPhone.header("New username")
	term.setCursorPos(w,1)
	term.setBackgroundColor(sPhone.theme["header"])
	term.setTextColor(sPhone.theme["headerText"])
	write("X")
	term.setBackgroundColor(sPhone.theme["backgroundColor"])
	term.setTextColor(sPhone.theme["text"])
	term.setCursorPos(2,7)
	print("Change your username.")
	print(" It affects chat app.")
	while true do
		term.setCursorPos(2,4)
		term.clearLine()
		newUsername,mouse,x,y = sPhone.read(nil,nil,nil,true,newUsername)
		if mouse then
			if y == 1 and x == w then
				return
			end
		else
			break
		end
	end
	sPhone.user = newUsername
	config.write("/.sPhone/config/sPhone","username",newUsername)
	sPhone.winOk("Username","changed")
end

local function changePassword()
	skipped = false
	sPhone.wrongPassword = false
	while true do
		local usingPW = config.read("/.sPhone/config/sPhone","lockEnabled")
		if not usingPW then
			break
		end
		term.setBackgroundColor(sPhone.theme["lock.background"])
		term.clear()
		term.setCursorPos(1,1)
		sPhone.header(sPhone.user)
		term.setCursorPos(w,1)
		term.setBackgroundColor(sPhone.theme["header"])
		term.setTextColor(sPhone.theme["headerText"])
		write("X")
		paintutils.drawBox(7,9,20,11,sPhone.theme["lock.inputSide"])
		term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
		if sPhone.wrongPassword then
			term.setTextColor(sPhone.theme["lock.error"])
			term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
			visum.align("center","  Wrong Password",false,13)
		end
		term.setTextColor(sPhone.theme["lock.text"])
		term.setBackgroundColor(sPhone.theme["lock.background"])
		visum.align("center","  Current Password",false,7)
		local loginTerm = window.create(term.native(), 8,10,12,1, true)
		term.redirect(loginTerm)
		term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(sPhone.theme["lock.inputText"])
		while true do
			password,mouse,x,y = sPhone.read("*",nil,nil,true,password)
			if mouse then
				if y == 1 and x == w then
					term.redirect(sPhone.mainTerm)
					return
				end
			else
				break
			end
		end
		term.redirect(sPhone.mainTerm)
		local fpw = config.read("/.sPhone/config/sPhone","password")
		if sha256.sha256(password) ~= fpw then
			sPhone.wrongPassword = true
		else
			sPhone.wrongPassword = false
			break
		end
	end
	
	
	while true do
		term.setBackgroundColor(sPhone.theme["lock.background"])
		term.clear()
		term.setCursorPos(1,1)
		sPhone.header(sPhone.user)
		paintutils.drawBox(7,9,20,11,sPhone.theme["lock.inputSide"])
		term.setBackgroundColor(sPhone.theme["lock.background"])
		if sPhone.wrongPassword then
			term.setTextColor(sPhone.theme["lock.error"])
			term.setBackgroundColor(sPhone.theme["lock.background"])
			visum.align("center","  Wrong Password",false,13)
		end
		term.setTextColor(sPhone.theme["lock.text"])
		term.setBackgroundColor(sPhone.theme["lock.background"])
		visum.align("center","  New Password",false,7)
		local t = "Disable Password"
		term.setCursorPos(w-#t+1,h)
		write(t)
		local loginTerm = window.create(term.native(), 8,10,12,1, true)
		term.redirect(loginTerm)
		term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
		term.clear()
		term.setCursorPos(1,1)
		term.setTextColor(sPhone.theme["lock.inputText"])
		while true do
			pwChange,mouse,x,y = sPhone.read("*",nil,nil,true,pwChange)
			if mouse then
				if y == h and (x >= 10 and x <= w) then
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
			sPhone.header(sPhone.user)
			paintutils.drawBox(7,9,20,11,sPhone.theme["lock.inputSide"])
			term.setBackgroundColor(sPhone.theme["lock.background"])
			term.setTextColor(sPhone.theme["lock.text"])
			visum.align("center","  Repeat Password",false,7)
			local loginTerm = window.create(term.native(), 8,10,12,1, true)
			term.redirect(loginTerm)
			term.setBackgroundColor(sPhone.theme["lock.inputBackground"])
			term.clear()
			term.setCursorPos(1,1)
			term.setTextColor(sPhone.theme["lock.inputText"])
			pwChangeRep = read("*")
			term.redirect(sPhone.mainTerm)
			if sha256.sha256(pwChange) == sha256.sha256(pwChangeRep) then
				sPhone.wrongPassword = false
				config.write("/.sPhone/config/sPhone","password",sha256.sha256(pwChangeRep))
				config.write("/.sPhone/config/sPhone","lockEnabled",true)
				sPhone.winOk("Password","changed")
				return
			else
				sPhone.wrongPassword = true
			end
		else
			config.write("/.sPhone/config/sPhone","lockEnabled",false)
			sPhone.winOk("Password","disabled")
			return
		end
	end
end

local function changeLabel()
	local newLabel = os.getComputerLabel()
	sPhone.header("New Label")
	term.setCursorPos(w,1)
	term.setBackgroundColor(sPhone.theme["header"])
	term.setTextColor(sPhone.theme["headerText"])
	write("X")
	term.setBackgroundColor(sPhone.theme["backgroundColor"])
	term.setTextColor(sPhone.theme["text"])
	term.setCursorPos(2,7)
	print("Change computer label")
	print(" to be identified")
	print(" in your inventory.")
	while true do
		term.setCursorPos(2,4)
		term.clearLine()
		newLabel,mouse,x,y = sPhone.read(nil,nil,nil,true,newLabel)
		if mouse then
			if y == 1 and x == w then
				return
			end
		else
			break
		end
	end
	newLabel = newLabel:gsub("&", string.char(0xc2)..string.char(0xa7)) --yay colors
	os.setComputerLabel(newLabel)
	sPhone.winOk("Computer Label set")
end

local function clearLabel()
	local ok, err = pcall(function() os.setComputerLabel(nil) end)
	if not ok then
		os.setComputerLabel(err)
		sPhone.winOk("Error")
		return
	end
	sPhone.winOk("Computer Label cleared")
end

local function editTheme()
	local themeOptions = {
		"Theme List",
		"",
		"Header Color",
		"Header Text Color",
		"Text Color",
		"Background Color",
		"Window Options",
		"Login Options",
		"Save",
		"Load",
		"Reset",
	}
	local themeOptionsWindow = {
		"Background",
		"Side",
		"Button",
		"Text",
	}
	local themeOptionsLock = {
		"Background",
		"Text",
		"Input Background",
		"Input Text",
		"Input Sides",
		"Error",
	}
	while true do
		local _, id = sPhone.menu(themeOptions,"Theme","X")
		if id == 0 then
			return
		elseif id == 1 then
			shell.run("/.sPhone/apps/themes")
		elseif id == 2 then
			--separator?
		elseif id == 3 then
			sPhone.applyTheme("header", sPhone.colorPicker("Header",sPhone.getTheme("header")))
		elseif id == 4 then
			sPhone.applyTheme("headerText", sPhone.colorPicker("Header Text",sPhone.getTheme("headerText")))
		elseif id == 5 then
			sPhone.applyTheme("text", sPhone.colorPicker("Text",sPhone.getTheme("text")))
		elseif id == 6 then
			sPhone.applyTheme("backgroundColor", sPhone.colorPicker("Background Color",sPhone.getTheme("backgroundColor")))
		elseif id == 7 then
			while true do
				local _, id = sPhone.menu(themeOptionsWindow,"Window Theme","X")
				if id == 0 then
					return
				elseif id == 1 then
					sPhone.applyTheme("window.background", sPhone.colorPicker("Background",sPhone.getTheme("window.background")))
				elseif id == 2 then
					sPhone.applyTheme("window.side", sPhone.colorPicker("Side",sPhone.getTheme("window.side")))
				elseif id == 3 then
					sPhone.applyTheme("window.button", sPhone.colorPicker("Button",sPhone.getTheme("window.button")))
				elseif id == 4 then
					sPhone.applyTheme("window.text", sPhone.colorPicker("Text",sPhone.getTheme("window.text")))
				end
			end
		elseif id == 8 then
			while true do
				local _, id = sPhone.menu(themeOptionsLock,"Login Theme","X")
				if id == 0 then
					return
				elseif id == 1 then
					sPhone.applyTheme("lock.background", sPhone.colorPicker("Background",sPhone.getTheme("lock.background")))
				elseif id == 2 then
					sPhone.applyTheme("lock.text", sPhone.colorPicker("Text",sPhone.getTheme("lock.text")))
				elseif id == 3 then
					sPhone.applyTheme("lock.inputBackground", sPhone.colorPicker("Input Background",sPhone.getTheme("lock.inputBackground")))
				elseif id == 4 then
					sPhone.applyTheme("lock.inputText", sPhone.colorPicker("Input Text",sPhone.getTheme("lock.inputText")))
				elseif id == 5 then
					sPhone.applyTheme("lock.inputSide", sPhone.colorPicker("Input Sides",sPhone.getTheme("lock.inputSide")))
				elseif id == 6 then
					sPhone.applyTheme("lock.error", sPhone.colorPicker("Error",sPhone.getTheme("lock.error")))
				end
			end
		elseif id == 9 then
			local saveTheme
			sPhone.header(sPhone.user)
			term.setCursorPos(w,1)
			term.setBackgroundColor(sPhone.theme["header"])
			term.setTextColor(sPhone.theme["headerText"])
			write("X")
			term.setBackgroundColor(sPhone.theme["backgroundColor"])
			term.setTextColor(sPhone.theme["text"])
			visum.align("center", "Save Theme",false,3)
			while true do
				term.setCursorPos(2,5)
				term.clearLine()
				saveTheme,mouse,x,y = sPhone.read(nil,nil,nil,true,saveTheme)
				if mouse then
					if y == 1 and x == w then
						return
					end
				else
					break
				end
			end
			if fs.exists(saveTheme) then
				fs.delete(saveTheme)
			end
			fs.copy("/.sPhone/config/theme", saveTheme)
			sPhone.winOk("Theme saved!")
		elseif id == 10 then
			local loadTheme = sPhone.list()
			if loadTheme then
				if fs.exists(loadTheme) and not fs.isDir(loadTheme) then
					for k, v in pairs(sPhone.theme) do -- Load theme
						sPhone.theme[k] = config.read(loadTheme, k)
					end
					for k, v in pairs(sPhone.theme) do -- Overwrite theme config
						config.write("/.sPhone/config/theme", k, v)
					end
					sPhone.winOk("Theme loaded!")
				else
					sPhone.winOk("Theme not found!")
				end
			end
		elseif id == 11 then
			fs.delete("/.sPhone/config/theme")
			sPhone.theme = sPhone.defaultTheme
			sPhone.winOk("Removed Theme")
		end
	end
end

local function defaultApps()
	local defaultMenu = {
		"Home",
	}
	local name, id = sPhone.menu(defaultMenu,"Default Apps","X")
	
	if id == 0 then
		return
	elseif id == 1 then
		
		while true do
			local hList = {
				["sphone.home"] = "sPhone Home",
			}
			
			for k,v in pairs(config.list("/.sPhone/config/spklist")) do
				local f = fs.open("/.sPhone/apps/spk/"..k.."/.spk","r")
				local data = f.readAll()
				f.close()
				data = textutils.unserialise(data)
				if data.type == "home" then
					hList[k] = v
				end
			end
			
			local defaultHome = sPhone.list(nil,{
				list = hList,
				pairs = true,
				title = " Default Home",
			})
			
			if not defaultHome then
				sPhone.setDefaultApp("home","sphone.home")
				sPhone.winOk("Done!","Reboot to apply")
				break
			else
				sPhone.setDefaultApp("home",defaultHome)
				sPhone.winOk("Done!","Reboot to apply")
				break
			end
		end
	end
end

while true do
	clear()
	sPhone.header("","X")
	local name, id = sPhone.menu(menu, "Settings","X")
	if id == 0 then
		task.kill(temp.get("homePID"))
		return
	elseif id == 1 then
		setfenv(loadstring(http.get("https://raw.githubusercontent.com/BeaconNet/sPhone/master/src/installer.lua").readAll()),getfenv())()
	elseif id == 2 then
		editTheme()
	elseif id == 3 then
		changeUsername()
	elseif id == 4 then
		changePassword()
	elseif id == 5 then
		changeLabel()
	elseif id == 6 then
		clearLabel()
	elseif id == 7 then
		defaultApps()
	end
end
