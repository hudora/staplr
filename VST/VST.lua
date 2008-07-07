#!/usr/bin/env lua

-- VST - very simple terminal
--
-- This contains the complete front end for the user.
-- Handles incoming input and display output
--
--
-- Original by Christian Klein
-- Further developments by Johan Otten

local movement = require("Movement")
--local pipeserver = require("pipeserver")
require("pipeserver")
local socket = require("socket")



-- check for forklift ID
if table.getn(arg) == 0 then
    print(string.format("Usage: %s %s stapler_id", arg[-1], arg[0]))
    os.exit()
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

function correctPosition(barcode)
    return true
end


print("starting VST")
lift_id = arg[1]


-- redirect all output to /dev/tty1 and clear screen
io.output("/dev/tty1")


running = 1

--main loop
while running ~= 0 do
    -- try to get a movement
    current_movement = Movement:next(lift_id)

    if current_movement ~= nil then
        --current_movement:display(current_movement)
        displayMovement(current_movement)
        --this was: current_movement:handle_input(lift_id)

        while true do
            input = getinput()
            if input == "F2" then
                --io.write("\nMelde Umlagerung\nzurueck\nScan location\nF5: Fehler")
                io.write("\n\nScan location\n\nF5: Fehler")
                io.flush()

                while true do
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
                            if correctPosition(input) then
                                --io.write("\n\n        Done\n\n")
                                io.write("        Done")
                                io.flush()
                                break
                            else
                                io.write("\n\nWrong position\n\n")
                                io.flush()
                            end
                        else
                            io.write("\ninvalid barcode\n\n\n")
                            io.flush()
                        end
                        socket.sleep(2)
                    end
                end
                --Movement:release(lift_id)
                current_movement:release(lift_id)
                socket.sleep(2)
                break

            elseif input == "F5" then
                --something went wrong
                io.write("Melde Fehler\nF2: Kein Palette\nF4: Bezets\n\n")
                io.flush()
                while true do
                    input = getinput()
                    if input == 'F2' then
                        -- no palet fault
                        io.write("\n\n Melden \n\n")
                        current_movement:report_error(lift_id)
                        break
                    elseif input == 'F4' then
                        -- place taken
                        -- TODO: instructions?
                        io.write("\n\n bezets \n\n")
                        current_movement:report_error(lift_id)
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

keyb.restore_tty()
