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
					if (texttypes[ceunit.utype] == "num" or texttypes[ceunit.utype] == "numop" or texttypes[ceunit.utype] == "numequals") and (ceunit.value == obst.value or (ceunit.utype == 24 and tostring(obst.value) == tostring(levelnum))) then
					
						table.insert(delthese,obstid)
						table.insert(delthese,ceunitid)
						
						table.remove(obsts,i)
						
					else
				
						return
						
					end
				elseif obst.utype == 23 then
					if (texttypes[ceunit.utype] == "num" or texttypes[ceunit.utype] == "numop" or texttypes[ceunit.utype] == "numequals") and (ceunit.value == obst.value or (ceunit.utype == 24 and tostring(obst.value) == tostring(levelnum))) then
					
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
			checkdels()
		end
	end
end














