
local json = require("json")
local http = require("socket.http")

Movement = {source=nil, destination=nil, quantity=0, description="", id = nil}


function Movement:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Movement:display()
    text = table.concat({"%s -> %s", "%s x %s", "", "F2: Ok, F3: Fehler"}, "\n")
    io.write(string.format(text, self.source, self.destination, self.quantity, self.description))
end

-- get next movement as json encoded dictionary
function Movement:next(lift_id)
    --response = http.request(string.format("http://boingball.local.hudora.biz/intern/mypl/beleg/stapler/%d/holen", lift_id))
    response = http.request("http://127.0.0.1/~chris/json?lift=" .. lift_id)
    if response == nil then
        return nil
    end

	return Movement:new(json.decode(response))
end

function Movement:handle_input(lift_id)
    input = io.read()
    if input == "2" then
        self:release()
    elseif input == "3" then
        -- report error
        print("error")
    end
end

function Movement:release()
    response = http.request("http://127.0.0.1/~chris/json", string.format("belegnr=%s", self.id))
    --response = http.request("http://boingball.local.hudora.biz/intern/mypl/beleg/zurueckmelden/", string.format("belegnr=%s", self.id))
end
