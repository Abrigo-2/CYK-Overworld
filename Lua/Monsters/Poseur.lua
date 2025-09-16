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

commands = { "Check", "Talk", "Pose" }
AddAct("Check", "", 0)
AddAct("Talk", "Little chit-chat", 0)
AddAct("Pose", "Show him who's cool!", 0)

hp = 80
atk = 8
def = 0
dialogbubble = "DRBubble" -- See documentation for what bubbles you have available.
check = "Check message goes here."
canspare = false
sparebeg = 3

useMercyCounter=true
isTiredWhenHPLow=true

-- CYK variables
mag = 9001            -- MAGIC stat of the enemy
targetType = "single" -- Specifies how many (or which) target(s) this enemy's bullets will target
tired = false         -- If true, the Player will be able to spare this enemy using the spell "Pacify"

-- Check the "Special Variables" page of the documentation to learn how to modify this mess
animations = {
    Hurt      = { { 0 },                                           .7    , { next = "Idle" } },
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
        table.insert(currentdialogue, "Do no harm, " .. attacker.name .. ".\n")
    else
        -- Player did actually attack
        if attackstatus < 50 then
            table.insert(currentdialogue, "You're strong, " .. attacker.name .. "!\n")
        else
            table.insert(currentdialogue, "Too strong, " .. attacker.name .. "...\n")
        end
    end
end

posecount = 0

-- Triggered when a Player uses an Act on this enemy.
-- You don't need an all-caps version of the act commands here.
function HandleCustomCommand(user, command)
    local text = { "" }
    
    local posingPlayer = {}
    if command == "Check" then
        text = { name .. " - " .. atk .. " ATK " .. def .. " DEF\n" .. check }
    elseif command == "Talk" then
        if not tired then
            table.insert(comments, "Poseur has trouble staying up.")
        end
        tired = true
        currentdialogue = {"... *yawns*"}
        text = {"You try to talk with Poseur, but all you seem to be able to do is make him yawn."}
    elseif command == "Pose" then
        currentdialogue = {"Not bad."}
        text = {"You posed dramatically...[w:4] \nPoseur was utterly swayed."}

        if not canspare then
            table.insert(comments, "Poseur is impressed by your posing power.")
        end
        canspare = true
        SetCYKAnimation("Idle") -- Refresh the animation
    
    end

    -- Spawn the blurry afterimages.
    if command == "Pose" then
        CYK.SetAnim( CYK.players[1], "Pose" )
        for i=1, 6 do
            local blur = CreateSprite( CYK.players[1].sprite.spritename, "Background")
            blur.SetPivot(0, 0)
            blur.MoveToAbs(CYK.players[1].sprite.absx, CYK.players[1].sprite.absy)

            blur.alpha = 0.69 - 0.01 * i 
            table.insert(CYK.players[1].blurs, blur)
        end
    end

    BattleDialog(text)
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