

if not pocket or not term.isColor() then
  print("sPhone is only for Advanced Pocket Computers!")
  return
end

local old = os.pullEvent
os.pullEvent = os.pullEventRaw

local files = {
	["src/init.lua"] = "/.sPhone/init",
	["src/sPhone.lua"] = "/.sPhone/sPhone",
	
	["install"] = "/.sPhone/update",
	
	["LICENSE"] = "/.sPhone/LICENSE",
	
	["src/apis/sha256.lua"] = "/.sPhone/apis/sha256",
	["src/apis/visum.lua"] = "/.sPhone/apis/visum",
	["src/apis/base64.lua"] = "/.sPhone/apis/base64",
	["src/apis/config.lua"] = "/.sPhone/apis/config",
	["src/apis/task.lua"] = "/.sPhone/apis/task",
	["src/apis/temp.lua"] = "/.sPhone/apis/temp",
	["src/apis/aes.lua"] = "/.sPhone/apis/aes",
	["src/apis/bigfont.lua"] = "/.sPhone/apis/bigfont",
	
	["src/bin/wget.lua"] = "/bin/wget",
	["src/bin/halt.lua"] = "/bin/halt",
	["src/bin/echo.lua"] = "/bin/echo",
	
	["src/sdk/build.lua"] = "/bin/build",
	
	["src/system/vfs.lua"] = "/.sPhone/system/vfs",
	
	["src/apps/spks/appList.spk"] = "/.sPhone/apps/system/appList.spk",
	["src/apps/spks/chat.spk"] = "/.sPhone/apps/system/chat.spk",
	["src/apps/spks/gps.spk"] = "/.sPhone/apps/system/gps.spk",
	["src/apps/spks/home.spk"] = "/.sPhone/apps/system/home.spk",
	["src/apps/spks/info.spk"] = "/.sPhone/apps/system/info.spk",
	["src/apps/spks/settings.spk"] = "/.sPhone/apps/system/settings.spk",
	["src/apps/spks/shell.spk"] = "/.sPhone/apps/system/shell.spk",
	["src/apps/spks/store.spk"] = "/.sPhone/apps/system/store.spk",
	["src/apps/spks/themes.spk"] = "/.sPhone/apps/system/themes.spk",
	["src/apps/spks/explorer.spk"] = "/.sPhone/apps/system/explorer.spk",
	
	["src/interfaces/login"] = "/.sPhone/interfaces/login",
	["src/interfaces/bootImage"] = "/.sPhone/interfaces/bootImage",
	
	["src/startup"] = "/startup",
	["src/startup"] = "/.sPhone/startup",
}

local githubUser    = "SertexTeam"
local githubRepo    = "sPhone"
local githubBranch  = "master"

local w, h = term.getSize()


local function clear()
  term.setBackgroundColor(colors.white)
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.black)
end

local function gui()
	clear()
	paintutils.drawLine(1,1,w,1,colors.blue)
	term.setTextColor(colors.white)
	term.setCursorPos(2,1)
	print("sPhone Installer")
	term.setCursorPos(1,2)
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
end

local function center(text, y)
  local w, h = term.getSize()
  if not y then
  	local x, y = term.getCursorPos()
  end
  term.setCursorPos(math.ceil(w/2)-math.ceil(#text/2), y)
  write(text)
end

local function httpGet(url, save)
	if not url then
		error("not enough arguments, expected 1 or 2", 2)
	end
	local remote = http.get(url)
	if not remote then
		return false
	end
	local text = remote.readAll()
	remote.close()
	if save then
		local file = fs.open(save, "w")
		file.write(text)
		file.close()
		return true
	end
	return text
end

local function get(user, repo, bran, path, save)
	if not user or not repo or not bran or not path then
		error("not enough arguments, expected 4 or 5", 2)
	end
    local url = "https://raw.github.com/"..user.."/"..repo.."/"..bran.."/"..path
	local remote = http.get(url)
	if not remote then
		return false
	end
	local text = remote.readAll()
	remote.close()
	if save then
		local file = fs.open(save, "w")
		file.write(text)
		file.close()
		return true
	end
	return text
end

local function getFile(file, target)
	return get(githubUser, githubRepo, githubBranch, file, target)
end

shell.setDir("")

gui()

local fileCount = 0
for _ in pairs(files) do
	fileCount = fileCount + 1
end
local filesDownloaded = 0

local w, h = term.getSize()

term.setBackgroundColor(colors.white)
term.setTextColor(colors.black)
term.clear()
term.setCursorPos(1,1)
gui()
term.setCursorPos(2,3)
print("License\n")
printError("You must accept the license to install sPhone\n")
print("The MIT License (MIT)\nCopyright (c) 2017 Sertex\n\nRead full license here:\nhttps://raw.github.com/SertexTeam/sPhone/master/LICENSE")
paintutils.drawFilledBox(2,17,9,19,colors.lime)
term.setCursorPos(3,18)
term.setTextColor(colors.white)
print("Accept")

paintutils.drawFilledBox(18,17,25,19,colors.red)
term.setCursorPos(20,18)
term.setTextColor(colors.white)
print("Deny")

while true do
	local e = {os.pullEvent()}
	if e[1] == "mouse_click" then
		local x,y = e[3],e[4]
		if (x >= 2 and y >= 17 ) and (x <= 9 and y <= 19 ) then
			break
		elseif (x >= 18 and y >= 17) and (x <= 25 and y <= 19) then
			os.pullEvent = old
			return
		end
	elseif e[1] == "terminate" then
		os.pullEvent = old
		print("Terminated")
		return
	end
end

if fs.exists("/startup") then
	fs.delete("/startup")
end

for k, v in pairs(files) do
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	gui()
	center("  Downloading files",6)
	term.setCursorPos(1,12)
	term.clearLine()
	center("  "..filesDownloaded.."/"..fileCount, 12)
	local ok = k:sub(1, 4) == "ext:" and httpGet(k:sub(5), v) or getFile(k, v)
	if not ok then
		if term.isColor() then
			term.setTextColor(colors.red)
		end
		term.setCursorPos(2, 16)
		print("Error getting file:")
		term.setCursorPos(2, 17)
		print(k)
		sleep(1.5)
	end
	filesDownloaded = filesDownloaded + 1
end
term.setCursorPos(1,12)
term.clearLine()
center("  "..filesDownloaded.."/"..fileCount, 12)

local data = {}
if fs.exists("/.sPhone/config/sPhone") then
	local f = fs.open("/.sPhone/config/sPhone","r")
	local con = f.readAll()
	f.close()
	con = textutils.unserialize(con)
	data = con
end

data["updated"] = true
local f = fs.open("/.sPhone/config/sPhone","w")
f.write(textutils.serialize(data))
f.close()

if not fs.exists("/startup") then
	fs.copy("/.sPhone/startup","/startup")
end
center("  sPhone installed!",h-2)
center("  Rebooting...",h-1)
sleep(2)
os.reboot()
