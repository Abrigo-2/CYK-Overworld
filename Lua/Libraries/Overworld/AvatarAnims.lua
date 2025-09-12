return function(self)
    -- Animation collection
    self.anims = { }
    self.anims.followUps = { }  -- List of sprites in an animation that starts another animation when it's finished

    -- Build the content in the self.anims table to make it look like proper animations usable with sprite.SetAnimation()
    function self.BuildAnimations()
        local testSprite = CreateSprite("empty", "Top")
        
        -- Check each registered entity
        for k, v in pairs(self.anims) do
            local folder = v.animsFolder
            v.animsFolder = nil
            -- For each animation in the current entity
            for k2, v2 in pairs(v) do
                -- Create the animation with file paths
                for i = 1, #v2[1] do
                    local cpath = tostring(v2[1][i])

                    local file = "Overworld/" .. folder .. "/" .. k2 .. "/" .. cpath
                    v2[1][i] = file
                end
                -- Starts the anim if preloadAnimations is true to register it in CYK
                testSprite.SetAnimation(v2[1], v2[2])
            end
        end
        -- Animation of the stars that appear when a Player's attack is performed perfectly

        testSprite.Remove()
    end

    -- Sets a sprite object's animation
    function self.SetAnim(entity, animName)
        local ignore = ignore or false
        local sprite = entity.sprite
    
        local animObject = self.anims[sprite["anim"]][animName]

        -- Removes any occurence of this sprite in the followUp table
        for i = #self.anims.followUps, 1, -1 do
            if self.anims.followUps[i].entity == entity then
                table.remove(self.anims.followUps, i)
            end
        end

        -- If the animation's "Walk", do stuff.
        local decoyAnim = animObject[1]
        if animName ==  "Idle" then
            decoyAnim = {}
            decoyAnim[1] = animObject[1][entity.direction]
            
        elseif animName == "Walk" or animName == "Run" then
            decoyAnim = {}
            local totalFrames = #animObject[1] / 4

            local tableanims = {}

            for i=1, totalFrames do
                tableanims[i] = animObject[1][ ((entity.direction - 1) * totalFrames) + i ]
            end
            decoyAnim = tableanims

        end

        -- If the current animation doesn't exist, abort
        if not animObject then
            if CYKDebugLevel > 0 then
                error("[WARN] The animation " .. animName .. " of the " .. (entity.UI and "player" or "enemy") .. " " .. tostring(entity.sprite["anim"]) .. " doesn't exist.", 2)
            end
            return
        end
        local loopmode = animObject[3].loop and animObject[3].loop or animObject[3].next and "ONESHOT" or "LOOP"

        -- Adds the sprite to the followUp table if this anim must be followed by another anim when it ends
        sprite.loopmode = loopmode

        sprite["currAnim"] = animName
        sprite["lastAnimTime"] = Time.time

        -- Moves the sprite if needed
        local xShift = animObject[3].posShift and animObject[3].posShift[1] or 0
        local yShift = animObject[3].posShift and animObject[3].posShift[2] or 0
        sprite.Move(xShift - (sprite["xShift"] or 0), yShift - (sprite["yShift"] or 0))
        sprite["xShift"] = xShift
        sprite["yShift"] = yShift

        -- FINALLY set the animation
        sprite.SetAnimation(decoyAnim, animObject[2])

        -- Don't forget the sprite's mask... Except that avatars have none yet.
        --if sprite["mask"] then
        --    sprite["mask"].loopmode = loopmode
        --    sprite["mask"].SetAnimation(decoyAnim, animObject[2])
        --end
    end

    
    function self.PlayerLookAt(player, direction, nooverride)
        local nooverride = (nooverride ~= nil) and nooverride or false
        local beforeDirection = player.direction
        
        player.direction = direction
        self.SetAnim(player, "Idle")
        
        -- if nooverride is true, the avatar won't actually have its direction value changed, only the sprite.
        if nooverride then
            player.direction = beforeDirection end
    end

    -- Check if any sprite animation in the followUp list has ended
    -- if an animation has ended, it launches the animation that is supposed to follow it
    function self.UpdateFollowUps()
        for i = #self.anims.followUps, 1, -1 do
            local followUp = self.anims.followUps[i]
            if followUp.entity.sprite.animcomplete then

                -- Remove the sprite if it has to be removed at the end of the anim, otherwise set its followUp animation
                if followUp.destroyOnEnd then
                    followUp.entity.sprite.Remove()
                    table.remove(self.anims.followUps, i)
                else
                    self.SetAnim(followUp.entity, followUp.next)
                end

                break
            end
        end
    end

    function self.queueDirectionKey(queue, direction)
        if #queue < 2 and queue[1] ~= direction then
            table.insert(queue, direction)
        end
    end
    function self.removeDirectionKeyFromQueue(queue, direction)
        for me=#queue, 1, -1 do
            if queue[me] == direction then
                table.remove(queue, me)
                return
            end
        end
    end

    -- The overworld walking animation
    function self.UpdatePlayerIdleAnim()
        if #self.party == 0 then return end
        
        for i=1, #self.party do
            local player = self.party[i]
            local direction = { x=0, y=0 }
            
            local beforeDirection = player.direction
            local hasDirectionChanged = false
            local isNotWalking = false
            
            -- The first party member, the one moved by the players.
            if i == 1 then
                -- Set direction to the currently pressed key, IF no other keys on queue are being held.
                if Input.Up == 2 then 
                    direction.y = direction.y + 1 
                    self.queueDirectionKey(player.directionKeyQueue, 1)
                end 
                if Input.Down == 2 then 
                    direction.y = direction.y - 1 
                    self.queueDirectionKey(player.directionKeyQueue, 3)
                end 
                
                if Input.Right == 2 then
                    direction.x = direction.x + 1 
                    self.queueDirectionKey(player.directionKeyQueue, 2)
                end 
                if Input.Left == 2 then 
                    direction.x = direction.x - 1 
                    self.queueDirectionKey(player.directionKeyQueue, 4)
                end 

                -- Remove any previously held keys from queue.
                if Input.Up == -1 then 
                    self.removeDirectionKeyFromQueue(player.directionKeyQueue, 1)
                end 
                if Input.Down == -1 then 
                    self.removeDirectionKeyFromQueue(player.directionKeyQueue, 3)
                end 
                
                if Input.Right == -1 then
                    self.removeDirectionKeyFromQueue(player.directionKeyQueue, 2)
                end 
                if Input.Left == -1 then 
                    self.removeDirectionKeyFromQueue(player.directionKeyQueue, 4)
                end 
                
                if direction.x == 0 and direction.y == 0 then
                    isNotWalking = true
                end

                player.direction = player.directionKeyQueue[1] or player.direction
                
            -- The other party members, they only follow.
            else
                if (player.beforePos.x == player.posX) and (player.beforePos.y == player.posY) then
                    isNotWalking = true 
                end

                beforeDirection = player.beforeDirection

                player.beforeDirection = player.direction
                player.beforePos.x = player.posX
                player.beforePos.y = player.posY
            end

            hasDirectionChanged = (beforeDirection ~= player.direction) or (player.isNotWalking ~= isNotWalking)

            --Actually change the animation
            if isNotWalking then
                self.SetAnim(player, "Idle")
            else
                
                local speed = player.animations.Walk[2]
                
                player.sprite.animationspeed = self.Movement.speed > self.Movement.walkSpeedCap and 4/30 or speed
                
                -- Don't change the sprite's animation if it is the same one looped anim
                if hasDirectionChanged then
                    self.SetAnim(player, "Walk") end
            end

            player.isNotWalking = isNotWalking
        end

    end

end