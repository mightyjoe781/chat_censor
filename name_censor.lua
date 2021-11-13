
-- improve this dictionary


minetest.register_on_prejoinplayer(function(name)
    -- length check
    if name:len() < 3 then
        return "Please use more than 2 characters for username !"
    end

    -- better name checking rather than random digits
    for k,v in pairs(bad_en_words) do
        if string.find(string.lower(name),string.lower(v)) then
            --  console print
            print("Blocked user: " ..name.. " from joining because their name contains word : " .. v)
            return "Your name contain a blocked word :"..v..", Please login again with better name"
        end
    end
end)

print("[Name Censor] Loaded...")
