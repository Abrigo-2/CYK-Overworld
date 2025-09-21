return function(CYK)
    local self = { }

    self.attackingPlayers = { }  -- Used when players are attacking. It keeps track of who is attacking and who is attacking first!
    
    self.visorSpeed = 4 * (1 + 1/30)
    self.fadetime = 0

    -- Sets a Player attack up
    function self.SetupAttack()
        -- If a player's target entity is not active, take an active entity instead
        for i = 1, #self.attackingPlayers do
            local player = CYK.players[self.attackingPlayers[i]]
            if not player.target.isactive then
                player.target = CYK.enemies[CYK.GetEntityUp(player.target, true)]
            end
        end

        -- Nobody attacking
        if #self.attackingPlayers == 0 then
            CYK.State("ENEMYDIALOGUE")
            return
        end

        -- Reset the timer for fading out the attack UI
        self.fadetime = 0

        -- Computes the order at which the Players will attack and the position of their attack visor
        local differentInputs = math.random()
        differentInputs = math.min(#self.attackingPlayers, differentInputs < 0.1 and 1 or differentInputs < 0.9 and 2 or 3)
        local differentInputsOriginal = differentInputs
        local usedInputs = { }
        for i = 1, #self.attackingPlayers do
            local attackingPlayer = { playerID = self.attackingPlayers[i], stopped = false, perfectStars = { } }
            local player = CYK.players[self.attackingPlayers[i]]
            local chancesDifferent = differentInputs == 0 and 0 or (#self.attackingPlayers - i + 1) / differentInputs
            local chosen = 0
            -- BRAND NEW INPUT! LIMITED STOCK!
            if math.random() <= chancesDifferent then
                differentInputs = differentInputs - 1
                repeat
                    chosen = math.random(1, differentInputsOriginal)
                until not table.containsObj(usedInputs, chosen, true) or limitCount == 0
                table.insert(usedInputs, chosen)
            -- Same input as someone else
            else
                chosen = usedInputs[math.random(1, #usedInputs)]
            end
            attackingPlayer.inputNumber = chosen
            attackingPlayer.visor = player.UI.atkZone.visor
            attackingPlayer.visor.x = 41 + (60*self.visorSpeed) + (24*self.visorSpeed) * (attackingPlayer.inputNumber - 1)
            attackingPlayer.visor["crit"] = false
            
            attackingPlayer.visor.color = { 1, 1, 1 }
            attackingPlayer.visor.alpha = 1
            attackingPlayer.atkColor = player.atkHitColor
            
            for i=1, #attackingPlayer.visor["trails"] do
                local t = attackingPlayer.visor["trails"][i]
                t.x = attackingPlayer.visor.x
                t.alpha = .92 - (#attackingPlayer.visor["trails"]-i) * 2/11
                t.alpha = t.alpha * 0.54
            end
            attackingPlayer.visor["activeTrail"] = true
            
            self.attackingPlayers[i] = attackingPlayer
            self.DisplayAtkZone(player.UI)
        end
        for i = 2, #CYK.players do
            CYK.players[i].UI.atkZone.separator.alpha = 1
        end
    end

    -- Handles the press of the "Confirm" key while we're in the state ATTACKING
    function self.Confirm()
        local nextPlayers = { }
        local lowerPlayerX = 132
        -- For each Player
        for i = 1, #self.attackingPlayers do
            local attackingPlayer = self.attackingPlayers[i]
            -- If it hasn't attacked yet
            if not attackingPlayer.stopped then
                -- If this Player is the closest Player to the left, add it to a table
                local visor = attackingPlayer.visor
                local added = true
                -- If this Player is closer to the left than the Player(s) currently in the table where the Players are stored, remove those Players
                if visor.x < lowerPlayerX then
                    nextPlayers = { { attackingPlayer, i } }
                    lowerPlayerX = visor.x
                -- If this Player is at the same X position as the Player(s) currently in the table where the Players are stored, add this Player to the table
                elseif visor.x == lowerPlayerX then
                    table.insert(nextPlayers, { attackingPlayer, i })
                else
                    added = false
                end
                if added then
                    attackingPlayer.visor["activeTrail"] = false
                    
                    -- Get the attack coefficient of this Player that'll be used if this Player's attack cursor is closer to the left than any other cursors
                    local diff = math.abs(visor.x - 41)
                    local attackingPlayer = nextPlayers[#nextPlayers][1]

                    -- Missed
                    if visor.x <= -500 then
                        attackingPlayer.coeff = 0
                    -- Perfect hit...?
                    elseif diff <= self.visorSpeed then
                        -- Perfect hit!!
                        if visor.x < 42.5 then
                            visor.x = 41
                            diff = 0
                            attackingPlayer.coeff = 150

                            -- Create the stars displayed during perfect attacks
                            local player = CYK.players[attackingPlayer.playerID]
                            CYK.StartSecondaryAnimation(CYK.animationChannelsName.perfectHitStars, player)
                        -- Slightly too early...
                        else
                            attackingPlayer.coeff = 120
                        end
                    -- 2 frame off...
                    elseif diff <= self.visorSpeed*3 then
                        attackingPlayer.coeff = 120
                    -- 4 frames off...
                    elseif diff <= self.visorSpeed*5 then
                        attackingPlayer.coeff = 110
                    -- Formula when far from the target
                    else
                        attackingPlayer.coeff = 100 - (diff/5 * 2)
                    end

                    if attackingPlayer.coeff > 0 then
                        local tp = attackingPlayer.coeff / 10
                        CYK.TP.Set(tp, true)

                        attackingPlayer.coeff = attackingPlayer.coeff / 150
                    end
                end
            end
        end
        -- If a Player has attacked
        if #nextPlayers > 0 then
            -- For each of those Players
            local crit = false
            while #nextPlayers > 0 do
                local playerID = nextPlayers[1][1].playerID
                local visor = nextPlayers[1][1].visor
                if visor.x == 41 then
                    visor.color = { 1, 1, 0 }
                    visor["crit"] = true
                    crit = true
                elseif visor.x > 41 then
                    visor.color = nextPlayers[1][1].atkColor
                end
                nextPlayers[1][1].stopped = true
                -- Start this Player's "Fight" animation
                CYK.SetAnim(CYK.players[playerID], "Fight")
                table.remove(nextPlayers, 1)
            end

            if crit then
                PlaySoundOnceThisFrame("criticalslice")
            else
                PlaySoundOnceThisFrame("slice")   end
        end
        CYK.UI.FlashAttackBars()
    end

    -- Updates this library, if the current state is ATTACKING
    function self.Update()
        if CYK.state == "ATTACKING" then
            local done = true
            -- For each attacking Player
            for i = 1, #self.attackingPlayers do
                local attackingPlayer = self.attackingPlayers[i]
                if attackingPlayer == nil then return end
                local player = CYK.players[attackingPlayer.playerID]
                local enemy = player.target

                if attackingPlayer.done then
                    -- Nothing happens when it's done
                -- Reset the enemy's animation to Idle when it's Hurt animation is done
                elseif (attackingPlayer.coeff == 0 or enemy.sprite["currAnim"] ~= "Hurt") and attackingPlayer.done == false then
                    attackingPlayer.done = true
                    if attackingPlayer.coeff > 0 then
                        CYK.SetAnim(enemy, "Idle")
                    end
                -- Once this Player's "Fight" animation is complete
                elseif attackingPlayer.stopped and player.sprite.animcomplete and attackingPlayer.done == nil then
                    attackingPlayer.done = false
                    player.UI.faceSprite.Set("CreateYourKris/Players/" .. player.sprite["anim"] .. "/UI/Normal")
                    
                    -- Attack the enemy, and if the attack is not missed, start a slashing animation on the target enemy!
                    if self.Attack(enemy.ID, false, player.ID, true, attackingPlayer.coeff) and attackingPlayer.coeff > 0 then
                        local atkSprite = CreateSprite("empty", "Entity")
                        atkSprite.absx = enemy.posX + enemy.sprite.width / 2
                        atkSprite.absy = enemy.posY + enemy.sprite.height / 2
                        atkSprite.loopmode = "ONESHOTEMPTY"
                        atkSprite["anim"] = player.sprite["anim"]
                        atkSprite["xShift"] = enemy.sliceAnimOffsetX
                        atkSprite["yShift"] = enemy.sliceAnimOffsetY
                        CYK.SetAnim({ sprite = atkSprite }, "SliceAnim", nil, nil, { noAnimOverride = true, destroyOnEnd = true })
                        attackingPlayer.attackAnim = atkSprite
                    end
                end
                -- Shows the Player's visor scale up and disappear as the attack is confirmed
                if attackingPlayer.stopped and attackingPlayer.visor.alpha > -1 then
                    if attackingPlayer.visor["crit"] then
                        attackingPlayer.visor.Scale(attackingPlayer.visor.xscale + 8 * 0.05, attackingPlayer.visor.yscale + 46 * 0.06)
                    else
                        attackingPlayer.visor.Scale(attackingPlayer.visor.xscale + 6 * 0.05, attackingPlayer.visor.yscale + 38 * 0.05)
                    end
                    attackingPlayer.visor.alpha = attackingPlayer.visor.alpha - 0.05
                -- Moves the visor to the left
                elseif not attackingPlayer.stopped then
                    -- This is accurate, just laggy.
                    --attackingPlayer.visor.x = attackingPlayer.visor.x - ((CYK.frame%2 == 0) and self.visorSpeed*2 or 0)
                    attackingPlayer.visor.x = attackingPlayer.visor.x - self.visorSpeed*Time.mult * ( (attackingPlayer.visor.x < 41) and 1.5 or 1 )
                    
                    -- If the visor goes too far to the left, it disappears and the attack ends
                    if attackingPlayer.visor.x < 20 then
                        attackingPlayer.visor.alpha = attackingPlayer.visor.x / 20
                    end
                    -- If the visor is too far to the left, the attack is missed
                    if attackingPlayer.visor.x <= -20 then
                        attackingPlayer.visor.x = -500
                        self.Confirm()
                    end

                end

                -- Moves and fades the trails
                for i=1, #attackingPlayer.visor["trails"] do
                    local t = attackingPlayer.visor["trails"][i]
                    
                    if CYK.frame%4 == 1 then
                        if i == #attackingPlayer.visor["trails"] then
                            t.x = attackingPlayer.visor.x
                        else
                            t.x = attackingPlayer.visor["trails"][i+1].x  end
                    end

                    
                    if not attackingPlayer.visor["activeTrail"] then
                        t.alpha = t.alpha - 1/18
                    end
                end
                -- If any of the Players isn't done attacking, do not exit this state
                if not attackingPlayer.done then
                    done = false
                end
            end
            
            -- Once every player's done attacking, start fading out the UI
            if done then
                
                self.fadetime = self.fadetime + 1
                for i = 1, #CYK.players do
                    local player = CYK.players[i]
                    
                    if (player.UI.atkZone.bar.alpha > 0) then
                        self.DisplayAtkZone(player.UI,  1 - (self.fadetime/20) )
                        player.UI.atkZone.visor.alpha = player.UI.atkZone.visor.alpha - (self.fadetime/20)
                    end

                    if i >= 2 then
                        CYK.players[i].UI.atkZone.separator.alpha = CYK.players[i].UI.atkZone.separator.alpha - (self.fadetime/20)
                    end

                end
                
                local enemyHurtingDone = true
                -- If any enemy is still displaying their Hurt animation, do not exit this state
                for i = 1, #CYK.enemies do
                    if CYK.enemies[i].sprite["currAnim"] == "Hurt" then
                        enemyHurtingDone = false
                        break
                    end
                end

                if (self.fadetime > 20) and enemyHurtingDone then
                    CYK.State( (#CYK.enemies > 0) and "ENEMYDIALOGUE" or "BEFOREDONE" )
                end

            end
        end

    end

    self.DisplayAtkZone = CYK.UI.DisplayAtkZone

    -- Attacks a target
    function self.Attack(targetID, isTargetPlayer, attackerID, isAttackerPlayer, coeff, damageClass)
        local target = (isTargetPlayer and CYK.allPlayers or CYK.allEnemies)[targetID]
        local attacker = (isAttackerPlayer and CYK.allPlayers or CYK.allEnemies)[attackerID]
        -- Do not attack a dead / disabled entity
        if target.hp < 0 or not target.isactive then
            return false
        end
        -- Shake the screen if a player is hurt.
        if isTargetPlayer or (attacker.name == "Susie" and coeff > 0) then
            if damageClass ~= "RudeBuster" then
                CYK.ScreenShake.Shake(13, 6)
            end
        end
        -- Tries to call this entity's BeforeDamageCalculation function
        ProtectedCYKCall(target.BeforeDamageCalculation, attacker, coeff)
        local damage
        -- If the amount of damage dealt to the entity is fixed, use it
        if target.presetDamage ~= nil then
            damage = target.presetDamage
            target.presetDamage = nil
        -- Otherwise, computes the damage dealt to the entity
        else
            damage = -self.ComputeDamage(targetID, attackerID, coeff and coeff or 1, isTargetPlayer, isAttackerPlayer, damageClass and damageClass or "")
        end

        damage = self.ChangeHP(target, attacker, damage)
        if damageClass == "RudeBuster" then
            if coeff >= 2 then
                PlaySoundOnceThisFrame("rudebusterhitboost")
            else
                PlaySoundOnceThisFrame("rudebusterhit") end
        elseif damageClass == "Iceshock" then
            
        else
            -- If the damage is lower than 0, that means it's negative and subtracts the target's health.
            if damage < 0 and not isTargetPlayer then
                PlaySoundOnceThisFrame((attacker.name == "Susie") and "hitsusie" or "hitsound")  end
        end

        return true
    end

    -- Computes the damage an attacker is supposed to deal to a target
    function self.ComputeDamage(targetID, attackerID, coeff, isTargetPlayer, isAttackerPlayer, damageClass)
        local target = (isTargetPlayer and CYK.allPlayers or CYK.allEnemies)[targetID]
        local attacker = (isAttackerPlayer and CYK.allPlayers or CYK.allEnemies)[attackerID]

        local dmg = 0
        if damageClass == "RudeBuster" then
            dmg = math.ceil( (11*attacker.atk) + (5*attacker.mag) )
            dmg = math.ceil( dmg - (3 * target.def) )
            dmg = (coeff >= 2) and dmg+30 or dmg
        elseif damageClass == "IceShock" then
            dmg = math.ceil( (30*(attacker.mag-10)) + 90 + math.random(0, 10) )
            dmg = math.ceil( dmg - (3 * target.def) )
        elseif damageClass == "ChargedMash" then
            local hpPercent = 1 - math.abs((target.hp-1) / target.maxhp) 
            dmg = math.ceil( 15*(0.4*hpPercent+1)*(attacker.atk + attacker.mag) / 2 )
            dmg = math.ceil( dmg - (3 * target.def) )
        else
            if isAttackerPlayer then
                -- coeff comes as a float from 0 to 1.
                dmg = math.ceil( (attacker.atk * coeff * 150) / 20 )
            else
                dmg = math.ceil( 5*attacker.atk )    end
            
            if coeff > 0 then
                dmg = math.ceil( dmg - (3 * target.def) )  end
        end

        -- Further reduce Player's damage taken.
        if chapter2 and isTargetPlayer then
            if  dmg > target.maxhp/5 then
                dmg = dmg - 3
            elseif dmg > target.maxhp/8 then
                dmg = dmg - 2
            else    dmg = dmg - 1 end
        end
        
        if target.action == "Defend" then
            dmg = math.ceil(dmg * 2 / 3)      end

        return dmg
    end

    -- Changes an entity's HP, spawns a damage text and changes the entity's animation
    function self.ChangeHP(target, attacker, value, isAbsolute)
        local textValue = value
        local color = nil
        local isPlayer = table.containsObj(CYK.players, target)
        
        target.hp = target.hp + value

        -- Killing a spareable enemy will result in a game-breaking infinite loop.
        -- I apologize, I cannot figure out how to work around it.
        -- This contraption, at the moment, is the best I can do.
        if not isPlayer and target.hp <= 0 then
            if target.canspare then
                target.hp = 1
                target.TryKill()
            end
        end

        -- Displays the "Miss" text if the entity's HP is changed by 0
        if value == 0 then
            textValue = "Miss"
        -- If the entity's HP is changed by a positive number, heal it
        elseif value > 0 then
            PlaySoundOnceThisFrame("healsound")
            -- Cap this entity's HP to its map HP value
            if target.hp >= target.maxhp then
                textValue = "Max"
                target.hp = target.maxhp
            -- If this (Player) entity is healed, display the text "Up" instead
            elseif target.hp > 0 and value >= target.hp then
                textValue = "Up"
                target.hp = math.min(math.max(math.ceil(target.maxhp / 5), target.hp), target.maxhp)
                CYK.SetAnim(target, "Idle")
                if isPlayer then
                    target.UI.faceSprite.Set("CreateYourKris/Players/" .. target.sprite["anim"] .. "/UI/Normal")
                end
            end
        -- If the entity's HP is changed by a negative number, hurt it
        else
            -- If the entity's HP is 0 or below
            if target.hp <= 0 then
                if isPlayer then
                    -- Check for game over if we're damaging a Player
                    local gameOver = true
                    for i = 1, #CYK.players do
                        if CYK.players[i].hp > 0 then
                            gameOver = false
                            break
                        end
                    end
                    -- If all the Players are down, GAME OVER
                    if gameOver and ProtectedCYKCall(OnGameOver) ~= false then
                        if CYK.Background then
                            for i = 1, #CYK.Background do
                                CYK.Background[i].Remove()
                            end
                        end
                        Player.sprite.set("ut-heart")
                        Player.sprite.alpha = 1
                        doneFor = true
                        unescape = false
                        CYK.GameOver.StartGameOver()
                    end
                    color = { 1, 0, 0 }
                    textValue = "Down"
                    target.hp = -math.ceil(target.maxhp / 3)
                    target.UI.faceSprite.Set("CreateYourKris/Players/" .. target.sprite["anim"] .. "/UI/Down")
                    CYK.SetAnim(target, "Down")
                -- Try to kill the enemy, unless it has a function named OnDeath()
                else
                    target.TryKill()
                end
            -- Set the entity's animation to Hurt if it's not defending
            elseif target.action ~= "Defend" then
                CYK.SetAnim(target, "Hurt")

                if isPlayer then
                    target.UI.faceHurtTime = 26
                    target.UI.faceSprite.Set("CreateYourKris/Players/" .. target.sprite["anim"] .. "/UI/Hurt")
                end
            end
            -- Hidden feature?!
            if not isPlayer and target.isTiredWhenHPLow and target.hp <= target.maxhp / 3 then
                target.tired = true
            end
        end

        -- Updates the Player's UI if the entity is a Player
        if isPlayer then
            CYK.UI.UpdatePlayerHP(target)
        end
        -- Call the entity's HandleAttack() function if it exists
        if value <= 0 then
            ProtectedCYKCall(target.HandleAttack, attacker, value == 0 and -1 or -value)
        end

        -- Computes the damage text's color, then spawns it
        if not color and value > 0 then
            color = { 0, 1, 0 }
        elseif attacker and attacker.UI and not color then
            color = attacker.damageColor
            
            for i = 1, #color do
                color[i] = color[i] == 0 and 0.5 or color[i]
            end
        elseif not color then
            color = { 1, 1, 1 }
        end

        CYK.UI.CreateValueChangeText(textValue, target, color)
        return value
    end

    return self
end
