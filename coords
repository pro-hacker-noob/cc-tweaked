-- chat_coords_silent.lua
-- Silent listener: PMs coords on "getcoords" from pro_hacker_noob
-- Keeps silent, retries finding Chat Box if missing

local ALLOWED_USER = "pro_hacker_noob"
local RETRY_DELAY = 2 -- seconds to wait when chat box not found or after handling

local function findChatBox()
    return peripheral.find("chat_box") or peripheral.find("chatBox")
end

local function getCoords()
    if gps then
        local ok, x, y, z = pcall(gps.locate, 10)
        if ok and x then
            return math.floor(x + 0.5), math.floor(y + 0.5), math.floor(z + 0.5)
        end
    end
    if commands and type(commands.getBlockPosition) == "function" then
        local ok, a, b, c = pcall(commands.getBlockPosition)
        if ok and a then
            return a, b, c
        end
    end
    return nil, nil, nil
end

local function pmPlayer(chatBox, username, msg)
    pcall(function()
        if chatBox.sendMessageToPlayer then
            chatBox.sendMessageToPlayer(msg, username)
        else
            chatBox.sendMessage(msg, username)
        end
    end)
end

while true do
    local chatBox = findChatBox()
    if not chatBox then
        sleep(RETRY_DELAY)
    else
        -- If chatBox is found enter event loop; if peripheral detached, break to outer loop to re-find silently
        local ok, err = pcall(function()
            while true do
                local event = {os.pullEvent()}
                local evname = event[1]

                if evname == "chat" or evname == "chat_message" then
                    -- event signatures differ slightly between implementations:
                    -- common patterns:
                    -- ("chat", username, message, uuid, isHidden)
                    -- ("chat_message", sender, message, _, isHidden)
                    local sender = tostring(event[2] or "")
                    local message = tostring(event[3] or "")

                    if sender == ALLOWED_USER and message:lower() == "getcoords" then
                        local x, y, z = getCoords()
                        if x then
                            pmPlayer(chatBox, sender, ("Coords for this computer: X=%d Y=%d Z=%d"):format(x, y, z))
                        else
                            pmPlayer(chatBox, sender, "Could not determine coordinates: no GPS and commands API unavailable.")
                        end
                        sleep(0.8)
                    end
                elseif evname == "peripheral_detach" then
                    -- If chat box was detached, break and try to find it again silently
                    -- No output
                    break
                end
            end
        end)
        if not ok then
            -- in case of unexpected error, silently wait and retry
            sleep(RETRY_DELAY)
        end
    end
end
