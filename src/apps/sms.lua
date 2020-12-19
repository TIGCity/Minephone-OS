local tArgs = {...}
local loading = {"|","/","-","\\","|","/","-","\\"}
local server = "http://sertex.x10.bz/"
local sendTo

if not sPhone then
	printError("This app is for sPhone")
	return
end

--check if the server is down
local isServerUp = http.get(server.."/status.php").readAll()
if isServerUp ~= "true" then
	sPhone.winOk("The service is","currently down!", colors.lime, colors.green, colors.white, colors.lime)
	return
end
term.setBackgroundColor(colors.white)
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.black)
print("sPhone SMS")
if not fs.exists("/.sPhone/config/.sIDpw") then
	sPhone.winOk("Sertex ID not set!","Run sID!", colors.lime, colors.green, colors.white, colors.lime)
	return
end
f = fs.open("/.sPhone/config/username", "r")
local user = f.readLine()
f.close()
f = fs.open("/.sPhone/config/.sIDpw", "r")
local pass = f.readLine()
f.close()
local head = "user="..user.."&password="..pass.."&hashed=true"
http.request(server.."login.php",head)
local update = os.startTimer(0.15)
local pos = 1
while true do
  local _,y = term.getCursorPos()
  term.clearLine()
  term.setCursorPos(1,y)
  term.write("Loading "..loading[pos])
  local e = {os.pullEvent()}
  if e[1] == "timer" and e[2] == update then
    pos = pos + 1
    if pos > #loading then pos = 1 end
    update = os.startTimer(0.15)
  elseif e[1] == "http_success" then
    if e[3].readAll() == "true" then
			if not tArgs[1] then
				term.clearLine()
				term.setCursorPos(1,y)
				print("Leave blank to get unread chat\n")
				write("Send To: ")
				sendTo = read()
			else
				sendTo = tArgs[1]
			end
			local doesUserExist = http.post(server.."exists.php", "user="..sendTo).readAll()
			if doesUserExist ~= "true" then
				sPhone.winOk(sendTo.." does","not exist!", colors.lime, colors.green, colors.white, colors.lime)
				return
			end
      break
    else
      sPhone.winOk("Wrong Username","or Password", colors.lime, colors.green, colors.white, colors.lime)
      return
    end
  elseif e[1] == "http_failure" then
    term.clearLine()
    term.setCursorPos(1,y)
    sPhone.winOk("Connection lost!","Check internet!", colors.lime, colors.green, colors.white, colors.lime)
    return
  end
end
term.clear()
local x,y = term.getSize()
local mainTerm = term.current()
local displayWin = window.create(term.native(),1,1,x,y-1,true)
local readWin = window.create(term.native(),1,y,x,y,true)
local ntv = term.redirect(mainTerm)
local x,y = 1,1
local mx,my = displayWin.getSize()


  local function printMsg(msg, save)
		displayWin.setCursorBlink(false)
		displayWin.setTextColor(colors.black)
		local nTerm = term.current()
		term.redirect(displayWin)
		print(msg)
		if save then
			f = fs.open("/.sPhone/cache/sms/"..sendTo,"a")
			f.write(msg.."\n")
			f.close()
		end
		term.redirect(nTerm)
		term.setTextColor(colors.white)
		term.setCursorPos(7,1)
		term.setCursorBlink(true)
	end


local function readMsg()
	term.redirect(readWin)
	while true do
		term.setCursorBlink(true)
		term.setBackgroundColor(colors.green)
		term.setTextColor(colors.white)
		term.clear()
		term.setCursorPos(1,1)
		if sendTo ~= "" then
			term.write("Send: ")
			local msg = read()
			local rawMsg = msg
			local msg = base64.encode(msg)
			term.clear()
			if base64.decode(msg) == "/logout" then
				term.redirect(mainTerm)
				return
			end
			if msg ~= "" then
				local pos = 1
				local update = os.startTimer(0.15)
				http.request(server.."send.php","user="..user.."&password="..pass.."&message="..msg.."&to="..sendTo.."&hashed=true")
				while true do
					term.clear()
					term.setCursorPos(1,1)
					term.write("Sending "..loading[pos])
					e = {os.pullEvent()}
					if e[1] == "timer" and e[2] == update then
						update = os.startTimer(0.15)
						pos = pos + 1
						if pos > #loading then pos = 1 end
					elseif e[1] == "http_success" then
						printMsg("<You> "..rawMsg,true)
						break
					elseif e[1] == "http_failure" then
						term.redirect(ntv)
						term.clear()
						term.setCursorPos(1,1)
						sPhone.winOk("Disconnected",nil, colors.lime, colors.green, colors.white, colors.lime)
						return
					end
				end
			end
		else
			term.write("Press enter to exit")
			term.setCursorBlink(false)
			while true do
				local _, k = os.pullEvent("key")
				if k == keys.enter then
					term.redirect(mainTerm)
					return
				end
			end
		end
	end
end
local function recMsg()
	displayWin.setBackgroundColor(colors.white)
	displayWin.setTextColor(colors.black)
	displayWin.clear()
	if sendTo ~= "" then
		printMsg("Type /logout to exit",false)
		if fs.exists("/.sPhone/cache/sms/"..sendTo) then
			local f = fs.open("/.sPhone/cache/sms/"..sendTo,"r")
			local line = f.readLine()
			repeat
				printMsg(line,false)
				line = f.readLine()
			until not line
			f.close()
		end
	else
		printMsg("All messages",false)
	end
	
  while true do
    if sendTo == "" then
    	stream = http.post(server.."update.php?new",head)
    else
      stream = http.post(server.."update.php",head.."&to="..sendTo)
    end
    newMessages = {}
    line = stream.readLine()
    repeat
      table.insert(newMessages,line)
      line = stream.readLine()
    until not line
    for i,v in pairs(newMessages) do
      t = textutils.unserialize(v)
      if t then
        date = t["date"]
        mesg = "<"..t["from"].."> "..base64.decode(t["message"])
        printMsg(mesg,true)
      end
    end
  end
end
parallel.waitForAny(readMsg,recMsg)
