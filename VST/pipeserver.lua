--------------------
-- Pipeserver - accepts input from a socket
--
-- Usually this input comes from the pipeclient, but it can be anything
--
-- Usage:
--   call getinput to get the input
--
----------






local PORT = 3456

require("socket")

local sock, err = socket.bind("*", PORT)

if sock == nil then
    io.stderr:write("Failed to bind to port"..err)
    os.exit()
end   


function getinput()
    -- get a key from the socket, but first flush existing.

    -- TODO: FLUSH existing keys and then listen for a key


    print("accept")
    input, err= sock:accept()

    --failed to create a listen socket, port already taken?
    if input == nil then
        io.stderr:write("Failed to accept"..err)
        os.exit()
    end

    print("receive")
    contents, err, part = input:receive()

    --fix for when there's an error like socket closed, it can still be nil then
    if contents == nil then
        contents = part
    end

    input:close()
    return contents
end
