--[[ Pure Lua equivalent of lua-try (https://github.com/moteus/lua-try),
    which again is based on luasockets newtry, protect and try functions.
    Passes unittest of lua-try.
    fix_return_values() trick taken from http://lua-users.org/wiki/FinalizedExceptions
    License: MIT. Egil Hjelmeland.
]]

local error,getmetatable,pcall,setmetatable
    = error,getmetatable,pcall,setmetatable

local try_error_mt = { } -- tagging error as newtry error

local function is_try_error(e)
	return getmetatable(e) == try_error_mt
end

local function newtry (finalizer)
	return function (ok, ...)
		if ok then return ok, ... end
		-- else idiomatic nil, error
		if finalizer then finalizer() end
		error( setmetatable({ (...) }, try_error_mt) ) -- raise wrapped error 
	end
end

local function fix_return_values(ok, ...)
	if ok then return ... end
	local msg = ...
	if getmetatable (msg) == try_error_mt then -- is_try_error(...)
		return nil, msg[1] -- return idiomatic nil, error
	end
	error(msg, 0) -- pass non-try error
end

local function protect(f)
	return function(...)
		return fix_return_values(pcall(f, ...))
	end
end

local try = newtry()

return {
	new = newtry,      -- lua-try
	newtry = newtry,   -- luasockets
	protect = protect, -- both
	try = try,         -- luasockets
	assert = try,      -- lua-try
	is_try_error = is_try_error, -- for try/co.lua
}
