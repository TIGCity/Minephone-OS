local x, y, z = gps.locate(0)
if not x then
  x, y, z = "?", "?", "?"
end
if tonumber(x) then
  sPhone.winOk("X Y Z", math.ceil(x).." "..math.ceil(y).." "..math.ceil(z))
else
  sPhone.winOk("X Y Z","? ? ?")
end
