
-- improve this dictionary
local MP = minetest.get_modpath("chat_censor")
censor = {}
fun_mode = 1
fun_list = {"kitten","cat","dog","ara-ara"}
violations = {}
-- cost type limit
violation_limit = 10
caps_limit = 70

local f = MP.."/wordlist/fun"
if file_exists(f) then
    for line in io.lines(f) do
        table.insert(fun_list,line)
    end
end

minetest.register_on_joinplayer(function(player)
    violations[player:get_player_name()] = 0
end)

-- censor warn
function censor.warn(name)
    local vbalance = ""
    if violations[name] then
        vbalance = vbalance ..  "Violation Status: ".. violations[name] .. "/"..violation_limit
    end
    local warn = minetest.colorize("#ff0000","Your last message will be reported to server staff!" .. vbalance )
    minetest.chat_send_player(name,warn)
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

function censor.check(name,msg)
    -- check message for three types of profanity
    -- CAPS, bad words,long messages, SPAM attack

    if msg:len() > 256 then
        -- Add some cost
        violations[name] = (violations[name] or 0) + 3;
        minetest.chat_send_player(name,minetest.colorize("#ff0000","Long messages are considered as SPAM "))
        censor.warn(name)
    end

    if msg:len() > 8 then
        -- no need to check caps on short messages
        local caps = 0

        for i = 1,#msg do
            local c = msg:sub(i,i)
            -- replace everything that isnt letter with small ones
            c = c:gsub('%A','a')
            if c  == c:upper() then
                caps = caps + 1
            end
        end
        if (caps*100 / msg:len()) >= caps_limit then
            -- Add some cost
            violations[name] = (violations[name] or 0) + 2
            minetest.chat_send_player(name,minetest.colorize("#ff0000","CAPS ALERT "))
            censor.warn(name)
        end
    end

end
minetest.register_on_chat_message(function(name,message)

    -- Before sending check shout privs
    if not minetest.check_player_privs(name, "shout") then
        return
    end
    -- local sender = minetest.get_player_by_name(name)

    censor.check(name,message)


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
        violations[name] = (violations[name] or 0) + 3
        censor.warn(name)
    end

    if violations[name] >= violation_limit then
        minetest.kick_player(name, "Violations Limits Excedded")
        print("[Censor]: " .. name .. " was kicked due to violations limits.")
        return
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
