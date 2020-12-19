local _temp = {}

function set(config, value)
	_temp[config] = value
end

function get(config)
	return _temp[config]
end
