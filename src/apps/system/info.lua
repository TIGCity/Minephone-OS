local function clear()
  term.setBackgroundColor(sPhone.getTheme("backgroundColor"))
  term.setTextColor(sPhone.getTheme("text"))
  term.clear()
  term.setCursorPos(1,1)
end
clear()
sPhone.header("Info", "X")
print("ID: "..os.getComputerID())
print("User: "..sPhone.user)
if os.getComputerLabel() then
	print("Label: "..os.getComputerLabel())
end
print("Version: "..sPhone.version)
print("")
print("sPhone made by BeaconNet")
print("Krist by 3d6")
print("SHA256 by GravityScore")
print("Compress by Creator")
print("And thanks to dan200 for this mod!")

while true do
  local w, h = term.getSize()
  local _, _, x, y = os.pullEvent("mouse_click")
  if y == 1 and x == w then
    return
  end
end
