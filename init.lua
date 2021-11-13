local MP = minetest.get_modpath("chat_censor")
-- bad_words
-- go in /wordlist/*
lang = {"en","zh","fil","fr","de","hi","ja","pl","ru","es","th"}
local dirname = MP.. "/wordlist"

function file_exists(file)
    local f = io.open(file,"rb")
    if f then f:close() end
    return f ~= nil
end

bad_words = {}
bad_en_words = {}

for k,f in pairs(lang) do
    local fname = dirname.. "/" .. f
    if file_exists(fname) then
        -- append its content to the dictionary bad_words
        for line in io.lines(fname) do
            if f == "en" then
                table.insert(bad_en_words,line)
            end
            table.insert(bad_words,line)
        end
    end
end


-- Stop BAD names from joining
dofile(MP.."/name_censor.lua")

-- VPN Blocker (ghoti/Paul)
-- Basically create a IP Rating System
-- dofile(MP.."/vpn_blocker.lua")

-- AntiSpam
dofile(MP.."/antispam.lua")

-- CAPS Alert
-- Censor bad words in chat
dofile(MP.."/censor.lua")
