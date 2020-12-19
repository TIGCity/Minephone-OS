local host = "https://raw.github.com/BeaconNet/sPhone-Store/master/"
local index = host.."index.lua"
local apps = host.."apps/"
local appsL = {}
local w, h = term.getSize()

local function redraw()
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.clear()
	term.setTextColor(colors.white)
	paintutils.drawLine(1,1,w,1,colors.green)
	term.setCursorPos(1,1)
	write(" Store")
	visum.align("right","X",false,1)
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	term.setCursorPos(1,3)
end

local function install(path,name)
	local data = http.get("https://raw.github.com/BeaconNet/sPhone-Store/master/apps/"..path).readAll()
	local f = fs.open("/tmp/sPhoneStore/"..name..".spk","w")
	f.write(data)
	f.close()
	local status = sPhone.install("/tmp/sPhoneStore/"..name..".spk")
	if status then
		sPhone.winOk("Installed")
	else
		sPhone.winOk("Error while installing")
	end
end

redraw()

term.setCursorPos(1,2)
visum.align("center","  Loading",false,2)
term.setCursorPos(1,3)

local c = http.get(index).readAll()

local appsIndex = textutils.unserialize(c)

redraw()

local mx,my = term.getCursorPos()
term.setCursorPos(1,2)
term.clearLine()
term.setCursorPos(mx,my)


while true do
	local path,name = sPhone.list(nil,{
		title = " Store",
		pairs = true,
		list = appsIndex,
		bg1 = colors.white,
		fg1 = colors.black,
		bg2 = colors.green,
		fg2 = colors.white,
		bg3 = colors.green,
		fg3 = colors.white,
	})
	
	if not path then
		return
	end
	
		local data = http.get("https://raw.github.com/BeaconNet/sPhone-Store/master/apps/"..path).readAll()
		data = textutils.unserialise(data)
		if data then
			local _conf = textutils.unserialise(data.config)
			redraw()
			term.setCursorPos(2,3)
			print(_conf.name)
			term.setCursorPos(2,6)
			term.setTextColor(colors.black)
			print("Author:")
			term.setTextColor(colors.gray)
			term.setCursorPos(2,7)
			print(_conf.author)
			term.setCursorPos(2,9)
			term.setTextColor(colors.black)
			print("Type:")
			term.setTextColor(colors.gray)
			term.setCursorPos(2,10)
			print((_conf.type or "Normal"))
			term.setCursorPos(2,12)
			term.setTextColor(colors.black)
			print("Version:")
			term.setTextColor(colors.gray)
			term.setCursorPos(2,13)
			print(_conf.version)
			
			if config.read("/.sPhone/config/spklist",_conf.id) then
				paintutils.drawLine(19,4,25,4,colors.red)
				term.setTextColor(colors.white)
				term.setCursorPos(19,4)
				write("Delete")
			else
				paintutils.drawLine(19,4,25,4,colors.green)
				term.setTextColor(colors.white)
				term.setCursorPos(19,4)
				write("Install")
			end
			
			while true do
				local _,_,mx,my = os.pullEvent("mouse_click")
				if my == 1 and mx == w then
					break
				elseif (mx >= 19 and mx <= 25) and my == 4 then
					if config.read("/.sPhone/config/spklist",_conf.id) then
						if fs.exists("/.sPhone/apps/spk/".._conf.id) then
							fs.delete("/.sPhone/apps/spk/".._conf.id)
						end
						config.write("/.sPhone/config/spklist",_conf.id,nil)
					else
						install(path,name)
					end
					break
				end
			end
		else
			sPhone.winOk("Cannot install","file corrupted")
		end
		
		
		
	end
