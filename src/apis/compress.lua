--[[
	Compress made by Creator
]]

local filesystem = {}
 
local function readFile(path)
	local file = fs.open(path,"r")
	local variable = file.readAll()
	file.close()
	return variable
end
 
local function explore(dir)
	local buffer = {}
	local sBuffer = fs.list(dir)
	for i,v in pairs(sBuffer) do
		sleep(0.05)
		if fs.isDir(dir.."/"..v) then
			if v ~= ".git" then
				buffer[v] = explore(dir.."/"..v)
			end
			buffer[v] = readFile(dir.."/"..v)
		end
	end
	return buffer
end

local function writeFile(path,content)
	local file = fs.open(path,"w")
	file.write(content)
	file.close()
end

local function writeDown(input,dir)
	for i,v in pairs(input) do
		if type(v) == "table" then
			writeDown(v,dir.."/"..i)
		elseif type(v) == "string" then
			writeFile(dir.."/"..i,v)
		end
	end
end

function compress(input, output)
	if not output then error("expected string") end
	if not fs.exists(input) then error("file not found") end
	local filesystem = explore(input)
	local file = fs.open(output,"w")
	file.write(textutils.serialize(filesystem))
	file.close()
	return true
end

function decompress(input, output)
	if not output then error("expected string") end
	if not fs.exists(input) then error("file not found") end
	local file = fs.open(input,"r")
	f = file.readAll()
	file.close()
	inputTable = textutils.unserialize(f)
	writeDown(inputTable,output)
	return true
end
