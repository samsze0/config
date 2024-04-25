local M = {}

M.rgb_to_hex = function(r, g, b) return ("#%02X%02X%02X"):format(r, g, b) end

M.cube6 = function(v) return v == 0 and v or (v * 40 + 55) end

return M
