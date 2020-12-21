function parse()

	PHACK_INFINITY = PHACK_INFINITY + 1
	if PHACK_INFINITY == 1 then
		infx = x
		infy = y
		infz = z
	elseif PHACK_INFINITY > 250 then
		inflooped = true
		playsfx("setlevel")
		x = infx
		y = infy
		z = infz
		return
	end
	
	local vchange = false
	
	local levelsetunits = {}
	local levelsetvalue = 0
	local lschange = false
	
	local xsetunits = {}
	local xsetvalue = 0
	local xchange = false
	
	local ysetunits = {}
	local ysetvalue = 0
	local ychange = false
	
	local zsetunits = {}
	local zsetvalue = 0
	local zchange = false
	
	for i,chunit in pairs(units) do
		
		chunitvalue = totalvalue(chunit.x,chunit.y)
		
		if texttypes[chunit.utype] == "num" or texttypes[chunit.utype] == "numop" or texttypes[chunit.utype] == "numequals" then
		
			local op = findopeq(chunit.x+1,chunit.y)
			
			if op and (texttypes[op.utype] == "equals" or texttypes[op.utype] == "numequals") then
				local findop = findop(chunit.x-1,chunit.y)
				local findop2 = findnum(chunit.x-2,chunit.y)
				
				if not findop or not findop2 then
					
					local findnum2 = findnum(chunit.x+2,chunit.y)
					
					if findnum2 then
						
						local num2s = findnums(chunit.x+2,chunit.y)
						local num2 = totalvalue(chunit.x+2,chunit.y)
						
						if op.utype == 8 or op.utype == 31 then
							for i,inum2 in pairs(num2s) do
								if inum2.utype == 24 then
									
									local newlsunit = true
									
									for i,v in pairs(levelsetunits) do
										if v.x == chunit.x and v.y == chunit.y then
											newlsunit = false
										end
									end
									
									if newlsunit then
										table.insert(levelsetunits,{x = chunit.x, y = chunit.y})
										levelsetvalue = levelsetvalue + chunitvalue
										lschange = true
									end
									
								elseif inum2.utype == 38 then
									
									local newxunit = true
									
									for i,v in pairs(xsetunits) do
										if v.x == chunit.x and v.y == chunit.y then
											newxunit = false
										end
									end
									
									if newxunit then
										table.insert(xsetunits,{x = chunit.x, y = chunit.y})
										xsetvalue = xsetvalue + chunitvalue
										xchange = true
									end
									
								elseif inum2.utype == 39 then
									
									local newyunit = true
									
									for i,v in pairs(ysetunits) do
										if v.x == chunit.x and v.y == chunit.y then
											newyunit = false
										end
									end
									
									if newyunit then
										table.insert(ysetunits,{x = chunit.x, y = chunit.y})
										ysetvalue = ysetvalue + chunitvalue
										ychange = true
									end
									
								elseif inum2.utype == 40 then
									
									local newzunit = true
									
									for i,v in pairs(zsetunits) do
										if v.x == chunit.x and v.y == chunit.y then
											newzunit = false
										end
									end
									
									if newzunit then
										table.insert(zsetunits,{x = chunit.x, y = chunit.y})
										zsetvalue = zsetvalue + chunitvalue
										zchange = true
									end
									
								elseif tostring(inum2.value) ~= tostring(chunitvalue) then
									vchange = true
									inum2.value = chunitvalue
								end
							end
						elseif (op.utype == 9 or op.utype == 32) and chunitvalue == num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif (op.utype == 15 or op.utype == 33) and chunitvalue < num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif (op.utype == 16 or op.utype == 34) and chunitvalue > num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif (op.utype == 17 or op.utype == 35) and chunitvalue <= num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif (op.utype == 18 or op.utype == 36) and chunitvalue >= num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						elseif (op.utype == 19 or op.utype == 37) and chunitvalue ~= num2 then
							loadlevel(levelnum+1)
							
							playsfx("win")
						end
					end
				end
				
			elseif op and (texttypes[op.utype] == "op" or texttypes[op.utype] == "numop") then
			
				local num2s = findnums(chunit.x+2,chunit.y)
				num2 = totalvalue(chunit.x+2,chunit.y)
				
				if #num2s > 0 then
				
					local equals = findeq(chunit.x+3,chunit.y)
					
					if equals then
					
						local num3s = findnums(chunit.x+4,chunit.y)
						num3 = totalvalue(chunit.x+4,chunit.y)
						
						if #num3s > 0 then
						
							if equals.utype == 8 or equals.utype == 31 then
								if op.utype == 4 or op.utype == 25 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											local newlsunit = true
									
											for i,v in pairs(levelsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newlsunit = false
												end
											end
									
											if newxunit then
												table.insert(levelsetunits,{x = chunit.x, y = chunit.y})
												levelsetvalue = levelsetvalue + (chunitvalue+num2)
												lschange = true
											end
										elseif inum3.utype == 38 then
											
											local newxunit = true
											
											for i,v in pairs(xsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newxunit = false
												end
											end
											
											if newxunit then
												table.insert(xsetunits,{x = chunit.x, y = chunit.y})
												xsetvalue = xsetvalue + (chunitvalue+num2)
												xchange = true
											end
											
										elseif inum3.utype == 39 then
											
											local newyunit = true
											
											for i,v in pairs(ysetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newyunit = false
												end
											end
											
											if newyunit then
												table.insert(ysetunits,{x = chunit.x, y = chunit.y})
												ysetvalue = ysetvalue + (chunitvalue+num2)
												ychange = true
											end
											
										elseif inum3.utype == 40 then
											
											local newzunit = true
											
											for i,v in pairs(zsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newzunit = false
												end
											end
											
											if newzunit then
												table.insert(zsetunits,{x = chunit.x, y = chunit.y})
												zsetvalue = zsetvalue + (chunitvalue+num2)
												zchange = true
											end
											
										elseif tostring(inum3.value) ~= tostring(chunitvalue+num2) then
											vchange = true
											inum3.value = chunitvalue+num2
										end
									end
								elseif op.utype == 5 or op.utype == 26 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											local newlsunit = true
									
											for i,v in pairs(levelsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newlsunit = false
												end
											end
									
											if newlsunit then
												table.insert(levelsetunits,{x = chunit.x, y = chunit.y})
												levelsetvalue = levelsetvalue + (chunitvalue-num2)
												lschange = true
											end
										elseif inum3.utype == 38 then
											
											local newxunit = true
											
											for i,v in pairs(xsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newxunit = false
												end
											end
											
											if newxunit then
												table.insert(xsetunits,{x = chunit.x, y = chunit.y})
												xsetvalue = xsetvalue + (chunitvalue-num2)
												xchange = true
											end
											
										elseif inum3.utype == 39 then
											
											local newyunit = true
											
											for i,v in pairs(ysetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newyunit = false
												end
											end
											
											if newyunit then
												table.insert(ysetunits,{x = chunit.x, y = chunit.y})
												ysetvalue = ysetvalue + (chunitvalue-num2)
												ychange = true
											end
											
										elseif inum3.utype == 40 then
											
											local newzunit = true
											
											for i,v in pairs(zsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newzunit = false
												end
											end
											
											if newzunit then
												table.insert(zsetunits,{x = chunit.x, y = chunit.y})
												zsetvalue = zsetvalue + (chunitvalue-num2)
												zchange = true
											end
											
										elseif tostring(inum3.value) ~= tostring(chunitvalue-num2) then
											vchange = true
											inum3.value = chunitvalue-num2
										end
									end
								elseif op.utype == 6 or op.utype == 28 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											local newlsunit = true
									
											for i,v in pairs(levelsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newlsunit = false
												end
											end
									
											if newlsunit then
												table.insert(levelsetunits,{x = chunit.x, y = chunit.y})
												levelsetvalue = levelsetvalue + (chunitvalue/num2)
												lschange = true
											end
										elseif inum3.utype == 38 then
											
											local newxunit = true
											
											for i,v in pairs(xsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newxunit = false
												end
											end
											
											if newxunit then
												table.insert(xsetunits,{x = chunit.x, y = chunit.y})
												xsetvalue = xsetvalue + (chunitvalue/num2)
												xchange = true
											end
										elseif inum3.utype == 39 then
											
											local newyunit = true
											
											for i,v in pairs(ysetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newyunit = false
												end
											end
											
											if newyunit then
												table.insert(ysetunits,{x = chunit.x, y = chunit.y})
												ysetvalue = ysetvalue + (chunitvalue/num2)
												ychange = true
											end
										
										elseif inum3.utype == 40 then
											
											local newzunit = true
											
											for i,v in pairs(zsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newzunit = false
												end
											end
											
											if newzunit then
												table.insert(zsetunits,{x = chunit.x, y = chunit.y})
												zsetvalue = zsetvalue + (chunitvalue/num2)
												zchange = true
											end
											
										elseif tostring(inum3.value) ~= tostring(chunitvalue/num2) then
											vchange = true
											inum3.value = chunitvalue/num2
										end
									end
								elseif op.utype == 7 or op.utype == 27 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											local newlsunit = true
									
											for i,v in pairs(levelsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newlsunit = false
												end
											end
									
											if newlsunit then
												table.insert(levelsetunits,{x = chunit.x, y = chunit.y})
												levelsetvalue = levelsetvalue + (chunitvalue*num2)
												lschange = true
											end
										elseif inum3.utype == 38 then
											
											local newxunit = true
											
											for i,v in pairs(xsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newxunit = false
												end
											end
											
											if newxunit then
												table.insert(xsetunits,{x = chunit.x, y = chunit.y})
												xsetvalue = xsetvalue + (chunitvalue*num2)
												xchange = true
											end
										elseif inum3.utype == 39 then
											
											local newyunit = true
											
											for i,v in pairs(ysetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newyunit = false
												end
											end
											
											if newyunit then
												table.insert(ysetunits,{x = chunit.x, y = chunit.y})
												ysetvalue = ysetvalue + (chunitvalue*num2)
												ychange = true
											end
											
										elseif inum3.utype == 40 then
											
											local newzunit = true
											
											for i,v in pairs(zsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newzunit = false
												end
											end
											
											if newzunit then
												table.insert(zsetunits,{x = chunit.x, y = chunit.y})
												zsetvalue = zsetvalue + (chunitvalue*num2)
												zchange = true
											end
											
										elseif tostring(inum3.value) ~= tostring(chunitvalue*num2) then
											vchange = true
											inum3.value = chunitvalue*num2
										end
									end
								elseif op.utype == 10 or op.utype == 29 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											local newlsunit = true
									
											for i,v in pairs(levelsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newlsunit = false
												end
											end
									
											if newlsunit then
												table.insert(levelsetunits,{x = chunit.x, y = chunit.y})
												if chunitvalue == 0 and num2 == 0 then
													levelsetvalue = 0/0
												else
													levelsetvalue = levelsetvalue + (chunitvalue^num2)
												end
												lschange = true
											end
										elseif inum3.utype == 38 then
											
											local newxunit = true
											
											for i,v in pairs(xsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newxunit = false
												end
											end
											
											if newxunit then
												table.insert(xsetunits,{x = chunit.x, y = chunit.y})
												if chunitvalue == 0 and num2 == 0 then
													xsetvalue = 0/0
												else
													xsetvalue = xsetvalue + (chunitvalue^num2)
												end
												xchange = true
											end
										elseif inum3.utype == 39 then
											
											local newyunit = true
											
											for i,v in pairs(ysetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newyunit = false
												end
											end
											
											if newyunit then
												table.insert(ysetunits,{x = chunit.x, y = chunit.y})
												if chunitvalue == 0 and num2 == 0 then
													ysetvalue = 0/0
												else
													ysetvalue = ysetvalue + (chunitvalue^num2)
												end
												ychange = true
											end
											
										elseif inum3.utype == 40 then
											
											local newzunit = true
											
											for i,v in pairs(zsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newzunit = false
												end
											end
											
											if newzunit then
												table.insert(zsetunits,{x = chunit.x, y = chunit.y})
												if chunitvalue == 0 and num2 == 0 then
													zsetvalue = 0/0
												else
													zsetvalue = zsetvalue + (chunitvalue^num2)
												end
												zchange = true
											end
											
										elseif (tostring(inum3.value) ~= tostring(chunitvalue^num2) and not (chunitvalue == 0 and num2 == 0)) or (chunitvalue == 0 and num2 == 0 and tostring(inum3.value) ~= "nan") then
											vchange = true
											inum3.value = chunitvalue^num2
											if chunitvalue == 0 and num2 == 0 then inum3.value = 0/0 end
										end
									end
								elseif op.utype == 14 or op.utype == 30 then
									for i,inum3 in pairs(num3s) do
										if inum3.utype == 24 then
											local newlsunit = true
									
											for i,v in pairs(levelsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newlsunit = false
												end
											end
									
											if newlsunit then
												table.insert(levelsetunits,{x = chunit.x, y = chunit.y})
												levelsetvalue = levelsetvalue + (chunitvalue*num2)
												lschange = true
											end
										elseif inum3.utype == 38 then
											
											local newxunit = true
											
											for i,v in pairs(xsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newxunit = false
												end
											end
											
											if newxunit then
												table.insert(xsetunits,{x = chunit.x, y = chunit.y})
												xsetvalue = xsetvalue + (chunitvalue%num2)
												xchange = true
											end
										elseif inum3.utype == 39 then
											
											local newyunit = true
											
											for i,v in pairs(ysetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newyunit = false
												end
											end
											
											if newyunit then
												table.insert(ysetunits,{x = chunit.x, y = chunit.y})
												ysetvalue = ysetvalue + (chunitvalue%num2)
												ychange = true
											end
											
										elseif inum3.utype == 40 then
											
											local newzunit = true
											
											for i,v in pairs(zsetunits) do
												if v.x == chunit.x and v.y == chunit.y then
													newzunit = false
												end
											end
											
											if newzunit then
												table.insert(zsetunits,{x = chunit.x, y = chunit.y})
												zsetvalue = zsetvalue + (chunitvalue%num2)
												zchange = true
											end
											
										elseif tostring(inum3.value) ~= tostring(chunitvalue%num2) then
											vchange = true
											inum3.value = chunitvalue%num2
										end
									end
								end
							elseif equals.utype == 9 or equals.utype == 32 then
								if (op.utype == 4 or op.utype == 25) and chunitvalue + num2 == num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 5 or op.utype == 26) and num3 == chunitvalue-num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 6 or op.utype == 28) and num3 == chunitvalue/num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 7 or op.utype == 27) and num3 == chunitvalue*num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 10 or op.utype == 29) and (num3 == chunitvalue^num2 or (chunitvalue == 0 and num2 == 0 and num3 == 0/0)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif (op.utype == 14 or op.utype == 30) and num3 == chunitvalue%num2 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 15 or equals.utype == 33 then
								if (op.utype == 4 or op.utype == 25) and chunitvalue + num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 5 or op.utype == 26) and  chunitvalue-num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 6 or op.utype == 28) and chunitvalue/num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 7 or op.utype == 27) and chunitvalue*num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 10 or op.utype == 29) and (chunitvalue^num2 < num3 or (chunitvalue == 0 and num2 == 0 and 0/0 < num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif (op.utype == 14 or op.utype == 30) and chunitvalue%num2 < num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 16 or equals.utype == 34 then
								if (op.utype == 4 or op.utype == 25) and chunitvalue + num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 5 or op.utype == 26) and  chunitvalue-num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 6 or op.utype == 28) and chunitvalue/num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 7 or op.utype == 27) and chunitvalue*num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 10 or op.utype == 29) and (chunitvalue^num2 > num3 or (chunitvalue == 0 and num2 == 0 and 0/0 > num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif (op.utype == 14 or op.utype == 30) and chunitvalue%num2 > num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 17 or equals.utype == 35 then
								if (op.utype == 4 or op.utype == 25) and chunitvalue + num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 5 or op.utype == 26) and  chunitvalue-num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 6 or op.utype == 28) and chunitvalue/num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 7 or op.utype == 27) and chunitvalue*num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 10 or op.utype == 29) and (chunitvalue^num2 <= num3 or (chunitvalue == 0 and num2 == 0 and 0/0 <= num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif (op.utype == 14 or op.utype == 30) and chunitvalue%num2 <= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 18 or equals.utype == 36 then
								if (op.utype == 4 or op.utype == 25) and chunitvalue + num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 5 or op.utype == 26) and  chunitvalue-num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 6 or op.utype == 28) and chunitvalue/num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 7 or op.utype == 27) and chunitvalue*num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 10 or op.utype == 29) and (chunitvalue^num2 >= num3 or (chunitvalue == 0 and num2 == 0 and 0/0 >= num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif (op.utype == 14 or op.utype == 30) and chunitvalue%num2 >= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
								end
							elseif equals.utype == 19 or equals.utype == 37 then
								if (op.utype == 4 or op.utype == 25) and chunitvalue + num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 5 or op.utype == 26) and  chunitvalue-num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 6 or op.utype == 28) and chunitvalue/num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 7 or op.utype == 27) and chunitvalue*num2 ~= num3 then
									loadlevel(levelnum+1)
									
									playsfx("win")
									
								elseif (op.utype == 10 or op.utype == 29) and (chunitvalue^num2 ~= num3 or (chunitvalue == 0 and num2 == 0 and 0/0 ~= num3)) then
									loadlevel(levelnum+1)
									
									playsfx("win")
								elseif (op.utype == 14 or op.utype == 30) and chunitvalue%num2 ~= num3 then
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
	
	if lschange then
		loadlevel(levelsetvalue)
		playsfx("setlevel")
		return
	end
	
	if zchange and tostring(zsetvalue) ~= tostring(z) then
		z = zsetvalue
		setvarvalues()
		checkdels()
		parse()
	end
	
	if ychange and tostring(ysetvalue) ~= tostring(y) then
		y = ysetvalue
		setvarvalues()
		checkdels()
		parse()
	end
	
	if xchange and tostring(xsetvalue) ~= tostring(x) then
		x = xsetvalue
		setvarvalues()
		checkdels()
		parse()
	end
	
	if vchange then
		checkdels()
		parse()
	end
	
end