
-- improve this dictionary
local MP = minetest.get_modpath("chat_censor")
censor = {}
fun_mode = 1
fun_list = {"kitten","cat","dog","ara-ara"}

local f = MP.."/wordlist/fun"
if file_exists(f) then
    for line in io.lines(f) do
        table.insert(fun_list,line)
    end
end

-- censor messages
function censor.mentioned(name,msg)
    name, msg = name:lower(), msg:lower()

    -- Direct Mention
    local mention = msg:find(name,1,true)

    return mention
end

function censor.colorize(name, color, msg)
    return minetest.colorize(color,msg)
end
minetest.register_on_chat_message(function(name,message)

    -- Before sending check shout privs
    if not minetest.check_player_privs(name, "shout") then
        return
    end

    -- local sender = minetest.get_player_by_name(name)

    -- Censor Code
    -- "Lua is sexy" -> "Lua is ****"
    --[[
    local mes = ""
    for w in message:gmatch("%S+") do
        for k,v in pairs(bad_words) do
            if string.find(string.lower(w), string.lower(v)) then
                w = w:gsub(".","*")
            end
        end
        mes = mes .. w .. " "
    end
    -- remove last " "
    mes = mes:sub(1,-2)
    --]]

    --Censor Code v2
    -- "Lua is sexy" -> "Lua is ***y"
    local mes = message
    for k,v in pairs(bad_words) do
        -- Apply fun word substitution
        local pat = string.rep("*",v:len())
        if fun_mode == 1 then
            pat = fun_list[math.random(1,#fun_list)] .. " "
        end
        mes = mes:gsub(v,pat)
    end

    -- warn the offender
    if mes ~= message then
        print("[Censor]: ".. name .. " sent censored message :"..message)
        local warn = minetest.colorize("#ff0000","Your last message will be reported to server staff !")
        minetest.chat_send_player(name,warn)
    end

    message = mes

    -- broadcast the message to everyone
    for _,player in pairs(minetest.get_connected_players()) do
        -- reciever is everyone
        local rname = player:get_player_name()
        local color = "#ffffff"

        -- check for mentions ( BONUS feature )
        if censor.mentioned(rname,message) then
            color = "#00ff00"
        end
        if name == rname then
            color = "#ffffff"
        end
        -- Send the message
        local send = minetest.colorize(color,"<"..name.."> " .. message)
        minetest.chat_send_player(rname,send)
    end

    return true
end)

print("[Chat Censor] Loaded...")
