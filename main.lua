function love.load()
	love.window.setMode(1200, 900)
	love.window.setTitle("Null Is Zero")
	units = {}
	undos = {}
	runits = {}
	delthese = {}
	mode = "play"
	levelnum = 1
	texttypes = {"num",0,"num","op","op","op","op","equals","equals","op",0,0,"num","op","equals","equals","equals","equals","equals",0,"num",0,"num"}
	numoffsets = {}
	numoffsets[21] = {x = 4, y = 2, limit = 12,r = 0, g = 0, b = 0}
	numoffsets[23] = {x = 4, y = 8, limit = 8,r = 1, g = 1, b = 1}
	objsopen = false
	objorder = {11,12,2,20,0,1,3,13,21,0,4,5,7,6,10,14,0,8,0,22,0,0,0,0,23,0,0,0,0,9,15,16,17,18,19}
	cutype = 0
	cid = 0
	cimagetype = 0
	images = {"plr.png","wall.png","pushable.png","plus.png","minus.png","divide.png","times.png","equals.png","equalscheck.png","exponent.png","plrnonum.png","pushablenonum.png","wallnum.png","modulo.png","lessthan.png","greaterthan.png","lessthanequals.png","greaterthanequals.png","notequals.png","door.png","doornum.png","spike.png","spikenum.png"}
	objimages = {}
	
	for i,v in pairs(objorder) do
		if v > 0 then
			local objimage = love.graphics.newImage(images[v])
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
	sfx = love.audio.newSource(name..".ogg","static")
	love.audio.play(sfx)
	sfx = nil
end

function makeunit(nutype,nx,ny,nvalue)
	if nutype > 0 then
		local image = love.graphics.newImage(images[nutype])
		table.insert(units,{utype = nutype,x = nx,y = ny,value = 0,image,id = cid+1})
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
					if texttypes[ceunit.utype] == "num" and ceunit.value == obst.value then
					
						table.insert(delthese,obstid)
						table.insert(delthese,ceunitid)
						
						table.remove(obsts,i)
						
					else
				
						return
						
					end
				elseif obst.utype == 23 then
					if texttypes[ceunit.utype] == "num" and ceunit.value == obst.value then
					
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
	--temp code to cause restart
	units = deepCopy(runits)
	undos = {}
	addundo()
	parse()
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

function parse()
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
								inum2.value = chunitvalue
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
										inum3.value = chunitvalue+num2
									end
								elseif op.utype == 5 then
									for i,inum3 in pairs(num3s) do
										inum3.value = chunitvalue-num2
									end
								elseif op.utype == 6 then
									for i,inum3 in pairs(num3s) do
										inum3.value = chunitvalue/num2
									end
								elseif op.utype == 7 then
									for i,inum3 in pairs(num3s) do
										inum3.value = chunitvalue*num2
									end
								elseif op.utype == 10 then
									for i,inum3 in pairs(num3s) do
										inum3.value = chunitvalue^num2
										if chunitvalue == 0 and num2 == 0 then inum3.value = 0/0 end
									end
								elseif op.utype == 14 then
									for i,inum3 in pairs(num3s) do
										inum3.value = chunitvalue%num2
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
end

function love.mousepressed(mx,my,bt)
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
			units = deepCopy(runits)
			mode = "edit"
		else 
			runits = deepCopy(units)
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
	
	if mode == "play" then
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
			deldels()
			parse()
			addundo()
		end
		moveplayed = false
		pushplayed = false
		destroyplayed = false
	elseif mode == "edit" then
	
		if k == "=" then
			local mx,my = love.mouse.getPosition()
			tx = math.floor(mx/60)
			ty = math.floor(my/60)
			
			local inc = findunit(tx,ty)[1]
			
			if inc and texttypes[inc.utype] == "num" then
				inc.value = inc.value+1
			end
		end
		
		if k == "-" then
			local mx,my = love.mouse.getPosition()
			tx = math.floor(mx/60)
			ty = math.floor(my/60)
			
			local dec = findunit(tx,ty)[1]
			if dec and texttypes[dec.utype] == "num" then
				dec.value = dec.value-1
			end
		end
		
		if k == "tab" then
			objsopen = not objsopen
		end
		
	end
	
	
end

function love.draw()
	
	if not objsopen then
		for i,unit in pairs(units) do
			local utype = unit.utype
			
			love.graphics.setColor(1, 1, 1)
			
			if not unit.image then unit.image = love.graphics.newImage(images[utype]) end
			
			love.graphics.draw(unit.image, unit.x*60, unit.y*60)
			
			if texttypes[unit.utype] == "num" then
			
				if numoffsets[unit.utype] then
					offset = numoffsets[unit.utype]
					love.graphics.setColor(offset.r,offset.b,offset.g)
					love.graphics.printf(tostring(string.sub(unit.value,1,offset.limit)), unit.x*60+7+offset.x, unit.y*60+5+offset.y,(42-(2*offset.x)),"center")
				else
					love.graphics.setColor(0,0,0)
					love.graphics.printf(tostring(string.sub(unit.value,1,15)), unit.x*60+7, unit.y*60+5,42,"center")
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
		mx, my = love.mouse.getPosition()
		love.graphics.setColor(1, 1, 1,0.2)
		if cimagetype ~= cutype then
			cimage = love.graphics.newImage(images[cutype])
			cimagetype = cutype
		end
		love.graphics.draw(cimage, math.floor(mx/60)*60, math.floor(my/60)*60)
	end
	
	love.graphics.setColor(0.1, 0.1, 0.2)
	love.graphics.rectangle("fill", 0, 0, 1200,60)
	love.graphics.rectangle("fill", 0, 840, 1200,60)
	love.graphics.rectangle("fill", 0, 0, 60,900)
	love.graphics.rectangle("fill", 1140, 0, 60,900)
end