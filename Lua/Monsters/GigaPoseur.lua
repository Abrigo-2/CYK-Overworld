return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

-- A basic Enemy Entity script skeleton you can copy and modify for your own creations.
comments = { "Smells like the work of an enemy stand.", "Poseur is posing like his life depends on it.", "Poseur's limbs shouldn't be moving in this way." }
randomdialogue = {
    { "Check it out.",            "Please"                     },
    { "Check it out again.",      "...",      "For real now"   },
    { "I'll show you something.", "Trust me."                  },
    { "Keep looking!",            "Harder!",  "I SAID HARDER!" },
      "It's working."
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
function HandleAttack(attacker, attackstatus)
    if attackstatus == -1 then
        -- Player pressed fight but didn't press Z afterwards
        AddBubbleToTurn("Do no harm, " .. attacker.name .. ".\n")
        AddBubbleToTurn("")
        InstantBubbleToTurn("[voice:v_ralsei]Cripes!", true, 2)
        InstantBubbleToTurn("[voice:v_susie]$!$?", true, 3)
    else
        -- Player did actually attack
        if attackstatus < 50 then
            AddBubbleToTurn("You're strong, " .. attacker.name .. "!\n")

            if (hp > maxhp*7/10) then
                if attacker.name == "Ralsei" then
                    AddBubbleToTurn("[voice:v_ralsei]Thank you!", true, attacker.ID)
                elseif attacker.name == "Susie" then
                    AddBubbleToTurn("[voice:v_susie]Heh.", true, attacker.ID) end
            end
        else
            AddBubbleToTurn("Too strong, " .. attacker.name .. "...\n")

            if (hp > maxhp*7/10) then
                if attacker.name == "Ralsei" then
                    AddBubbleToTurn("[voice:v_ralsei]Sorry...!!", true, attacker.ID)
                elseif attacker.name == "Susie" then
                    AddBubbleToTurn("[voice:v_susie]You bet!!", true, attacker.ID) end
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
            --CYK.SetAnim( posingPlayers[j], "Pose" )
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
        AddBubbleToTurn("Not bad...")

    elseif (chapter2 and GetMercyPercent()>=70) or (posecount > 4)  then     -- winning him over.
        text = text .. "\nPoseur is certainly growing more impressed...!"
        AddBubbleToTurn("Almost!")

    else
        if command == "Pose" then      -- not even close to winning him over
            text = text .. "\n...but Poseur was barely impressed."
            AddBubbleToTurn("Hmm.")
        elseif command ~= "Talk" then  -- starting the process of winning him over
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

----- DO NOT MODIFY BELOW -----
end