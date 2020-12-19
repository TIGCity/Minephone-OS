term.setBackgroundColor(sPhone.theme["backgroundColor"])
term.clear()
term.setCursorPos(1,1)
term.setTextColor(sPhone.theme["text"])
sPhone.header("RedNet Chat")
term.setBackgroundColor(sPhone.theme["backgroundColor"])
term.setTextColor(sPhone.theme["text"])
term.setCursorPos(2, 5)
if not peripheral.isPresent("back") or not peripheral.getType("back") == "modem" then
	print("Modem not found")
	print(" Press any key")
	os.pullEvent("key")
	return
end
write("Host: ")
local h = read()	term.setCursorPos(2,6)
shell.run("/rom/programs/rednet/chat", "join", h, sPhone.user)
