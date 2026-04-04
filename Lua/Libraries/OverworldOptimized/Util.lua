return function(self)

    -- Creates fake avatar keys, for optimized encounters.
    function self.CreateAllAvatars_Optimized()
        -- Search for every existing Avatar script.
        local p = 1
        for key, value in pairs(Misc.ListDir("/Lua/Overworld/Avatars/")) do
            local fakekey = string.gsub(value, "/Lua/Overworld/Avatars/", "")
            fakekey = string.gsub(value, ".lua", "")

            self.allAvatars[fakekey] = {}
            p = p + 1
        end

        for realI, v in pairs(self.allAvatars) do
            local avatar = self.allAvatars[realI]

            -- Lastly, add some extra variables to the avatar.
            avatar.name = realI

            avatar.hp = 1
            avatar.maxhp = 1 

            avatar.posX = 0
            avatar.posY = 0
            
            avatar.posBeforeBattle = { }
            avatar.posBeforeBattle.x = 0
            avatar.posBeforeBattle.y = 0

            if avatar.maxhp == nil then
                avatar.maxhp = avatar.hp
            end
            
        end

    end


    -- Sets HP for optimized avatars.
    function self.SetAvatarProperties_Optimized(IDtag, _hp, battleName)
        -- Search for every existing Avatar script.
        
        self.allAvatars[IDtag].hp = _hp
        self.allAvatars[IDtag].maxhp = _hp

        self.allAvatars[IDtag].battleName = battleName

    end



    return self
end