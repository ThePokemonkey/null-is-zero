function parse()

	local vchange = false

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
									loadlevel(chunitvalue)
									playsfx("setlevel")
									return
								end
								if tostring(inum2.value) ~= tostring(chunitvalue) then
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
											loadlevel(chunitvalue+num2)
											playsfx("setlevel")
											return
										end
										if tostring(inum3.value) ~= tostring(chunitvalue+num2) then
											vchange = true
											inum3.value = chunitvalue+num2
										end
									end
								elseif op.utype == 5 or op.utype == 26 then
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
								elseif op.utype == 6 or op.utype == 28 then
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
								elseif op.utype == 7 or op.utype == 27 then
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
								elseif op.utype == 10 or op.utype == 29 then
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
										if (tostring(inum3.value) ~= tostring(chunitvalue^num2) and not (chunitvalue == 0 and num2 == 0)) or (chunitvalue == 0 and num2 == 0 and tostring(inum3.value) ~= "nan") then
											vchange = true
											inum3.value = chunitvalue^num2
											if chunitvalue == 0 and num2 == 0 then inum3.value = 0/0 end
										end
									end
								elseif op.utype == 14 or op.utype == 30 then
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
	
	if vchange then
		checkdels()
		parse()
	end
	
end