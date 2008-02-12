
local json = require("json")
local http = require("socket.http")
local keyb = require("keyb")

local get_url = "http://192.168.2.45/~chris/json?lift=%d"
local release_url = "http://192.168.2.45/~chris/json"
-- "http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%d/holen"
-- "http://boingball.local.hudora.biz/intern/mypl/beleg/zurueckmelden/"

Movement = {source=nil, destination=nil, quantity=0, description="", id = nil}


function Movement:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Movement:display()
    text = table.concat({"%s -> %s", "%s x %s", " ", "F2: Ok, F3: Fehler"}, "\n")
    io.write(string.format(text, self.source, self.destination, self.quantity, self.description))
    io.flush()
end

-- get next movement as json encoded dictionary
function Movement:next(lift_id)
    response = http.request(string.format(get_url, lift_id))
    if response == nil then
        return nil
    end

	return Movement:new(json.decode(response))
end

function Movement:handle_input(lift_id)
    while true do
    	input = keyb.readkey()
    	if input == "F2" then
        	self:release()
                break
    	elseif input == "F5" then
        	-- report error
                break
    	end
    end
end

function Movement:release()
    response = http.request(release_url, string.format("belegnr=%s", self.id))
end
