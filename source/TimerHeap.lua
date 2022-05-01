-- https://github.com/Tieske/binaryheap.lua/blob/master/src/binaryheap.lua
if not TimerHeap then
local assert = assert
local floor = math.floor
--================================================================
-- basic heap sorting algorithm
--================================================================

--- Basic heap.
-- This is the base implementation of the heap. Under regular circumstances
-- this should not be used, instead use a _Plain heap_ or _Unique heap_.
-- @section baseheap

--- Creates a new binary heap.
-- This is the core of all heaps, the others
-- are built upon these sorting functions.
-- @param swap (function) `swap(heap, idx1, idx2)` swaps values at
-- `idx1` and `idx2` in the heaps `heap.values` and `heap.payloads` lists (see
-- return value below).
-- @param erase (function) `swap(heap, position)` raw removal
-- @param lt (function) in `lt(a, b)` returns `true` when `a < b` (for a min-heap)
-- @return table with two methods; `heap:bubbleUp(pos)` and `heap:sinkDown(pos)`
-- that implement the sorting algorithm and two fields; `heap.values` and
-- `heap.payloads` being lists, holding the values and payloads respectively.
local binaryHeap = function(swap, erase, lt)

	local heap = {
			values = {},  -- list containing values
			erase = erase,
			swap = swap,
			lt = lt,
		}

	function heap:bubbleUp(pos)
		local values = self.values
		while pos>1 do
			local parent = floor(pos/2)
			if not lt(values[pos], values[parent]) then
					break
			end
			swap(self, parent, pos)
			pos = parent
		end
	end

	function heap:sinkDown(pos)
		local values = self.values
		local last = #values
		while true do
			local min = pos
			local child = 2 * pos

			for c = child, child + 1 do
				if c <= last and lt(values[c], values[min]) then min = c end
			end

			if min == pos then break end

			swap(self, pos, min)
			pos = min
		end
	end

	return heap
end

--================================================================
-- plain heap management functions
--================================================================

--- Plain heap.
-- A plain heap carries a single piece of information per entry. This can be
-- any type (except `nil`), as long as the comparison function used to create
-- the heap can handle it.
-- @section plainheap
do end -- luacheck: ignore
-- the above is to trick ldoc (otherwise `update` below disappears)

local update_old
--- Updates the value of an element in the heap.
-- @function heap:update
-- @param pos the position which value to update
-- @param newValue the new value to use for this payload
update_old = function(self, pos, newValue)
	assert(newValue ~= nil, "cannot add 'nil' as value")
	assert(pos >= 1 and pos <= #self.values, "illegal position")
	self.values[pos] = newValue
	if pos > 1 then self:bubbleUp(pos) end
	if pos < #self.values then self:sinkDown(pos) end
end

local remove
--- Removes an element from the heap.
-- @function heap:remove
-- @param pos the position to remove
-- @return value, or nil if a bad `pos` value was provided
remove = function(self, pos)
	local last = #self.values
	if pos < 1 then
		return  -- bad pos

	elseif pos < last then
		local v = self.values[pos]
		self:swap(pos, last)
		self:erase(last)
		self:bubbleUp(pos)
		self:sinkDown(pos)
		return v

	elseif pos == last then
		local v = self.values[pos]
		self:erase(last)
		return v

	else
		return  -- bad pos: pos > last
	end
end

local insert
--- Inserts an element in the heap.
-- @function heap:insert
-- @param value the value used for sorting this element
-- @return nothing, or throws an error on bad input
insert = function(self, value) -- changed
	assert(value ~= nil, "cannot add 'nil' as value")
	local pos = #self.values + 1
	self.values[pos] = value
	self.position[value] = pos
	self:bubbleUp(pos)
end

local pop
--- Removes the top of the heap and returns it.
-- @function heap:pop
-- @return value at the top, or `nil` if there is none
pop = function(self)
	if self.values[1] ~= nil then
		return remove(self, 1)
	end
end

local peek
--- Returns the element at the top of the heap, without removing it.
-- @function heap:peek
-- @return value at the top, or `nil` if there is none
peek = function(self)
	return self.values[1]
end

local size
--- Returns the number of elements in the heap.
-- @function heap:size
-- @return number of elements
size = function(self)
	return #self.values
end

local function swap(heap, a, b) -- (pos_a and pos_b) -- changed
	heap.position[heap.values[a]], heap.position[heap.values[b]] = b, a
	heap.values[a], heap.values[b] = heap.values[b], heap.values[a]
end

local function erase(heap, pos) -- changed
	heap.position[heap.values[pos]] = nil
	heap.values[pos] = nil
end

--================================================================
-- new functions
-- changed: erase, swap, insert
local function append(self, obj)
	local pos = self.position[obj]
	if pos then
		self:update_old(pos, obj)
	else
		self:insert(obj)
	end
end

local function drop(self, obj)
	local pos = self.position[obj]
	if pos and self.values[pos] ~= nil then
		return remove(self, pos)
	end
end

local function update(self, obj)
	local pos = self.position[obj]
	if pos then
		self:update_old(pos, obj)
	else return nil end
end

local function first(self)
	return self.values[1]
end

--================================================================
--================================================================
-- TimerHeap heap creation
--================================================================

function TimerHeap(lt)
	-- if not lt then lt = function(a,b) return a[1] < b[1] end end
	local h = binaryHeap(swap, erase, lt)
	h.peek = peek
	h.pop = pop
	h.size = size
	h.remove = remove
	h.insert = insert -- changed
	h.update_old = update_old -- renamed

	-- new
	h.position = {}
	h.append = append
	h.drop = drop
	h.update = update
	h.first = first
	return h
end
end