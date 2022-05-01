# Timer system
A system that provides convenient work with timers. Designed for integration with an external timer and for testing and emulating code that depends on time events. Advantages relative to other implementations - deterministic execution order on most devices. Based on a [binary heap](https://github.com/Tieske/binaryheap.lua) with modification. It was calculated to work with ~ 300_000 timers.
## Quick start
```lua
local Time = TimeSystem()
local Timer = TimerSystem(Time)
Timer.after(2, function() print('2 seconds have passed') end)
Timer.every(1, 5, function() print('periodic') end)
Time.start() -- run time (for console)
[[ output
periodic
periodic
2 seconds have passed
periodic
periodic
periodic
]]
```
## API
```lua
local Time = TimeSystem()
local Timer = TimerSystem(Time)
Timer.new() --> timer

-- @param delay - float
-- @param fucntion - fucntion
-- @param arguments - table, optional
Timer.after(delay, fucntion, arguments) --> timer -- run through time

-- ...
-- @param count - uint
Timer.every(delay, count, function, arguments) --> timer -- run multiple times
```
```lua
local timer = Timer.new()
timer:after(delay, fucntion, arguments) -- run through time
timer:every(delay, count, function, arguments) -- run multiple times
timer:pause()
timer:remained() --> float - time
```
## More examples
```lua
local unit = {x = 0, y = 0}
Timer.after(3, function(timer, arg)
	arg.x, arg.y = 1, -1
	print(unit.x, unit.y)
end, unit)
--> 1, -1


local tick = 0
Timer.every(1, 10, function(timer)
	tick = tick + 1
	print(tick)
	if tick > 5 then
		timer:pause()
	end
end)
--> 1, 2, 3, 4, 5, 6
```