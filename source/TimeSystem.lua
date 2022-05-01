if not TimeSystem then
function TimeSystem(ptime)
	local list = {}
	local ht = {}
	local ptime = ptime or 0.03125
	local tick = 0
	local isRun = true

	local Time = {
		ptime = ptime,
		time = 0,
	}

	-- @param func function(time) [[your code]] end
	function Time.subscribe(func)
		table.insert(list, func)
		ht[func] = true
	end

	function Time.unsubscribe(func)
		if ht[func] then
			for i=1, #list do
				if list[i] == func then table.remove(list, i); ht[func] = nil end
			end
		end
	end

	local function update()
		tick = tick + 1
		local time = tick*ptime
		Time.time = time
		for i=1, #list do
			list[i](time)
		end
	end

	function Time.resume()
		while isRun do
			update()
		end
	end

	function Time.start()
		tick = 0
		Time.resume()
	end

	function Time.stop()
		isRun = false
	end

	-- connect API game
	-- TimerStart(CreateTimer(), ptime, true, update)
	return Time
end
end
