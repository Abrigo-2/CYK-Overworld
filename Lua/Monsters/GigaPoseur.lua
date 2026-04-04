return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

-- A basic Enemy Entity script skeleton you can copy and modify for your own creations.
comments = { "Smells like the work of an enemy stand.", "Poseur is posing like his life depends on it.", "Poseur's limbs shouldn't be moving in this way." }
randomdialogue = {
    { "Be not afraid.",                              },
    { "Might before Meetle.", "Stove under Keetle."  },
    { "Show me something.",  "Make me proud."                  },
    { "Keep looking!",            "Harder!",  "I SAID HARDER!" },
      "It's all smooth sailing."
}

commands = { "Check", "Talk", "Pose", "S-Pose", "Z-Pose" }
AddAct("Check", "", 0)
AddAct("Talk", "Little chit-chat", 0)
AddAct("Pose", "Show him who's cool!", 0)
AddAct("S-Pose", "Show him who RULES!", 20*5/2, { "Susie" })
AddAct("Z-Pose", "Show him good!!", 20*5/2, { "Gentle" })

hp = 600
atk = 8
def = 0
dialogbubble = "CH1wide" -- See documentation for what bubbles you have available.
check = "A Poseur of the greater variety.[w:4] Watch yourself around him."
canspare = false
sparebeg = -1

useMercyCounter=true
isTiredWhenHPLow=true

-- CYK variables
mag = 9001            -- MAGIC stat of the enemy
targetType = "single" -- Specifies how many (or which) target(s) this enemy's bullets will target
tired = false         -- If true, the Player will be able to spare this enemy using the spell "Pacify"

-- Check the "Special Variables" page of the documentation to learn how to modify this mess
animations = {
    Hurt      = { { 0 },                                           1     , { next = "Idle" } },
    Idle      = { { 0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, 1 / 15, { }               },
    Spareable = { { 0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, 1 / 15, { }               },
}

-- Triggered just before computing an attack on this target
function BeforeDamageCalculation(attacker, damageCoeff)
    -- Good location to set the damage dealt to this enemy using self.SetDamage()
    if damageCoeff > 0 then
        --SetDamage(666)
    end
end

-- Triggered when a Player attacks (or misses) this enemy in the ATTACKING state
function HandleAttack(attacker, damage)
    if damage == -1 then
        -- Player pressed fight but didn't press Z afterwards
        AddBubbleToTurn("Do no harm, " .. attacker.name .. ".\n")
        AddBubbleToTurn("")
        CYK.InstantBubbleToTurn("[voice:v_ralsei]Cripes!", true, 2)
        if CYK.players[3].name == "Susie" then
            CYK.InstantBubbleToTurn("[voice:v_susie]$!$?", true, 3)  end
    else
        -- Player did actually attack
        if damage < 50 then
            if (hp > maxhp*8/10) then
                if attacker.name == "Gentle" then
                    AddBubbleToTurn("You're strong, gentle fellow!\n")
                else
                    AddBubbleToTurn("You're strong, " .. attacker.name .. "!\n")
                end
                
                if attacker.name == "Ralsei" then
                    attacker.AddBubbleToTurn("[voice:v_ralsei]Thank you!")
                elseif attacker.name == "Susie" then
                    attacker.AddBubbleToTurn("[voice:v_susie]Heh.") end
            end
        else
            if (hp > maxhp*8/10) then
                if attacker.name == "Gentle" then
                    AddBubbleToTurn("Too strong, gentle fellow...\n")
                else
                    AddBubbleToTurn("Too strong, " .. attacker.name .. "...\n")
                end
            

                if attacker.name == "Ralsei" then
                    attacker.AddBubbleToTurn("[voice:v_ralsei]Sorry...!!")
                elseif attacker.name == "Susie" then
                    attacker.AddBubbleToTurn("[voice:v_susie]You bet!!") end
            end
        end

    end
end

posecount = 0

-- Triggered when a Player uses an Act on this enemy.
-- You don't need an all-caps version of the act commands here.
function HandleCustomCommand(user, command)
    local text = ""
    
    local posingPlayer = {}
    if command == "Check" then
        text = { name .. " - " .. atk .. " ATK " .. def .. " DEF\n" .. check }
    elseif command == "Talk" then
        AddBubbleToTurn("... *yawns*")
        text = "You try to talk with Poseur, but he pays your words no mind."

    elseif command == "Pose" then
        if chapter2 then ChangeMercyPercent(10)
        else  posecount = posecount + 1 end
        text = "You posed dramatically...[w:4]"

        posingPlayers = { CYK.players[1] }
    elseif command == "S-Pose" then
        if chapter2 then ChangeMercyPercent(35)
        else  posecount = posecount + 3 end
        text = "You and Susie posed dramatically![w:4] "

        posingPlayers = { CYK.players[1], CYK.players[3] }
    elseif command == "Z-Pose" then
        if chapter2 then ChangeMercyPercent(35)
        else  posecount = posecount + 3 end
        text = "You and the gentle fellow posed...![w:4] "
        
        posingPlayers = { CYK.players[1], CYK.players[3] }
    end

    if command == "Pose" or command == "Z-Pose" or command == "S-Pose" then
        for j=1, #posingPlayers do
            CYK.SetAnim( posingPlayers[j], "Pose" )
            for i=1, 6 do
                local blur = CreateSprite( posingPlayers[j].sprite.spritename, "Background")
                blur.SetPivot(0, 0)
                blur.MoveToAbs(posingPlayers[j].sprite.absx, posingPlayers[j].sprite.absy)

                blur.alpha = 0.69 - 0.01 * i 
                table.insert(posingPlayers[j].blurs, blur)
            end
        end

    end

    
    if (chapter2 and GetMercyPercent()>=100) or (posecount >= 9) then -- Won him over.
        if not canspare then
            table.insert(comments, "Poseur is impressed by your posing power.")
        end
        canspare = true
        SetCYKAnimation("Idle")

        text = text .. "\nPoseur is finally impressed by your endeavors!"
        AddBubbleToTurn("Well done.")

    elseif (chapter2 and GetMercyPercent()>=70) or (posecount > 4)  then     -- winning him over.
        text = text .. "\nPoseur is certainly growing more impressed...!"
        AddBubbleToTurn("Almost!")

    else
        if command == "Pose" then      -- not even close to winning him over
            text = text .. "\n...but Poseur was barely impressed."
            AddBubbleToTurn("Hmm.")
        elseif command == "Z-Pose" and command == "S-Pose" then  -- starting the process of winning him over
            text = text .. "\n...but Poseur wasn't impressed enough."
            AddBubbleToTurn("Not bad...")
        end
    end

    BattleDialog({ text })
end

-- Function called whenever this entity's animation is changed.
-- Make it return true if you want the animation to be changed like normal, otherwise do your own stuff here!
function HandleAnimationChange(newAnim)
    local oldAnim = self.sprite["currAnim"]
    if newAnim == "Idle" and canspare then
        SetCYKAnimation("Spareable")
        return false
    end
end


wingsSprite = nil
wingSpriteBuilt = false
function Update()
    --if not isactive then    return  end

    if not wingSpriteBuilt then
        wingSpriteBuilt = true
        
        wingsSprite = CreateSprite("CreateYourKris/Monsters/GigaPoseur/Wings/0", "Entity")
        wingsSprite.MoveToAbs(self.sprite.absx, self.sprite.absy)
        wingsSprite.Move(35, 40)
        wingsSprite.SetParent(self.sprite)

        wingsSprite.alpha = 0
    end
    

    if wingsSprite.isactive then

        if self.spareOrFleeStart > 0 then
            local frame = CYK.frame - self.spareOrFleeStart - 1

            if frame < 20 then
                local percent = 1.0 - (frame/20.0)
                wingsSprite.alpha = 0.5 * percent
            elseif frame >= 20 then
                wingsSprite.Remove()
            end
        elseif self.sprite.isactive then
            --- The Monster's sprite is removed as soon as the flee animation starts!
            wingsSprite.alpha = math.min(self.sprite.alpha, 0.5)

            wingsSprite.MoveTo(0, 3.33*math.cos( (CYK.frame/64) * math.pi ))
        end
    end
    

    ---
end



----- DO NOT MODIFY BELOW -----
end