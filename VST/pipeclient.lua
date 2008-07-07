--[[
-- pipeclient - redirects output from a file or device to a socket
--
-- usage:
--   lua pipeclient device [type]
--
-- where type is:
--   scanner    reads per line (for a handscanner)
--   terminal   reads per character (for a keyboard)
--
-- Made by: Johan Otten June 2008
--
--
]]

require("socket")
require("jstdlib")

local PORT = 3456


specialkeytrans = {}
specialkeytrans['[[A'] = "F1"
specialkeytrans['[[B'] = "F2"
specialkeytrans['[[C'] = "F3"
specialkeytrans['[[D'] = "F4"
specialkeytrans['[[E'] = "F5"


if arg[1] == nil then
    print (string.format([[

  pipeclient - redirects output from a file or device to a socket

  usage:
    %s %s device [type]

  where type is:
    scanner    reads per line (for a handscanner)
    terminal   reads per character (for a keyboard)
]], arg[-1], arg[0]))
    os.exit()
end

function fixfkey(fd, first)

    -- when not a special char, just return it
    -- 1b is esc char
    if ashex(first) ~= '1b ' then
        print("nothing to fix with" .. first)
        return first
    end

    --read the string and select the right key
    --when not in the list it's nil
    key = specialkeytrans[fd:read(3)]
    
    if key == nil then
        print("not in list")
        return nil
    end
    print("fixed to: "..key)

    return key
end


-- open connection

local mode = "undefined"
local readbuffersize = 1

if arg[2] == "scanner" then
    --for scanners
    print ("starting in scanner mode")
    mode = "scanner"
    readbuffersize = "*l"

elseif arg[2] == "terminal" then
    --for terminal
    print ("starting in terminal mode")
    mode = "terminal"
    readbuffersize = 1

else
    print ("default mode")
    mode = "default"
    readbuffersize = 1
end

print("## starting for "..arg[1])


if mode == "terminal" then
    --import the keyboard lib which contain some C only terminal control options
    require("keyb")
    --init
    keyb.init_tty(arg[1])

end

--open the pipe/buffer
local fd = io.open(arg[1])
print (fd)


while 1 do  
    foo = socket.protect(function()
        --first read, then connect and send and close
        print("reading "..arg[1])
        local contents = fd:read(readbuffersize)

        --translate special function keys
        if mode == "terminal" then
            contents = fixfkey(fd, contents)
        end

        --remove whitespace. barcode read appends \n
        contents = strip(contents)

        --if the string is empty begin again
        if contents == "" then
            --since this in a function return can be used, lack of continue :/
            return
        end

        print("connecting "..arg[1])
        -- connect
        local c = socket.try(socket.connect("localhost", PORT))

        --set linger option to avoid error
        c:setoption('linger', {on = true, timeout = 2})

        -- create a try function that closes 'c' on error
        local try = socket.newtry(function() c:close() end)
        -- do everything reassured c will be closed 
        print("sending " .. arg[1] .. " : " .. ashex(""..contents))


        print ("try", try(c:send(contents)))

        c:close()
    end)
    print ("Message:", foo())
end
