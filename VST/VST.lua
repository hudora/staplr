#!/usr/bin/env lua

-- VST - very simple terminal

local movement = require("Movement")

if table.getn(arg) == 0 then
    print(string.format("Usage: %s %s stapler_id", arg[-1], arg[0]))
    os.exit()
end

lift_id = arg[1]

running = 1
while running ~= nil do
    current_movement = Movement:next(lift_id)
    if current_movement ~= nil then
        current_movement:display()
        current_movement:handle_input()
    end
end