function loadworld()
	local file = love.filesystem.read("world.niz")
  local ok = false
  local data = nil
	if file ~= nil then
		ok, data = serpent.load(file)
	end
	return data
end


function saveworld(levels)
	love.filesystem.write("world.niz", serpent.dump(levels))
end