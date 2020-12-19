function get(url, post, header, timeout)
  if not url then
    error("a nil value",2)
  end
  if not timeout or not tonumber(timeout) then
    timeout = 1
  end
  
  http.request(url, post, header)
   
  while true do
   local timer = os.startTimer(timeout)
   local ev = {os.pullEvent()}
   if ev[1] == "timer" and ev[2] == timer then
     return false, nil, nil --ikr...
   elseif ev[1] == "http_success" then
     local source = ev[3]
     ev[3].close()
     return true, source, ev[2]
   elseif ev[1] == "http_failure" then
     return false, nil, ev[2]
   end
  end
end
