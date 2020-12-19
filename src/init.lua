os.oldPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local function crash(err)
	if not sPhone then
		sPhone = {
			devMode = false,
		}
	end
	term.setCursorBlink(false)
	term.setBackgroundColor(colors.white)
	term.clear()
	term.setCursorPos(1,1)
	term.setTextColor(colors.black)
	if not err then
		err = "Undefined Error"
	end
	
	print("sPhone got an error :(\n")
	term.setTextColor(colors.red)
	print(err)
	term.setTextColor(colors.black)
	print("")
	if sPhone.version then
		print("sPhone "..sPhone.version)
	end
	print("Computer ID: "..os.getComputerID())
	if _CC_VERSION then
		print("CC Version: ".._CC_VERSION)
		print("MC Version: ".._MC_VERSION)
	elseif _HOST then
		print("Host: ".._HOST)
	else
		print("CC Version: Under 1.74")
		print("MC Version: Undefined")
		term.setTextColor(colors.red)
		print("Update CC to 1.74 or higher")
		term.setTextColor(colors.black)
	end
	print("LUA Version: ".._VERSION)
	if _LUAJ_VERSION then
		print("LUAJ Version: ".._LUAJ_VERSION)
	end
	print("Contact sPhone devs:")
	print("GitHub: SertexTeam/sPhone")
	print("Thanks for using sPhone")
	print("Press any key")
	repeat
		sleep(0)
	until os.pullEvent("key")
	if not sPhone.devMode then
		_G.term = nil
	end
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	sleep(0.1)
	shell.run("/rom/programs/shell")
end

local function recovery()
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.clear()
	term.setCursorPos(1,1)
	print("sPhone Recovery")
	print("[1] Hard Reset")
	print("[2] Update sPhone")
	print("[3] Reset User Config")
	print("[4] Continue Booting")
	print("[5] Boot in safe mode")
	while true do
		local _, k = os.pullEvent("key")
		if k == 2 then
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
			for k, v in pairs(fs.list("/")) do
				if not fs.isReadOnly(v) then
					if fs.isDir(v) then
						shell.setDir(v)
						for k, v in pairs(fs.list("/"..v)) do
							fs.delete(v)
							print("Removed "..shell.dir().."/"..v)
						end
						shell.setDir(shell.resolve(".."))
					end
					fs.delete(v)
					print("Removed "..v)
				end
			end
			print("Installing sPhone...")
			sleep(0.5)
			setfenv(loadstring(http.get("https://raw.githubusercontent.com/SertexTeam/sPhone/master/src/installer.lua").readAll()),getfenv())()
		elseif k == 3 then
			setfenv(loadstring(http.get("https://raw.githubusercontent.com/SertexTeam/sPhone/master/src/installer.lua").readAll()),getfenv())()
		elseif k == 4 then
			fs.delete("/.sPhone/config")
			fs.delete("/.sPhone/cache")
			fs.delete("/.sPhone/apps/spk")
			fs.delete("/.sPhone/autorun")
			os.reboot()
		elseif k == 5 then
			safemode = false
			break
		elseif k == 6 then
			safemode = true
			break
		end
	end
end

	term.setBackgroundColor(colors.white)
	term.setCursorPos(1,1)
	term.clear()
	term.setTextColor(colors.black)
	print("Sertex")
	if fs.exists("/.sPhone/interfaces/bootImage") then
		local bootImage = paintutils.loadImage("/.sPhone/interfaces/bootImage")
		paintutils.drawImage(bootImage, 11,7)
	else
		print("Missing bootImage")
	end
	local w, h = term.getSize()
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.setCursorPos(1,h)
	write("Press ALT to recovery mode")
	local bootTimer = os.startTimer(1)
	while true do
		local e,k = os.pullEvent()
		if e == "key" and k == 56 then
			recovery()
			break
		elseif e == "timer" and k == bootTimer then
			safemode = false
			break
		end
	end

if not fs.exists("/.sPhone/sPhone") then
	printError("sPhone not installed")
	shell.run("/.sPhone/init -u")
	return
end

	
local runningOnStartup

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)

if sPhone then
	printError("sPhone already started")
	return
end

if not pocket or not term.isColor() then
	printError("Computer not supported: use an Advanced Pocket Computer or an Advanced Wireless Pocket Computer")
	return
end

local tArgs = {...}

local argData = {
	["-u"] = false,
	["-s"] = false,
}

if #tArgs > 0 then
  while #tArgs > 0 do
    local tArgs = table.remove(tArgs, 1)
    if argData[tArgs] ~= nil then
      argData[tArgs] = true
    end
  end
end

if argData["-u"] then
	print("Getting installer...")
	setfenv(loadstring(http.get("https://raw.githubusercontent.com/SertexTeam/sPhone/master/src/installer.lua").readAll()),getfenv())()
end

os.pullEvent = os.oldPullEvent

local ok, err = pcall(function()
	setfenv(loadfile("/.sPhone/sPhone"), setmetatable({
		crash = crash,
		safemode = safemode,
	}, {__index = getfenv()}))()
end)
	
if not ok then
	crash(err)
end
_G.term = nil -- The OS ends here - This string force to crash the pda to shutdown
