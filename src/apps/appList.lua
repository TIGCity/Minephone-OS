local spkList = "/.sPhone/config/spklist"
local dir = "/.sPhone/apps/spk/"
local apps = {}
local ind = {}
if not fs.exists(spkList) then
	config.list("/.sPhone/config/spklist")
end
for k,v in pairs(config.list(spkList)) do
	table.insert(apps,{
		id = k,
		name = v,
	})
end
for k,v in ipairs(apps) do
	local hid = config.read(dir..v.id.."/.spk","hidden")
	if hid then
		table.remove(apps,k)
	end
end
for k,v in ipairs(apps) do
	ind[ v.id ] = v.name
end
sPhone.launch(sPhone.list(nil,{
	list = ind,
	pairs = true,
	title = " Apps"
}))
