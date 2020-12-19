if not sPhone then
	printError("sPhone must be installed and loaded before running this program")
	return
end


print("Downloading theme list")
local url = "https://raw.github.com/Ale32bit/sPhone-Mods/master/themes.lua"

local ht = http.get(url)
local themesRaw = ht.readAll()
local themes = textutils.unserialize(themesRaw)
ht.close()

local li = {}
for k,v in pairs(themes) do
	table.insert(li,k)
end
while true do
	local g, c = sPhone.menu(li,"  Themes","X")
	if c == 0 then
		return
	elseif c > #li then
	
	else
		for k,v in pairs(themes[g]) do
			sPhone.applyTheme(k,v)
		end
		sPhone.winOk("Theme applied")
		break
	end
end
