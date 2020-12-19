--[[
 Visum API by Sertex-Team
 Graphical User Interface API for ComputerCraft 1.7^
]]--

local aaTypes = {
	["left"] = true,
	["center"] = true,
	["right"] = true,
}

function version()
 return 1.1, "Visum Alpha 1.1"
end

function align(aType, text, slow, y)
 if not aType or not aaTypes[aType] then
  error('Use "left", "center" or "right" as align')
 end
 if not text then
  error("Undefined text (a nil value)")
 end
 local cx, cy = term.getCursorPos()
 local w, h = term.getSize()
 if aType == "left" then
  if not y then
   y = cy
  end
   term.setCursorPos(1,y)
  if slow then
   textutils.slowWrite(text)
  else
   term.write(text)
  end
 elseif aType == "center" then
  if not y then
   y = cy
  end
  term.setCursorPos(math.ceil(w/2) - math.ceil(#text/2), y)
  if slow then
   textutils.slowWrite(text)
  else
   term.write(text)
  end
  elseif aType == "right" then
  if not y then
   y = cy
  end
  term.setCursorPos(1+w - #text, y)
  if slow then
   textutils.slowWrite(text)
  else
   term.write(text)
  end
 end
end

local function drawPixelInternal( xPos, yPos ) -- Paintutils API - Made to prevent paintutils overwrite
    term.setCursorPos( xPos, yPos )
    term.write(" ")
end

function box(startX,startY,endX,endY,nColour) -- Paintutils API - Made to prevent paintutils overwrite
 if type( startX ) ~= "number" or type( startX ) ~= "number" or
       type( endX ) ~= "number" or type( endY ) ~= "number" or
       (nColour ~= nil and type( nColour ) ~= "number") then
        error( "Expected startX, startY, endX, endY, colour", 2 )
    end

    startX = math.floor(startX)
    startY = math.floor(startY)
    endX = math.floor(endX)
    endY = math.floor(endY)

    if nColour then
        term.setBackgroundColor( nColour )
    end
    if startX == endX and startY == endY then
        drawPixelInternal( startX, startY )
        return
    end

    local minX = math.min( startX, endX )
    if minX == startX then
        minY = startY
        maxX = endX
        maxY = endY
    else
        minY = endY
        maxX = startX
        maxY = startY
    end

    for x=minX,maxX do
        for y=minY,maxY do
            drawPixelInternal( x, y )
        end
    end
end

function buttons(buList,ignoreEvent)
 if type(buList) ~= "table" then
  error("invalid arg #1 (table expected, got "..tostring(type(buList))..")", 1)
 end

 for k, v in pairs(buList) do
  box(buList[k][2],buList[k][3],buList[k][4],buList[k][5],buList[k][6])
  term.setCursorPos(buList[k][2],buList[k][3])
  term.setTextColor(buList[k][7])
	if buList[k][9] then
		term.setCursorPos(buList[k][2],buList[k][3] + buList[k][9] - 1)
	else
		term.setCursorPos(buList[k][2],buList[k][3])
	end
  write(buList[k][8])
 end
 while not ignoreEvent do
  e,mk,mx,my = os.pullEvent()
  if e == "mouse_click" or e == "monitor_touch" then
   for k, v in ipairs(buList) do
    if (mx >= v[2] and my >= v[3]) and (mx <= v[4] and my <= v[5]) then
     return v[1], v[8], mk
    end
   end
  end
 end
end

local function menu()
	return nil
end

--More functions will be added
