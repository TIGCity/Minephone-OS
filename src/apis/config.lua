function write(file,config,value)
	local data = {}
	if fs.isDir(file) then
		return false
	end
	if fs.exists(file) then
		local f = fs.open(file,"r")
		local con = f.readAll()
		f.close()
		con = textutils.unserialize(con)
		if not con then
			return false
		end
		data = con
	end
	
	data[config] = value
	local f = fs.open(file,"w")
	f.write(textutils.serialize(data))
	f.close()
	return true
end

function read(file,config)
	local data = {}
	if fs.isDir(file) then
		return nil
	end
	if fs.exists(file) then
		local f = fs.open(file,"r")
		local con = f.readAll()
		f.close()
		con = textutils.unserialize(con)
		if not con then
			return nil
		end
		data = con
	end
	return data[config]
end

function list(file)
	local data = {}
	if fs.isDir(file) then
		return nil
	end
	if fs.exists(file) then
		local f = fs.open(file,"r")
		local con = f.readAll()
		f.close()
		con = textutils.unserialize(con)
		if not con then
			return nil
		end
		data = con
	end
	return data
end

function convert(cfgfile)
	local rtn
	local ok, err = pcall(function()
		local path
		if not cfgfile then
			path = "/.lmnet/sys.conf"
		else
			path = cfgfile
		end
		local file = fs.open(path, "r")
		if not file then
			return nil
		end
		local lines = {}
		local line = ""
		while line ~= nil do
			line = file.readLine()
			if line then
				table.insert(lines, line)
			end
		end
		file.close()
		local config = {}
		for _, v in pairs(lines) do
			local tmp
			local tmp2 = ""
			for match in string.gmatch(v, "[^\=]+") do
				if tmp then
					tmp2 = tmp2..match
				else
					tmp = match
				end
			end
			config[tmp] = textutils.unserialize(tostring(tmp2))
		end
		rtn = config
	end)
	if not ok then
		return false, err
	end
	fs.delete(cfgfile)
	for k,v in pairs(rtn) do
		write(cfgfile,k,v)
	end
	return true
end
