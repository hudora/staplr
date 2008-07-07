local PORT = 3456

require("socket")

local sock, err = socket.bind("*", PORT)

if sock == nil then
    io.stderr:write("Failed to bind to port"..err)
    os.exit()
end   


function getinput()
    print("accept")
    input, err= sock:accept()

    --failed to create a listen socket, port already taken?
    if input == nil then
        io.stderr:write("Failed to accept"..err)
        os.exit()
    end

    print("receive")
    contents, err, part = input:receive()

    --fix for when there's an error like socket closed
    if contents == nil then
        contents = part
    end

    input:close()
    return contents
end
