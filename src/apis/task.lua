local processList = {}
local exit = false
local autoExit = true
local killProcesses = {}
local pid = 0

function setAutoExit(val)
  autoExit = val
end

function run()
  local firstRun = true
  while (function()
    local rtn = false
    for i, co in pairs(processList) do
      if coroutine.status(co) ~= "dead" then
        rtn = true
      end
    end
    return rtn
  end)() or not autoExit do
    if exit then
      break
    end
    local event = {}
    if not firstRun then
      event = {os.pullEventRaw()}
    end
    firstRun = false
    for k, co in pairs(processList) do
      if coroutine.status(co) ~= "dead" then
        coroutine.resume(co,unpack(event))
      end
    end
    for k, code in pairs(killProcesses) do
      processList[k] = nil
    end
  end
end

function add(func)
  local co = coroutine.create(func)
	pid = pid + 1
  processList[pid] = co
  return tonumber(pid)
end

function kill(pid)
  killProcesses[pid] = true
end

function getList()
	p = 0
	for k,v in pairs(processList) do
		if v then
			p = p + 1
		end
	end
	return processList, p
end
