
local json = require("json")
local http = require("socket.http")
local keyb = require("keyb")

local get_url = "http://192.168.2.45/~chris/json?lift=%d"
local release_url = "http://192.168.2.45/?RELEASE"
local error_url = "http://192.168.2.45/?ERROR"
-- "http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%d/holen"
-- "http://boingball.local.hudora.biz/intern/mypl/beleg/zurueckmelden/"

Movement = {source=nil, destination=nil, quantity=0, description="", artnr="", id = nil}


function Movement:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Movement:display()
    text = table.concat({"", "%s -> %s", "%s x %s", "%s", "F2: Ok, F5: Fehler"}, "\n")
    io.write(string.format(text, self.source, self.destination, self.quantity, self.description, self.artnr))
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
        	self:report_error()
                break
    	end
    end
end

function Movement:report_error()
    response = http.request(error_url, string.format("belegnr=%s", self.id))
end

function Movement:release()
    response = http.request(release_url, string.format("belegnr=%s", self.id))
end
