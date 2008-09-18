#!/usr/bin/env lua

-- VST - very simple terminal
--
-- This contains the complete front end for the user.
-- Handles incoming input and display output
--
--
-- Original by Christian Klein
-- Further developments by Johan Otten
--
-- copyrighted! and it's a beast

local movement = require("Movement")
--local pipeserver = require("pipeserver")
require("pipeserver")
local socket = require("socket")



-- check for forklift ID
if table.getn(arg) == 0 then
    print(string.format("Usage: %s %s stapler_id", arg[-1], arg[0]))
    os.exit()
end

function show_con_error()
    io.write("\n Verbindungs fehler\n  versuchen noch\n   einmal\n")

    --wait
    getinput()
end

function prettyfyLocation(loc)
    return string.format("%s-%s-%s", loc:sub(1,2), loc:sub(3,4), loc:sub(5,6))
end



function displayMovement(mov)
    text = table.concat({"", "%s -> %s", "%s x %s", "%s", "F2: Ok, F5: Fehler"}, "\n")
    io.write(string.format(text, prettyfyLocation(mov.source), prettyfyLocation(mov.destination), mov.quantity, mov.description, mov.artnr))
    io.flush()
end


function barcodeIsValid(barcode)
    return true
    
end

-- are we at the correct position?
function correctPosition(barcode, position)
    print(barcode, position)
    if barcode == position then
        return true
    else 
        return false 
    end
end


print("starting VST")
lift_id = arg[1]


-- redirect all output to /dev/tty1 and clear screen
io.output("/dev/tty1")


running = 1
loggedin = 0

while true do
    -- startup wait to avoid accidental movement retrievals
    -- and a nice shameless plug splash ;)
    io.write("\n HUDORA Staplr\n Johan Otten 2008\n\n   F1 to start")
    io.flush()
    input = getinput()
    if input == 'F1' then
        break
    end
end


--main loop
while running ~= 0 do
    while true do
        -- should be replaced with a real login
        io.write("\n\n F1 Anmelden\n\n")
        io.flush()
        input = getinput()
        if input == 'F1' then
            loggedin = 1
            break
        end
    end


    while loggedin == 1 do

        while true do
            -- wait to avoid accidental movement retrievals
            io.write("\n\n F1 Weiter\n F5 Abmelden\n")
            io.flush()
            input = getinput()
            if input == 'F1' then
                break
            elseif input == 'F5' then
                loggedin = 0
                break
            end
        end

        --hack to accept the logout key
        if loggedin == 0 then
            break
        end


        -- try to get a movement
        io.write("\n\n   laden...\n\n")
        current_movement = Movement:next(lift_id)
        if current_movement == "connection error" then
            show_con_error()

        elseif current_movement ~= nil then
            --current_movement:display(current_movement)
            displayMovement(current_movement)
            --this was: current_movement:handle_input(lift_id)

            while true do
                input = getinput()
                if input == "F2" then
                    --io.write("\nMelde Umlagerung\nzurueck\nScan location\nF5: Fehler")
                    io.write("\n\nPlatz scannen\n\nF5: Fehler")
                    io.flush()

                    -- disabled barcode checks temporarily
                    io.write("\n\n   releasing...\n\n")
                    if current_movement:release(lift_id) == "connection error" then  -- should go away
                        show_con_error()
                    end
                    io.write("\n\n        OK\n\n")
                    io.flush()
                    socket.sleep(2)

                    while false do --##### should be true
                    -- #en
                        input = getinput()
                        if input == 'F5' then
                            --error
                            io.write("\n Fehler\n\n\n")
                            break
                        else
                            --barcode? need a check for that
                            io.write("\n barcode:\n"..input.."\n\n")
                            io.flush()
                            if barcodeIsValid(barcode) then 
                                if correctPosition(input, current_movement.destination) then
                                    --io.write("\n\n        Done\n\n")
                                    io.flush()
                                    io.write("\n Fehler\n\n\n")
                                    if current_movement:release(lift_id) == "connection error" then
                                        show_con_error()
                                    end
                                    socket.sleep(2)
                                    break
                                else
                                    --wrong position
                                    io.write("\n\nFalsche position\n\n")
                                    io.flush()
                                    socket.sleep(2)
                                end
                            else
                                io.write("\nfalsche barcode\n\n\n")
                                io.flush()
                            end
                            socket.sleep(2)
                        end
                    end
                    --Movement:release(lift_id)
                    break

                elseif input == "F5" then
                    --something went wrong
                    io.write("Melde Fehler\nF1: Keine Palette\nF2: Besetzt\nF3: Bruch\nF4: Falsche Menge")
                    io.flush()
                    while true do
                        input = getinput()
                        if input == 'F1' then
                            -- no pallet fault
                            io.write("\n\n Keine palette...\n\n")
                            if current_movement:report_error(lift_id, "nopallet") == "connection error" then
                                show_con_error()
                            end

                            break
                        elseif input == 'F2' then
                            -- place taken
                            -- TODO: instructions?
                            io.write("\n\n Besetzt... \n\n")
                            if current_movement:report_error(lift_id, "destinationtaken")  == "connection error" then
                                show_con_error()
                            end

                            break
                        elseif input == 'F3' then
                            -- place taken
                            -- TODO: instructions?
                            io.write("\n\n Bruch... \n\n")
                            if current_movement:report_error(lift_id, "brokengoods")  == "connection error" then
                                show_con_error()
                            end

                            break
                        elseif input == 'F4' then
                            -- place taken
                            -- TODO: instructions?
                            io.write("\n\n Falsche Menge... \n\n")
                            if current_movement:report_error(lift_id, "wrongamount")  == "connection error" then
                                show_con_error()
                            end

                            break
                        end
                    end

                    socket.sleep(2)
                    break
                end
            end
        else
            -- no movements

            -- reset nil
            input = nil 
            io.write("\nKeine Umlagerungen\nF1: Weiter\n\n")
            io.flush()
            while input ~= "F1" do
                --input = keyb.getkey()
                print("get")
                input = getinput()
                print("got: "..input)
            end

        end
    end
end

keyb.restore_tty()
