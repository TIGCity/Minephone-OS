local args = {...}
if not sPhone then
	print("build requires sPhone")
end
if #args < 2 then
	print("Sertex Application Package Builder")
	print("Usage: build <App Folder> <Output>")
	return
end

local dir = args[1]
local output = args[2]
local final = {}
local builderVersion = 1.2

if not fs.exists(dir) or not fs.isDir(dir) then
	print("Input must be a folder")
	return
end


local f = fs.open(dir.."/config","r")
local _config = textutils.unserialize(f.readAll())
f.close()
if not _config then
	print("Config file is corrupted")
	return
end

-- COMPRESS

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
                        else
                                buffer[v] = readFile(dir.."/"..v)
                        end
        end
        return buffer
end


-- COMPRESS

local result = {}

_config.type = (_config.type or "app")
local hidden = false

if _config.hidden then
	hidden = "true"
end

print("Name:",_config.name)
print("Author:",_config.author)
print("Version:",_config.version)
print("Type:",_config.type)
print("ID:",_config.id)
print("Main:",_config.main)
print("Type:",_config.type)
print("Hidden:",hidden)


if not _config.id then
	printError("ID not found")
	print("Build aborted")
	return
end

if not _config.main then
	printError("Main file not set")
	print("Build aborted")
	return
end

if not _config.type then
	_config.type = "app"
end


if string.getExtension(output) ~= "spk" then
	output = output..".spk"
end

print("Building...")

local filesystem = explore(args[1].."/main")
result["files"] = textutils.serialize(filesystem)
result["config"] = textutils.serialize(_config)


local newResult = textutils.serialize(result)
local info = "--\n-- Sertex Application Package\n-- Built with SPK builder "..builderVersion.."\n--"
local f = fs.open("/tmp/build/spk/builds/".._config.id,"w")
f.write(info.."\n"..newResult)
f.close()

print("Testing...")

local f = fs.open("/tmp/build/spk/builds/".._config.id,"r")
local script = f.readAll()
f.close()
script = textutils.unserialize(script)
if not script then
	print("SPK corrupted")
	print("Build aborted")
	return
end
				
local function writeFile(patha,contenta)
	local file = fs.open(patha,"w")
	file.write(contenta)
	file.close()
end
function writeDown(inputa,dira)
	for i,v in pairs(inputa) do
		if type(v) == "table" then
			writeDown(v,dira.."/"..i)
		elseif type(v) == "string" then
			writeFile(dira.."/"..i,v)
		end
	end
end

writeDown(textutils.unserialize(script.files),"/tmp/build/spk/tests/".._config.id.."/files")
local f = fs.open("/tmp/build/spk/tests/".._config.id.."/.spk","w")
f.write(textutils.serialize(_config))
f.close()

print("Running test...")

local ok, err = pcall(function()
	setfenv(loadfile("/tmp/build/spk/tests/".._config.id.."/files/".._config.main), setmetatable({
		spk = {
			getName = function()
				return (_config.name or nil)
			end,
					
			getID = function()
				return (_config.id or nil)
			end,
					
			getPath = function()
				return "/tmp/build/spk/tests/".._config.id
			end,
					
			getDataPath = function()
				return "/tmp/build/spk/tests/".._config.id.."/data"
			end,
					
			getAuthor = function()
				return (_config.author or nil)
			end,
					
			getVersion = function()
				return (_config.version or nil)
			end,
					
			open = function(file, mode)
				return fs.open("/tmp/build/spk/tests/".._config.id.."/data/"..file,mode)
			end,
		},
		string = string,
		sPhone = sPhone,
	 }, {__index = getfenv()}))
end)
		
if not ok then
	print("Test failed")
	print(err)
	print("Build aborted")
	return
end

print("Test completed")

fs.copy("/tmp/build/spk/builds/".._config.id,output)
