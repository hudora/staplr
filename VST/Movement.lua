
local json = require("json")
local http = require("socket.http")
local keyb = require("keyb")
local aux = require("aux")

local URLS = {
    "get" = "http://192.168.2.45/~chris/json?lift=%d",
    "release" = "http://192.168.2.45/?RELEASE&stapler=%d&movement=%s",
    "error" = "http://192.168.2.45/?ERROR&stapler=%d&movement=%s"
}

-- "get" = "http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%d/holen/"
-- "release" = "http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%d/zurueckmelden/%s"
-- "error" = "http://boingball.local.hudora.biz/?ERROR&stapler=%d&movement=%s"

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
-- or nil if error occurs of no movement available
function Movement:next(lift_id)
    url = string.format(URLS["get"], lift_id)
    response, code = http.request(url)
    if response == nil or code ~= 200 then
        return nil
    end

	return Movement:new(json.decode(response))
end

function Movement:handle_input(lift_id)
    while true do
    	input = keyb.readkey()
    	if input == "F2" then
			io.write("\n\nMelde Umlagerung\nzurueck\n")
			io.flush()
        	self:release()
			aux.sleep(2)
            break
    	elseif input == "F5" then
			io.write("\n\nMelde Fehler\n\n")
			io.flush()
        	self:report_error()
			aux.sleep(2)
            break
    	end
    end
end

function Movement:report_error(lift_id)
    body = string.format("belegnr=%s", self.id)
    url = string.format(URLS["error"], lift_id, self.id)
    response = http.request(url, body)
end

function Movement:release(lift_id)
    body = string.format("belegnr=%s", self.id)
    url = string.format(URLS["release"], lift_id, self.id)
    response, code = http.request(url, body)
    if code ~= 200 then
        -- error!
    end
end
