--[[
  Sertex ID API - Made by Sertex-Team
]]--

local SERVER = "http://sertex.x10.bz/"

function status()
  local isUp = http.get(SERVER.."status.php").readAll()
  if isUp == "true" then
    return true
  else
    return false
  end
end

function login(username, password, isHashed)
  if isHashed then
    local login = http.post(SERVER.."login.php", "user="..username.."&password="..password.."&hashed=true").readAll()
  else
    local login = http.post(SERVER.."login.php", "user="..username.."&password="..password).readAll()
  end
  if login == "true" then
    return true
  else
    return false
  end
end

function register(username, password, isHashed)
  if isHashed then
    local register = http.post(SERVER.."register.php", "user="..username.."&password="..password.."&hashed=true").readAll()
  else
    local register = http.post(SERVER.."register.php", "user="..username.."&password="..password).readAll()
  end
  if register == "Success!" then
    return true
  else
    return false, register
  end
end

function checkUser(username)
  local check = http.post(SERVER.."exists.php", "user="..username).readAll()
  if check == "true" then
    return true
  else
    return false
  end
end

exists = checkUser

function sendSMS(username, password, to, msg, isHashed)
  if isHashed then
    local send = http.post(SERVER.."send.php","user="..username.."&password="..password.."&to="..to.."&message="..message.."&hashed=true").readAll()
  else
    local send = http.post(SERVER.."send.php","user="..username.."&password="..password.."&to="..to.."&message="..message).readAll()
  end
  if send == "true" then
    return true
  else
    return false,send
  end
end

function updateSMS(username, password, all, from, isHashed)
  if isHashed then
    local update = http.post(SERVER.."update.php","user="..username.."&password="..password.."&hashed=true").readAll()
  else
    local update = http.post(SERVER.."update.php","user="..username.."&password="..password).readAll()
  end
  if update then
    return true, update
  else
    return false
  end
end
