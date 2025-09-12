-- This library only handles the Overworld's Avatars.
-- Y'know, those cute little persons you move around with the Arrow keys.

return function(self)

    -- Checks if a loaded file is valid
    -- If anything is wrong, it can throw errors or warnings.
    function self.CheckEntityFile(avatar, entityName)
        local debug = CYKDebugLevel > 0

        if type(avatar) ~= "table" then
            error("The Avatar file Lua/Overworld/Players/"  .. entityName .. ".lua can't be found.")
        elseif type(avatar.hp) ~= "number" then
            error("The Avatar file " .. entityName .. " must contain a number variable named \"hp\".\nThis value is the amount of HP the avatar has.")
        --[[
        elseif type(avatar.atk) ~= "number" then
            error("The Avatar file " .. entityName .. " must contain a number variable named \"atk\".\nThis value is the ATK value of the avatar.")
        elseif type(avatar.def) ~= "number" then
            error("The Avatar file " .. entityName .. " must contain a number variable named \"def\".\nThis value is the DEF value of the avatar.")
        elseif type(avatar.mag) ~= "number" then
            error("The Avatar file " .. entityName .. " must contain a number variable named \"mag\".\nThis value is the MAG value of the avatar.")
        --]]
        elseif type(avatar.animations) ~= "table" then
            error("The Avatar file " .. entityName .. " must contain a variable named \"animations\".\nYou should check an example Avatar file in order to know how to set this variable.")
        else
            -- Checks if the avatar files have some required animations
            -- Stores all the anims an avatar should have and check if they exist
            local minAnims = { Idle, Walk = true }
            for k, v in pairs(minAnims) do
                if not minAnims[k] then
                    minAnims[k] = nil
                end
            end

            for k, v in pairs(avatar.animations) do
                if type(v) ~= "table" then
                    error("Each variable inside an Avatar file's animations variable must be a table, however the Avatar file " .. entityName .. "'s animations." .. k .. " is a " .. type(v) .. ".")
                elseif type(v[1]) ~= "table" then
                    error("The Avatar file " .. entityName .. "'s animations." .. k .. "'s first variable must be a table, but it is a " .. type(v[1]) .. ".")
                elseif type(v[2]) ~= "number" then
                    error("The Avatar file " .. entityName .. "'s animations." .. k .. "'s second variable must be a number, but it is a " .. type(v[2]) .. ".")
                elseif type(v[3]) ~= "table" then
                    error("The Avatar file " .. entityName .. "'s animations." .. k .. "'s third variable must be a table, but it is a " .. type(v[3]) .. ".")
                end
                minAnims[k] = nil
            end

            local missingAnims = ""
            for k, v in pairs(minAnims) do
                if missingAnims == "" then
                    missingAnims = k
                else
                    missingAnims = missingAnims .. ", " .. k
                end
            end
            if missingAnims ~= "" then
                error("The Avatar file " .. entityName .. " requires the animations " .. missingAnims)
            end
        end

    end

    function self.CreateAllAvatars()
        -- Search for every existing Avatar script.
        local p = 1
        for key, value in pairs(Misc.ListDir("/Lua/Overworld/Avatars/")) do
            local fakekey = string.gsub(value, "/Lua/Overworld/Avatars/", "")
            fakekey = string.gsub(value, ".lua", "")

            self.allAvatars[fakekey] = fakekey
            p = p + 1
        end

        for realI, v in pairs(self.allAvatars) do
            local avatar = self.allAvatars[realI]

            local name = self.allAvatars[realI]

            -- Loads the file itself
            local queriedEntityFile = avatar
            self.allAvatars[realI] = LoadEntityFile(self._ENV_BASE, "Overworld/Avatars/" .. queriedEntityFile, self)

            -- Checks if the file is correct
            avatar = self.allAvatars[realI]
            self.CheckEntityFile(avatar, queriedEntityFile)

            avatar.scriptName = queriedEntityFile

            -- Add this avatar's animations to self.anims
            self.anims[avatar.scriptName] = avatar.animations
            self.anims[avatar.scriptName].animsFolder = avatar.animsFolder
            
            -- Lastly, add some extra variables to the avatar.
            avatar.name = name

            avatar.posX = 0
            avatar.posY = 0
            
            avatar.posBeforeBattle = { }
            avatar.posBeforeBattle.x = 0
            avatar.posBeforeBattle.y = 0

            if avatar.maxhp == nil then
                avatar.maxhp = avatar.hp
            end
            
        end

        -- Then build the animations just added in the self.anims table.
        self.BuildAnimations()

        -- and NOW, create the proper sprites.
        for realI, v in pairs(self.allAvatars) do
            self.CreateAvatarSprite(self.allAvatars[realI])
        end

    end

    -- Creates an avatar
    function self.CreateAvatarSprite(data)
        local avatar = data

        -- Avatar sprite
        avatar.sprite = CreateSprite("empty", "OWEntities")
        avatar.sprite.SetPivot(0.5, 0)
        --avatar.sprite.Scale(2, 2)  -- In case you wanna do that.
        avatar.sprite.absx = avatar.posX
        avatar.sprite.absy = avatar.posY
        avatar.sprite["anim"] = avatar.scriptName
        avatar.sprite["ysort"] = true

        -- I *don't* think this sprite gets used anywhere in the code?
        -- It's just here so you can know where the collision tiles will detect the player.
        avatar.debugbox = CreateSprite("px", "Top")
        avatar.debugbox.SetPivot(0, 0)
        avatar.debugbox.SetParent(avatar.sprite)
        avatar.debugbox.x = avatar.sprite.x + avatar.hitbox.startX
        avatar.debugbox.y = avatar.sprite.y - 38 + avatar.hitbox.startY

        avatar.debugbox.color = {1, 0.2, 0, 0.25}
        avatar.debugbox.alpha = (CYKDebugLevel > 0) and 0.7 or 0
        avatar.debugbox.Scale(avatar.hitbox.width, avatar.hitbox.height)


        avatar.scriptName = nil

        -- These are used by the Walk animation.
        avatar.beforePos = {x=0, y=0}
        avatar.beforeDirection = 0
        avatar.directionKeyQueue = {}

        avatar.isNotWalking = true

        self.SetAnim(avatar, "Idle")
    end

    self.CreateAllAvatars()

end