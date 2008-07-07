------------
-- 
-- Movement lib handles storage/requesting of movement data
--
-- Original by Christian Klein
-- Further developments by Johan Otten
--


local json = require("json")
local http = require("socket.http")
--local keyb = require("keyb")


TIMEOUT = 1


local URLS = {}
URLS["get"] = "http://192.168.3.195/~chris/json?lift=%d"
URLS["release"] = "http://192.168.3.195/?RELEASE&stapler=%d&movement=%s"
URLS["error"] = "http://192.168.3.195/?ERROR&stapler=%d&movement=%s"


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


function Movement:report_error(lift_id)
    print ("ids", lift_id, self.id)
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
