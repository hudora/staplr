------------
-- 
-- Movement lib handles storage/requesting of movement data
--
-- Original by Christian Klein
-- Further developments by Johan Otten
--


local json = require("json")
local socket = require("socket")
local http = require("socket.http")
--local keyb = require("keyb")


TIMEOUT = 1


local URLS = {}
URLS["get"] = "http://192.168.3.195/intern/mypl/beleg/stapler/%s/holen/"
URLS["release"] = "http://192.168.3.195/intern/mypl/beleg/stapler/%s/zurueckmelden/%s"
URLS["error"] = "http://192.168.3.195/intern/mypl/beleg/stapler/%s/fehler/%s/%s/"

-- URLS["get"] = "http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%s/holen/"
-- URLS["release"] = "http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%s/zurueckmelden/%s"
-- URLS["error"] = "http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%s/fehler/%s/%s/"

--URLS["get"] = "http://www.hudora.de/intern/mypl/beleg/stapler/%d/holen/"
--URLS["release"] = "http://www.hudora.de/intern/mypl/beleg/stapler/%d/zurueckmelden/%s"
--URLS["error"] = "http://www.hudora.de/?ERROR&stapler=%d&movement=%s"



Movement = {source=nil, destination=nil, quantity=0, description="", artnr="", id = nil}
secretkey = "qtRdiSlu"


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
    response, code = http.request(url, "key="..secretkey)
    if response == nil or code ~= 200 then
        --sleep and try again
        socket.sleep(2)
        response = http.request(url, "key="..secretkey)
        if response == nil then
            return "connection error"
        end
    end

	return Movement:new(json.decode(response))
end


function Movement:report_error(lift_id, errortype)
    print ("ids", lift_id, self.id)
    body = string.format("belegnr=%s&type=%s", self.id, errortype)
    url = string.format(URLS["error"], lift_id, self.id, errortype)
    response = http.request(url, "key="..secretkey.."&"..body)
    if response == nil then
        --sleep and try again
        socket.sleep(2)
        response = http.request(url, "key="..secretkey.."&"..body)
        if response == nil then
            return "connection error"
        end
    end
end

function Movement:release(lift_id)
    body = string.format("belegnr=%s", self.id)
    url = string.format(URLS["release"], lift_id, self.id)
    response, code = http.request(url, "key="..secretkey.."&"..body)
    if code ~= 200 then
        -- error!
        socket.sleep(2)
        response = http.request(url, "key="..secretkey.."&"..body)
        if response == nil then
            return "connection error"
        end
    end
end
