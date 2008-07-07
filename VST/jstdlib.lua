--[[
--  jstdlib
--
--  some fuctions used and are more library things then program functionality
--
--  contains:
--      ashex
--      strip
--
--  made by: Johan Otten - June 2008
--
--]]


--[[
--  prints a string in hex representation
--
--]]
function ashex(s)
    return (s:gsub(".", function(c) return string.format("%x ", string.byte(c)); end ))
end



--[[
--  strips a string of additional leading and trailing whitespace
--
--]]
function strip(st)
    if st == nil then 
        return nil
    end
    st = st:gsub('^[\t\ \n\r]*', '')
    st = st:gsub('[\t\ \n\r]*$', '')
    return st
end
