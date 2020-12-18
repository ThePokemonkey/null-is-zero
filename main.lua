function love.load()

	-- set dimensions of drawing area (canvas)
	can_w=1200
	can_h=900
	
	-- create the canvas and set it's filter to "nearest"
	canvas=love.graphics.newCanvas(can_w,can_h)
	--canvas:setFilter("nearest","nearest")

	-- if this is true, we're only going to scale the graphics to multiples, e.g. 2x, 3x and so on
	-- it doesn't look good on pixelart if we use floating point scales, because
	-- some pixels will appear bigger and some smaller, so lets use it
	scaleonlymultiples=false

	love.window.setMode(500, 500,{resizable = true,fullscreen = false})
	love.window.setTitle("Null Is Zero")
	ico = love.image.newImageData("sprites/plrnonum.png")
	love.window.setIcon(ico)
	
	units = {}
	undos = {}
	runits = {}
	inflooped = false
	HACK_INFINITY = 0
	
	numfont1 = love.graphics.newFont("font.ttf",60)
	numfont2 = love.graphics.newFont("font.ttf",42)
	numfont3 = love.graphics.newFont("font.ttf",30)
	numfont4 = love.graphics.newFont("font.ttf",18)
	numfontNAN = love.graphics.newFont("font.ttf",26)
	
	levelnumfont = love.graphics.newFont("font.ttf",60)
	buttonfont = love.graphics.newFont("font.ttf",30)
	titlefont = love.graphics.newFont("font.ttf",180)
	
	delthese = {}
	levels = {}
	buttons = {}
	
	sfxplaying = {win = false, restart = false, setlevel = false}
	
	mode = "play"
	
	levelnum = "1"
	
	texttypes = {"num",0,"num","op","op","op","op","equals","equals","op",0,0,"num","op","equals","equals","equals","equals","equals",0,"num",0,"num","num"}
	
	numoffsets = {}
	
	doornumfont3 = love.graphics.newFont("font.ttf",28)
	numoffsets[21] = {}
	numoffsets[21][4] = {x = 9, y = 2, limit = 12,r = 0, g = 0, b = 0,font = doornumfont3, ending = 42}
	numoffsets[21][5] = {x = 9, y = 13, limit = 10,r = 0, g = 0, b = 0,font = numfont4}
	
	
	spikenumfont1 = love.graphics.newFont("font.ttf",54)
	spikenumfont2 = love.graphics.newFont("font.ttf",38)
	spikenumfont3 = love.graphics.newFont("font.ttf",26)
	
	numoffsets[23] = {}
	numoffsets[23][1]={x = 9, y = 3, limit = 8,r = 1, g = 1, b = 1,font = spikenumfont1, ending = 42}
	numoffsets[23][2]={x = 9, y = 10, limit = 8,r = 1, g = 1, b = 1,font = spikenumfont2, ending = 42}
	numoffsets[23][3]={x = 9, y = 16, limit = 8,r = 1, g = 1, b = 1,font = spikenumfont3, ending = 42}
	numoffsets[23][4]={x = 16, y = 12, limit = 6,r = 1, g = 1, b = 1,font = numfont4, ending = 30}
	numoffsets[23][5]={x = 16, y = 12, limit = 6,r = 1, g = 1, b = 1,font = numfont4, ending = 30}
	numoffsets[23][6]={x = 16, y = 12, limit = 6,r = 1, g = 1, b = 1,font = numfont4, ending = 30}
	
	objsopen = false
	objorder = {11,12,2,20,0,1,3,13,21,0,4,5,7,6,10,14,0,8,0,22,0,0,0,0,23,0,0,0,0,9,15,16,17,18,19,0,24}
	cutype = 0
	levelchanged = false
	cid = 0
	cimagetype = 0
	
	images = {"plr.png","wall.png","pushable.png","plus.png","minus.png","divide.png","times.png","equals.png","equalscheck.png","exponent.png","plrnonum.png","pushablenonum.png","wallnum.png","modulo.png","lessthan.png","greaterthan.png","lessthanequals.png","greaterthanequals.png","notequals.png","door.png","doornum.png","spike.png","spikenum.png","level.png"}
	sssfx = {win = love.audio.newSource("sfx/win.ogg","static"), restart = love.audio.newSource("sfx/restart.ogg","static"), setlevel = love.audio.newSource("sfx/setlevel.ogg","static")}
	
	objimages = {}
	
	for i,v in pairs(objorder) do
		if v > 0 then
			local objimage = love.graphics.newImage("sprites/"..images[v])
			table.insert(objimages,objimage)
		else
			table.insert(objimages,0)
		end
	end
	
	--texts = {"+","-","/","x","=","==","^"}
	--colors = {{r = 1,g = 0, b = 0.7},{r = 0.25, g = 0.25, b = 0.25},{r = 0.3, g = 0.3, b = 1},{r = 0.8, g = 0.8, b = 0.8},{r = 0.8, g = 0.8, b = 0.8},{r = 0.8, g = 0.8, b = 0.8},{r = 0.8, g = 0.8, b = 0.8},{r = 0.8, g = 0.8, b = 0.8},{r = 0.8, g = 0.8, b = 0.8},{r = 0.8, g = 0.8, b = 0.8}}
	--colors2 = {{r = 1,g = 0.3, b = 1},{r = 0.25, g = 0.25, b = 0.25},{r = 0.45, g = 0.45, b = 1},{r = 1, g = 1, b = 1},{r = 1, g = 1, b = 1},{r = 1, g = 1, b = 1},{r = 1, g = 1, b = 1},{r = 1, g = 1, b = 1},{r = 1, g = 1, b = 1},{r = 1, g = 1, b = 1}}
end

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
		local image = love.graphics.newImage("sprites/"..images[nutype])
		table.insert(units,{utype = nutype,x = nx,y = ny,value = nvalue,image,id = cid+1})
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
		if texttypes[unit.utype] == "op" then return unit end
	end
end

function findeq(sx,sy)
	local units = findunit(sx,sy)
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "equals" then return unit end
	end
end

function findnum(sx,sy)
	local units = findunit(sx,sy)
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "num" then return unit end
	end
end

function findnums(sx,sy)
	local units = findunit(sx,sy)
	local endtable = {}
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "num" then table.insert(endtable,unit) end
	end
	return endtable
end

function findopeq(sx,sy)
	local units = findunit(sx,sy)
	for i,unit in pairs(units) do
		if texttypes[unit.utype] == "equals" or texttypes[unit.utype] == "op" then return unit end
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

function move(unit,mx,my)
	local tx, ty = unit.x + mx, unit.y + my
	
	local pushed = {}
	
	local obsts = findunit(tx,ty)
	local ccx,ccy = tx,ty
	
	local ceunitid = unit.id
	local obstid
	
	local obstgone = false
	
	ceunit = findunitid(ceunitid)
	
	if #obsts > 0 then
		repeat 
			for i,obst in pairs(obsts) do
				obstid = obst.id
				if obst.utype == 2 or obst.utype == 13 then return end
			
				if obst.utype == 1 or obst.utype == 11 then
					ccx,ccy = ccx+mx,ccy+my
					ceunitid = obstid
					obsts = findunit(ccx,ccy)
					
					ceunit = findunitid(ceunitid)
				elseif obst.utype == 20 then
					table.insert(delthese,obstid)
					
					table.insert(delthese,ceunitid)
					
					table.remove(obsts,i)
				elseif obst.utype == 22 then
					
					table.insert(delthese,ceunitid)
					table.remove(obsts,i)
					
				elseif obst.utype == 21 then
					if texttypes[ceunit.utype] == "num" and (ceunit.value == obst.value or (ceunit.utype == 24 and tostring(obst.value) == tostring(levelnum))) then
					
						table.insert(delthese,obstid)
						table.insert(delthese,ceunitid)
						
						table.remove(obsts,i)
						
					else
				
						return
						
					end
				elseif obst.utype == 23 then
					if texttypes[ceunit.utype] == "num" and (ceunit.value == obst.value or (ceunit.utype == 24 and tostring(obst.value) == tostring(levelnum))) then
					
						table.insert(delthese,ceunitid)
						
					end
					table.remove(obsts,i)
				else
					table.insert(pushed,obst)
					ccx,ccy = ccx+mx,ccy+my
					ceunitid = obstid
					obsts = findunit(ccx,ccy)
					ceunit = findunitid(ceunitid)
				end
			end
			
			if not inbounds(ccx,ccy) then return end
			
		until #obsts == 0 or obstgone
	end
	
	if inbounds(tx,ty) then
		for i,punit in pairs(pushed) do
			punit.x = punit.x + mx
			punit.y = punit.y + my
			
			if not pushplayed and #delthese == 0 then
				playsfx("push")
				pushplayed = true
			end
			
		end
		
		
		if not moveplayed and not pushplayed and #delthese == 0 then
			playsfx("move")
			moveplayed = true
		end
		
		if unit then
			unit.x,unit.y = tx,ty
		end
	end
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
		if texttypes[v.utype] == "num" then
			rtotal = rtotal+v.value
		end
	end
	return rtotal
end

function checkdels()
	for i,chdunit in pairs(units) do
		if texttypes[chdunit.utype] == "num" and chdunit.utype ~= 23 then
			for i,chdunit2 in pairs(findunit(chdunit.x,chdunit.y)) do
				if chdunit2.utype == 23 and chdunit2.value == chdunit.value then
					table.insert(delthese,chdunit.id)
				end
			end
		end
	end
end

function parse()

	local vchange = false

	for i,chunit in pairs(units) do
		
		chunitvalue = totalvalue(chunit.x,chunit.y)
		
		if texttypes[chunit.utype] == "num" then
		
			local op = findopeq(chunit.x+1,chunit.y)
			
			if op and texttypes[op.utype] == "equals" then
				local findop = findop(chunit.x-1,chunit.y)
				local findop2 = findnum(chunit.x-2,chunit.y)
				
				if not findop or not findop2 then
					
					local findnum2 = findnum(chunit.x+2,chunit.y)
					
					if findnum2 then
						
						local num2s = findnums(chunit.x+2,chunit.y)
						local num2 = totalvalue(chunit.x+2,chunit.y)
						
						if op.utype == 8 then
							for i,inum2 in pairs(num2s) do
								if inum2.utype == 24 then
									loadlevel(chunitvalue)
									playsfx("setlevel")
									return
								end
								if tostring(inum2.value) ~= tostring(chunitvalue) then
									vchange = true
									inum2.value = chunitvalue
								end
							end
						elseif op.utype == 9 and chunitvalue == num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif op.utype == 15 and chunitvalue < num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif op.utype == 16 and chunitvalue > num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif op.utype == 17 and chunitvalue <= num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif op.utype == 18 and chunitvalue >= num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif op.utype == 19 and chunitvalue ~= num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						end
					end
				end
				
			elseif op and (texttypes[op.utype] == "op") then
			
				local num2s = findnums(chunit.x+2,chunit.y)
				num2 = totalvalue(chunit.x+2,chunit.y)
				
				if #num2s > 0 then
				
					local equals = findeq(chunit.x+3,chunit.y)
					
					if equals then
					
						local num3s = findnums(chunit.x+4,chunit.y)
						num3 = totalvalue(chunit.x+4,chunit.y)
						
						if #num3s > 0 then
						
							if equals.utype == 8 then
								if op.utype == 4 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											loadlevel(chunitvalue+num2)
											playsfx("setlevel")
											return
										end
										if tostring(inum3.value) ~= tostring(chunitvalue+num2) then
											vchange = true
											inum3.value = chunitvalue+num2
										end
									end
								elseif op.utype == 5 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											loadlevel(chunitvalue-num2)
											playsfx("setlevel")
											return
										end
										if tostring(inum3.value) ~= tostring(chunitvalue-num2) then
											vchange = true
											inum3.value = chunitvalue-num2
										end
									end
								elseif op.utype == 6 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											loadlevel(chunitvalue/num2)
											playsfx("setlevel")
											return
										end
										if tostring(inum3.value) ~= tostring(chunitvalue/num2) then
											vchange = true
											inum3.value = chunitvalue/num2
										end
									end
								elseif op.utype == 7 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											loadlevel(chunitvalue*num2)
											playsfx("setlevel")
											return
										end
										if tostring(inum3.value) ~= tostring(chunitvalue*num2) then
											vchange = true
											inum3.value = chunitvalue*num2
										end
									end
								elseif op.utype == 10 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											if chunitvalue == 0 and num2 == 0 then
												loadlevel(0/0)
											else
												loadlevel(chunitvalue^num2)
											end
											playsfx("setlevel")
											return
										end
										if tostring(inum3.value) ~= tostring(chunitvalue^num2) and (chunitvalue == 0 and num2 == 0 and tostring(inum3.value) ~= "nan") then
											vchange = true
											inum3.value = chunitvalue^num2
											if chunitvalue == 0 and num2 == 0 then inum3.value = 0/0 end
										end
									end
								elseif op.utype == 14 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											loadlevel(chunitvalue%num2)
											playsfx("setlevel")
											return
										end
										if tostring(inum3.value) ~= tostring(chunitvalue%num2) then
											vchange = true
											inum3.value = chunitvalue%num2
										end
									end
								end
							elseif equals.utype == 9 then
								if op.utype == 4 and chunitvalue + num2 == num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 5 and num3 == chunitvalue-num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 6 and num3 == chunitvalue/num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 7 and num3 == chunitvalue*num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 10 and (num3 == chunitvalue^num2 or (chunitvalue == 0 and num2 == 0 and num3 == 0/0)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif op.utype == 14 and num3 == chunitvalue%num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 15 then
								if op.utype == 4 and chunitvalue + num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 5 and  chunitvalue-num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 6 and chunitvalue/num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 7 and chunitvalue*num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 10 and (chunitvalue^num2 < num3 or (chunitvalue == 0 and num2 == 0 and 0/0 < num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif op.utype == 14 and chunitvalue%num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 16 then
								if op.utype == 4 and chunitvalue + num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 5 and  chunitvalue-num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 6 and chunitvalue/num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 7 and chunitvalue*num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 10 and (chunitvalue^num2 > num3 or (chunitvalue == 0 and num2 == 0 and 0/0 > num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif op.utype == 14 and chunitvalue%num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 17 then
								if op.utype == 4 and chunitvalue + num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 5 and  chunitvalue-num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 6 and chunitvalue/num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 7 and chunitvalue*num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 10 and (chunitvalue^num2 <= num3 or (chunitvalue == 0 and num2 == 0 and 0/0 <= num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif op.utype == 14 and chunitvalue%num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 18 then
								if op.utype == 4 and chunitvalue + num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 5 and  chunitvalue-num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 6 and chunitvalue/num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 7 and chunitvalue*num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 10 and (chunitvalue^num2 >= num3 or (chunitvalue == 0 and num2 == 0 and 0/0 >= num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif op.utype == 14 and chunitvalue%num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 19 then
								if op.utype == 4 and chunitvalue + num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 5 and  chunitvalue-num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 6 and chunitvalue/num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 7 and chunitvalue*num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif op.utype == 10 and (chunitvalue^num2 ~= num3 or (chunitvalue == 0 and num2 == 0 and 0/0 ~= num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif op.utype == 14 and chunitvalue%num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							end
						end
						
					end
					
				end
			end
			
		end
	end
	
	if vchange then
		checkdels()
		parse()
	end
	
end

function love.mousepressed(mx,my,bt)
	if not ofs_x and not ofs_y then return end
	mx = math.floor((love.mouse.getX()-ofs_x)/scale)
	my = math.floor((love.mouse.getY()-ofs_y)/scale)
	
	tx = math.floor(mx/60)
	ty = math.floor(my/60)
	
	if inbounds(tx,ty) and mode == "edit" then else return end
	
	if bt == 1 and not objsopen then
		breakunit(tx,ty)
		makeunit(cutype,tx,ty)
	elseif bt == 1 then
		local objindex = tx+(19*(ty-1))
		if objorder[objindex] then
			cutype = objorder[objindex]
			objsopen = false
		else
			cutype = 0
			objsopen = false
		end
	elseif bt == 2 then
		local tunit = findunit(tx,ty)[1]
		if tunit then
			cutype = tunit.utype
		else
			cutype = 0
		end
	end
end

function love.keypressed(k)

	if k == "m" then
		if mode == "play" then
			HACK_INFINITY = 0
			inflooped = false
			units = deepCopy(runits)
			mode = "edit"
		elseif mode == "edit" then 
			runits = deepCopy(units)
			HACK_INFINITY = 0
			inflooped = false
			objsopen = false
			mode = "play"
			undos = {}
			parse()
			addundo()
		end
	end
	
	if k == "r" and mode == "play" then
	
		playsfx("restart")
		
		units = deepCopy(runits)
		undos = {}
		parse()
		addundo()
		
	end
	
	if k == "z" and mode == "play" then
	
		if #undos > 1 then
		
			playsfx("undo")
			
			units = deepCopy(undos[#undos-1])
			table.remove(undos,#undos)
			
			deldels()
			parse()
			
		end
		
	end
	
	if k == "escape" then love.event.push("quit") end
	
	if mode == "play" and not inflooped then
		for i,unit in pairs(units) do
			if unit.utype == 1 or unit.utype == 11 then	
				if k == "up" or k == "w" then
					move(unit,0,-1)
				elseif k == "down" or k == "s" then
					move(unit,0,1)
				elseif k == "right" or k == "d" then
					move(unit,1,0)
				elseif k == "left" or k == "a" then
					move(unit,-1,0)
				end
			end
		end	
		
		if k == "up" or k == "w" or k == "down" or k == "s" or k == "right" or k == "a" or k == "left" or k == "d" then
			HACK_INFINITY = 0
			deldels()
			parse()
			deldels()
			if not levelchanged then
				addundo()
			end
			levelchanged = false
		end
		moveplayed = false
		pushplayed = false
		destroyplayed = false
	elseif mode == "edit" then
		if objsopen == false then
			if k == "=" then
				mx = math.floor((love.mouse.getX()-ofs_x)/scale)
				my = math.floor((love.mouse.getY()-ofs_y)/scale)
				
				tx = math.floor(mx/60)
				ty = math.floor(my/60)
				
				local inc = findunit(tx,ty)[1]
				
				if inc and texttypes[inc.utype] == "num" then
					inc.value = inc.value+1
				end
			end
			
			if k == "-" then
				mx = math.floor((love.mouse.getX()-ofs_x)/scale)
				my = math.floor((love.mouse.getY()-ofs_y)/scale)
				
				tx = math.floor(mx/60)
				ty = math.floor(my/60)
				
				local dec = findunit(tx,ty)[1]
				if dec and texttypes[dec.utype] == "num" then
					dec.value = dec.value-1
				end
			end
			
			if k == "v" then
				mx = math.floor((love.mouse.getX()-ofs_x)/scale)
				my = math.floor((love.mouse.getY()-ofs_y)/scale)
				
				tx = math.floor(mx/60)
				ty = math.floor(my/60)
				
				local paste = findunit(tx,ty)[1]
				
				if paste and texttypes[paste.utype] == "num" then
					local val = tonumber(love.system.getClipboardText())
					if val == nil then val = 0/0 end
					paste.value = val
				end
			end
			
		else
			if k == "=" then
				loadlevel(levelnum+1)
			end
			
			if k == "-" then
				loadlevel(levelnum-1)
			end
		end
		
		if k == "tab" then
			objsopen = not objsopen
		end
		
	end
end

function newbutton(name,text,cfunc)
	
	if buttons[name] then return buttons[name] end 
	
	local button = {}
	button[image] = love.graphics.newImage("button.png")
	button[text] = text
	button[cfunc] = cfunc
	
	
end


function love.draw()

	-- get the dimensions of the current screenmode
	win_w,win_h=love.window.getMode()
	
	-- calculate aspect ratios of window and canvas
	win_asp=win_w/win_h
	can_asp=can_w/can_h
	
	-- let's compare the aspects to determine the way how to scale and center
	if win_asp<can_asp then
		-- if the window's aspect is smaller than the canvas' then it means that we
		-- need to center the canvas vertically
		scale = win_w/can_w
		ofs_x = 0
		ofs_y = (win_h-can_h*scale)/2
	else
		-- otherwise we have to center the canvas horizontally
		scale = win_h/can_h
		ofs_x = (win_w-can_w*scale)/2
		ofs_y = 0
	end
 
	-- we want scaling only to happen for multiples? fine!
	if scaleonlymultiples then
		-- trim the scaling factor down to nearest whole number
		scale=math.floor(scale)
	
		-- but don't scale less than 1
		if scale<1 then scale=1 end
	
		-- now we probably need to center in both directions, lets calculate the distances
		gap_h=win_w-can_w*scale
		if gap_h>0 then ofs_x=gap_h/2 end
		
		gap_v=win_h-can_h*scale
		if gap_v>0 then ofs_y=gap_v/2 end
	end
	
	
	-- all drawing should happen on canvas instead of screen
	love.graphics.setCanvas(canvas)
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")
	
	if not objsopen then
		for i,unit in pairs(units) do
			local utype = unit.utype
			
			love.graphics.setColor(1, 1, 1)
			
			if not unit.image then unit.image = love.graphics.newImage("sprites/"..images[utype]) end
			
			love.graphics.draw(unit.image, unit.x*60, unit.y*60)
			
			if texttypes[unit.utype] == "num" and unit.utype ~= 24 then
				
					love.graphics.setColor(0,0,0)
					
					if tostring(unit.value) == "nan" then
						if numoffsets[unit.utype] and numoffsets[unit.utype][6] then
							local offsettable = numoffsets[unit.utype][6]
							love.graphics.setFont(offsettable.font)
							love.graphics.setColor(offsettable.r,offsettable.g,offsettable.b)
							love.graphics.printf(string.sub(tostring(unit.value),1,offsettable.limit), unit.x*60+offsettable.x, unit.y*60+offsettable.y,offsettable.ending,"center") 
						else
							love.graphics.setFont(numfontNAN)
							love.graphics.printf(tostring(unit.value), unit.x*60+10, unit.y*60+15,42,"center")
						end
					elseif #tostring(unit.value) == 1 then
						if numoffsets[unit.utype] and numoffsets[unit.utype][1] then
							local offsettable = numoffsets[unit.utype][1]
							love.graphics.setFont(offsettable.font)
							love.graphics.setColor(offsettable.r,offsettable.g,offsettable.b)
							love.graphics.printf(string.sub(tostring(unit.value),1,offsettable.limit), unit.x*60+offsettable.x, unit.y*60+offsettable.y,offsettable.ending,"center") 
						else
							love.graphics.setFont(numfont1)
							love.graphics.printf(tostring(unit.value), unit.x*60+10, unit.y*60,42,"center") 
						end
					elseif #tostring(unit.value) == 2 then
						if numoffsets[unit.utype] and numoffsets[unit.utype][2] then
							local offsettable = numoffsets[unit.utype][2]
							love.graphics.setFont(offsettable.font)
							love.graphics.setColor(offsettable.r,offsettable.g,offsettable.b)
							love.graphics.printf(string.sub(tostring(unit.value),1,offsettable.limit), unit.x*60+offsettable.x, unit.y*60+offsettable.y,offsettable.ending,"center") 
						else
							love.graphics.setFont(numfont2)
							love.graphics.printf(tostring(unit.value), unit.x*60+10, unit.y*60+9,42,"center")
						end
					elseif #tostring(unit.value) == 3 then
						if numoffsets[unit.utype] and numoffsets[unit.utype][3] then
							local offsettable = numoffsets[unit.utype][3]
							love.graphics.setFont(offsettable.font)
							love.graphics.setColor(offsettable.r,offsettable.g,offsettable.b)
							love.graphics.printf(string.sub(tostring(unit.value),1,offsettable.limit), unit.x*60+offsettable.x, unit.y*60+offsettable.y,offsettable.ending,"center") 
						else
							love.graphics.setFont(numfont3)
							love.graphics.printf(tostring(unit.value), unit.x*60+10, unit.y*60+15,42,"center")
						end
					elseif #tostring(unit.value) < 7 then
						if numoffsets[unit.utype] and numoffsets[unit.utype][4] then
							local offsettable = numoffsets[unit.utype][4]
							love.graphics.setFont(offsettable.font)
							love.graphics.setColor(offsettable.r,offsettable.g,offsettable.b)
							love.graphics.printf(string.sub(tostring(unit.value),1,offsettable.limit), unit.x*60+offsettable.x, unit.y*60+offsettable.y,offsettable.ending,"center") 
						else
							love.graphics.setFont(numfont3)
							love.graphics.printf(tostring(unit.value), unit.x*60+9, unit.y*60,42,"center")
						end
					else
						if numoffsets[unit.utype] and numoffsets[unit.utype][5] then
							local offsettable = numoffsets[unit.utype][5]
							love.graphics.setFont(offsettable.font)
							love.graphics.setColor(offsettable.r,offsettable.g,offsettable.b)
							love.graphics.printf(string.sub(tostring(unit.value),1,offsettable.limit), unit.x*60+offsettable.x, unit.y*60+offsettable.y,offsettable.ending,"center") 
						else
							love.graphics.setFont(numfont4)
							love.graphics.printf(string.sub(tostring(unit.value),1,15), unit.x*60+9, unit.y*60+3,42,"center")
						end
					end
					
			end
		end
	else
		love.graphics.setColor(1, 1, 1)
		for i,v in pairs(objimages) do
			if v ~= 0 then
				love.graphics.draw(v, (i%19)*60, ((math.floor(i/19))+1)*60)
			end
		end
	end
	
	if mode == "edit" and cutype > 0 and not objsopen then
		mx = math.floor((love.mouse.getX()-ofs_x)/scale)
		my = math.floor((love.mouse.getY()-ofs_y)/scale)
		love.graphics.setColor(1, 1, 1,0.2)
		if cimagetype ~= cutype then
			cimage = love.graphics.newImage("sprites/"..images[cutype])
			cimagetype = cutype
		end
		love.graphics.draw(cimage, math.floor(mx/60)*60, math.floor(my/60)*60)
	end
	
	if inflooped then
		love.graphics.clear()
		love.graphics.setColor(1, 0, 0.6)
		love.graphics.setFont(titlefont)
		love.graphics.print("Infinite Loop", 120, 360)
	end
	
	love.graphics.setColor(0.1, 0.1, 0.2)
	love.graphics.rectangle("fill", 0, 0, 1200,60)
	love.graphics.rectangle("fill", 0, 840, 1200,60)
	love.graphics.rectangle("fill", 0, 0, 60,900)
	love.graphics.rectangle("fill", 1140, 0, 60,900)
	
	if mode ~= "title" then
		love.graphics.setFont(levelnumfont)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(levelnum, 10, 0)
	end
	
	if mode == "title" then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(titlefont)
		love.graphics.print("Null Is Zero", 180, 120)
	end
	
	
	
	
	
	-- switch all drawing operations to screen
	love.graphics.setCanvas()
	love.graphics.clear()
	
	-- we use "premultiplied" blending which is needed for correct behaviour of transparency
	love.graphics.setBlendMode("alpha","premultiplied")
	
	-- we set foreground color to white and clear the screen with black
	love.graphics.setColor(1,1,1,1)

	-- copy scaled and translated canvas to screen
	love.graphics.draw(canvas,ofs_x,ofs_y,0,scale)
	
end

















