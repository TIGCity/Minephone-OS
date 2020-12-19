term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorBlink(true)
print("System halted")
function _G.os.pullEventRaw()
  while true do
    coroutine.yield("haltSystem")
  end
end
 
_G.os.pullEvent = os.pullEventRaw
