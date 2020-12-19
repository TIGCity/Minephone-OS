local isDown
local menu
local id
local user
local pw
local pwr

if not sPhone then
	print("This app is for sPhone")
	return
end

local function clear()
  term.setBackgroundColor(sPhone.theme["backgroundColor"])
  term.setTextColor(sPhone.theme["text"])
  term.clear()
  term.setCursorPos(1,1)
end

clear()
print("Checking Server...")
isDown = http.get("http://sertex.x10.bz/status.php").readAll()
if isDown ~= "true" then
	sPhone.winOk("The server is down", "Retry later")
	return
end

local function login()
	term.setBackgroundColor(colors.white)
	term.clear()
	if sPhone.firstBoot then
		sPhone.header("Setup")
	else
		sPhone.header()
	end
	term.setTextColor(sPhone.theme["text"])
	term.setBackgroundColor(sPhone.theme["backgroundColor"])
	visum.align("center","  Setup Sertex ID",false,3)
	visum.align("center","  Your Username",false,7)
	term.setCursorPos(3,8)
	name = read()
	visum.align("center", "  Your Password",false,9)
	term.setCursorPos(3,10)
	term.clearLine()
	pw = read("*")
	visum.align("center", "  Checking...",false,11)
	rServer = http.post("http://sertex.x10.bz/login.php", "user="..name.."&password="..pw).readAll()
	if rServer ~= "true" then
		print("   Wrong Username/Password")
		sleep(2)
	else
		f = fs.open("/.sPhone/config/username", "w")
		f.write(name)
		f.close()
		f = fs.open("/.sPhone/config/.sIDpw", "w")
		f.write(sha256.sha256(pw))
		f.close()
		sPhone.name = name
	end
end

local function register()
	term.setBackgroundColor(colors.white)
	term.clear()
	if sPhone.firstBoot then
		sPhone.header("Setup")
	else
		sPhone.header()
	end
	term.setTextColor(sPhone.theme["text"])
	term.setBackgroundColor(sPhone.theme["backgroundColor"])
	visum.align("center","  Setup Sertex ID",false,3)
	visum.align("center","  Your Username",false,7)
	term.setCursorPos(3,8)
	name = read()
	while true do
		visum.align("center", "  Your Password",false,9)
		term.setCursorPos(3,10)
		term.clearLine()
		pw = read("*")
		visum.align("center", "  Repeat",false,11)
		term.setCursorPos(3,12)
		term.clearLine()
		pwr = read("*")
		if pw == pwr then
			break
		else
			print("   Wrong Password")
			sleep(1)
			term.clearLine()
		end
	end
	local rServer = http.post("http://sertex.x10.bz/register.php", "user="..name.."&password="..pw).readAll()
	if rServer ~= "Success!" then
		print("Username already exists")
		sleep(2)	
	else
		local f = fs.open("/.sPhone/config/username","w")
		f.write(name)
		f.close()
		local pwf = fs.open("/.sPhone/config/.sIDPw", "w")
		pwf.write(sha256.sha256(pw))
		pwf.close()
		sPhone.name = name
	end
end

while true do
	if fs.exists("/.sPhone/config/.sIDpw") then
		menu = {
			"Logout",
		}
		 _, id = sPhone.menu(menu, "Sertex ID", "X")
		if id == 1 then
		 	fs.delete("/.sPhone/config/.sIDpw")
		elseif id == 0 then
			return
		end
	else
		menu = {
			"Login",
			"Register",
		}
		_, id = sPhone.menu(menu, "Sertex ID", "X")
		if id == 1 then
			login()
		elseif id == 2 then
			register()
		elseif id == 0 then
			return
		end
	end
end

sPhone.header()
