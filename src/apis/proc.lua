-- "multitasking"
local _proc = {}
local _killProc = {}
function signal(pid, sig)
  local p = _proc[pid]
  if p then
    if not p.filter or p.filter == "signal" then
      local ok, rtn = coroutine.resume(p.co, "signal", tostring(sig))
      if ok then
        p.filter = rtn
      end
    end
    return true
  end
  return false
end
function kill(pid)
  _killProc[pid] = true
end
function launch(fn, name)
  _proc[#_proc + 1] = {
    name = name or "lua",
    co = coroutine.create(setfenv(fn, getfenv())),
  }
  return true
end
function getInfo()
  local t = {}
  for pid, v in pairs(_proc) do
    t[pid] = v.name
  end
  return t
end

function run()
  os.queueEvent("multitask")
  while _proc[1] ~= nil do
    local ev = {os.pullEventRaw()}
    for pid, v in pairs(_proc) do
      if not v.filter or ev[1] == "terminate" or v.filter == ev[1] then
        local ok, rtn = coroutine.resume(v.co, unpack(ev))
        if ok then
          v.filter = rtn
        end
      end
      if coroutine.status(v.co) == "dead" then
        _killProc[pid] = true
      end
    end
    for pid in pairs(_killProc) do
      _proc[pid] = nil
    end
    if next(_killProc) then
      _killProc = {}
    end
  end
end
