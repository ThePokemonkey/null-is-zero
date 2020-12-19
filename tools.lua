function playsfx(name)
	if not sssfx[name] then
		sfx = love.audio.newSource("sfx/"..name..".ogg","static")
		love.audio.play(sfx)
		sfx = nil
	else
		love.audio.play(sssfx[name])
	end
end

function makeunit(nutype,nx,ny,invalue)
	nvalue = invalue or 0
	if nutype > 0 then
		if nutype == 24 then nvalue = levelnum end
		table.insert(units,{utype = nutype,x = nx,y = ny,value = nvalue,id = cid+1})
		cid = cid+1
		return
	end
end

function findunit(sx,sy)
	local endtable = {}
	for i,unit in pairs(units) do
		if unit.x == sx and unit.y == sy then table.insert(endtable,unit)  end
	end
	return endtable
end

function findop(sx,sy)
	local units = findunit(sx,sy)
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "op" or texttypes[unit.utype] == "numop" then return unit end
	end
end

function findeq(sx,sy)
	local units = findunit(sx,sy)
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "equals" or texttypes[unit.utype] == "numequals" then return unit end
	end
end

function findnum(sx,sy)
	local units = findunit(sx,sy)
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "num" or texttypes[unit.utype] == "numequals" or texttypes[unit.utype] == "numop" then return unit end
	end
end

function findnums(sx,sy)
	local units = findunit(sx,sy)
	local endtable = {}
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "num" or texttypes[unit.utype] == "numequals" or texttypes[unit.utype] == "numop" then table.insert(endtable,unit) end
	end
	return endtable
end

function findopeq(sx,sy)
	local units = findunit(sx,sy)
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "equals" or texttypes[unit.utype] == "op"  or texttypes[unit.utype] == "numequals" or texttypes[unit.utype] == "numop" then return unit end
	end
end

function findunitid(id)
	for i,unit in pairs(units) do
		if unit.id == id then return unit,i end
	end
end


function inbounds(cx,cy)
	if cx > 0 and cx < 19 and cy > 0 and cy < 14 then return true else return end
end

function breakunit(rx,ry)
	local tunits = findunit(rx,ry)
	if #tunits > 0 then
		for i,v in pairs(tunits) do
			local h, index = findunitid(v.id)
			table.remove(units,index) 
		end
	end
end

function breakunitid(id)
	local tunit,index = findunitid(id)
	if tunit then table.remove(units,index) end
end

function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function addundo()
	local cunits = deepCopy(units)
	table.insert(undos,cunits)
end

function deldels()
	for i,v in pairs(delthese) do
		breakunitid(v)
		if not destroyplayed then
			playsfx("destroy")
			destroyplayed = true
		end
	end
	delthese = {}
end

function dump(o, fulldump)
  if type(o) == 'table' then
    local s = '{'
    local cn = 1
    if #o ~= 0 then
      for _,v in ipairs(o) do
        if cn > 1 then s = s .. ',' end
        s = s .. dump(v, fulldump)
        cn = cn + 1
      end
    else
      if not fulldump and o["new"] ~= nil then --abridged print for table
        local tbl = {fullname = o.textname, id = o.id, x = o.x, y = o.y, dir = o.dir}
        for k,v in pairs(tbl) do
           if cn > 1 then s = s .. ',' end
          s = s .. tostring(k) .. ' = ' .. dump(v, fulldump)
          cn = cn + 1
        end
      else
        for k,v in pairs(o) do
          if cn > 1 then s = s .. ',' end
          s = s .. tostring(k) .. ' = ' .. dump(v, fulldump)
          cn = cn + 1
        end
      end
    end
    return s .. '}'
  elseif type(o) == 'string' then
    return '"' .. o .. '"'
  else
    return tostring(o)
  end
end

function loadworld()
	local file = love.filesystem.read("world/world.niz")

	if file ~= nil then
		local data = serpent.load(file)
	end
	
	return data
end

function loadlevel(num)
	HACK_INFINITY = HACK_INFINITY + 1
	if HACK_INFINITY > 100 then
		inflooped = true
		love.audio.stop()
		return
	end
	local strnum = tostring(num)
	if mode == "play" then
		levels[levelnum] = deepCopy(runits)
	else 
		levels[levelnum] = deepCopy(units)
	end
	units = levels[strnum] and deepCopy(levels[strnum]) or {}
	runits = levels[strnum] and deepCopy(levels[strnum]) or {}
	levelnum = strnum
	undos = {}
	if mode == "play" then
		parse()
		addundo()
		levelchanged = true
	end
end

function totalvalue(tx,ty)
	local nums = findunit(tx,ty)
	local rtotal = 0
	for i,v in pairs(nums) do
		if texttypes[v.utype] == "num" or texttypes[v.utype] == "numequals" or texttypes[v.utype] == "numop" then
			rtotal = rtotal+v.value
		end
	end
	return rtotal
end

function checkdels()
	for i,chdunit in pairs(units) do
		if (texttypes[chdunit.utype] == "num" or texttypes[chdunit.utype] == "numequals" or texttypes[chdunit.utype] == "numop") and chdunit.utype ~= 23 then
			for i,chdunit2 in pairs(findunit(chdunit.x,chdunit.y)) do
				if chdunit2.utype == 23 and chdunit2.value == chdunit.value then
					table.insert(delthese,chdunit.id)
				end
			end
		end
	end
end

function newbutton(name,text,cfunc) --todo: finish UI
	
	if buttons[name] then return buttons[name] end 
	
	local button = {}
	button[image] = love.graphics.newImage("button.png")
	button[text] = text
	button[cfunc] = cfunc
	
	
end
