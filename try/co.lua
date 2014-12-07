local try = require "try"

local function _protect(co, status, ...)
  if not status then
    local msg = ...
    if try.is_try_error(msg) then
      return nil, msg[1]
    end
    return error(msg, 0)
  end
  if coroutine.status(co) == "suspended" then
    return _protect(co, coroutine.resume(co, coroutine.yield(...)))
  else
    return ...
  end
end

local function protect(f)
  return function(...)
    local co = coroutine.create(f)
    return _protect(co, coroutine.resume(co, ...))
  end
end

return setmetatable({
  protect = protect
},{__index = try})
