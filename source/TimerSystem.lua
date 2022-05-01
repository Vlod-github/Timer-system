if not TimerSystem then
local TimerHeap = require "TimerHeap" and TimerHeap
local TimeSystem = require "TimeSystem" and TimeSystem
assert(TimerHeap, TimeSystem)


----- class Timer
local index = {}

function index:every(delay, count, func, arg)
	if type(func) ~= 'function' then print('error') return end
	if count <= 0 then count = 1 end
	if delay <= 0 then delay = self.Time.ptime end
	self.delay = delay
	self.count = count
	self.func = func
	self.arg = arg
	self.start_time = self.Time.time
	self.end_time = self.Time.time + delay
	self.Heap:append(self)
	return self
end

function index:after(delay, func, arg)
	return self:every(delay , 1, func, arg)
end

function index:pause()
	return self.Heap:drop(self)
end

function index:remained()
	local time = self.end_time - self.Time.time
	return time > 0 and time or 0
end

local mt = {__index = index}
-----

local function lt(a,b) return a.end_time < b.end_time end

function TimerSystem(Time)
	Time = Time or TimeSystem()
	local Heap = TimerHeap(lt)

	local Timer = {}
	function Timer.new()
		local timer = {Time = Time, Heap = Heap}
		return setmetatable(timer, mt)
	end

	function Timer.after(...)
		return Timer.new():after(...)
	end

	function Timer.every(...)
		return Timer.new():every(...)
	end

	Time.subscribe(function(time)
		local timer = Heap:first()
		while timer and timer.end_time <= time do
			timer.count = timer.count - 1
			if timer.count > 0 then
				timer.start_time = time
				timer.end_time = time + timer.delay
				Heap:append(timer)
				timer.func(timer, timer.arg)
			else
				timer.func(timer, timer.arg)
				if timer.count <= 0 then Heap:pop() end
			end
			timer = Heap:first()
		end
	end)
	return Timer
end
end
