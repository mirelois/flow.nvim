local json = require("flow.lib.json")

local M = {}

M.file_exists = function(path)
   local f = io.open(path, "r")
   return f ~= nil and io.close(f)
end

M.str_split = function(s, delimiter)
  local result = {}
  for match in (s..delimiter):gmatch('(.-)'..delimiter) do
    table.insert(result, match);
  end
  return result
end

M.trim_space = function(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

return M
