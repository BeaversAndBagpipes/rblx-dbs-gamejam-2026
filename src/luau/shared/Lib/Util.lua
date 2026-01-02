--!strict

-- Utils Placeholder
-- This file is a place to put smaller generic functions used throughout the project.

local Util = {}

-- ████████╗ █████╗ ██████╗ ██╗     ███████╗███████╗
-- ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
--    ██║   ███████║██████╔╝██║     █████╗  ███████╗
--    ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--    ██║   ██║  ██║██████╔╝███████╗███████╗███████║
--    ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝
--

---
-- Returns the number of entries in the given table.\
-- Works with both indexed, keyed, and mixed table types.\
-- @param table Table to count entries in.\
-- @return number Number of entries in the table.
function Util.GetTableLength(table: {}): number
	if not table then return 0 end
	local i = 0
	for _, _ in pairs(table) do
		i += 1
	end
	return i
end

---
-- Returns an indexed table of every key in the given table.\
-- @param t Table to extract keys from.\
-- @return table Indexed table of keys.
function Util.GetTableKeys(t: {}): { [number]: any }
	local r = {}
	for k, _ in pairs(t) do
		table.insert(r, k)
	end
	return r
end

---
-- Returns a random value from a numerically indexed table.\
-- Only works with numerically indexed tables.\
-- @param table Table to select a random value from.\
-- @return any Random value from the table.
function Util.GetRandomTableKey(table: {}): number
	return table[math.random(#table)]
end

---
-- Checks if a table contains a given value.\
-- @param t Table to search.\
-- @param val Value to search for.\
-- @return boolean True if value is found, false otherwise.
function Util.TableContainsValue(t, val): boolean
	for _,v in pairs(t) do
		if v == val then
			return true
		end
	end
	return false
end

---
-- Checks if a table contains a given key.\
-- @param t Table to search.\
-- @param key Key to search for.\
-- @return boolean True if key is found, false otherwise.
function Util.TableContainsKey(t, key): boolean
	for k, _ in pairs(t) do
		if k == key then
			return true
		end
	end
	return false
end

---
-- Returns a table with the contents of t1 and t2 merged together - t2 has priority\
-- @param t1 First table.\
-- @param t2 Second table (overrides t1 on conflicts).\
-- @return table Merged table.
function Util.TableJoin(t1: {}, t2: {}): {}
	local t = {}
	if t1 then for k,v in pairs(Util.TableClone(t1)) do t[k] = v end end
	if t2 then for k,v in pairs(Util.TableClone(t2)) do t[k] = v end end
	return t
end

---
-- Returns a deep copy of the given table.\
-- @param t Table to clone.\
-- @return table Deep copy of the table.
function Util.TableClone(t: {}): {}
	local clone = {}
	for k,v in pairs(t) do
		if type(v) == "table" then
			clone[k] = Util.TableClone(v)
		else
			clone[k] = v
		end
	end
	return clone
end



-- ██╗     ███████╗██████╗ ██████╗ ███████╗
-- ██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝
-- ██║     █████╗  ██████╔╝██████╔╝███████╗
-- ██║     ██╔══╝  ██╔══██╗██╔═══╝ ╚════██║
-- ███████╗███████╗██║  ██║██║     ███████║
-- ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝
--

---
-- Linearly interpolates between two values.\
-- @param a Start value.\
-- @param b End value.\
-- @param t Interpolation factor (0-1).\
-- @return number Interpolated value.
function Util.Lerp(a, b, t)
	return a + (b - a) * t
end

---
-- Returns a triangle wave value for a given progress (0-1)./
-- Peaks at 0.5, returns to 0 at 0 and 1./
-- @param progress Progress value (0-1)./
-- @return number Triangle wave value (0-1).
function Util.TriangleWave(progress: number)
	local scale = 1 - math.abs(progress - 0.5) * 2 -- 0 -> 1 -> 0
	      scale = math.clamp(scale, 0, 1)
	return scale
end


-- ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
-- ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
-- ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
-- ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║╚════██║
-- ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝███████║
-- ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
--

---
-- Converts a key to lowercase and clamps its length to 50 characters./
-- @param key The key to format./
-- @return string Formatted key.
function Util.FormatKey(key: string): string
	return tostring(key):lower():sub(1, 50)
end



-- ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
-- ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
-- ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
-- ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
-- ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
-- ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
--

return Util
