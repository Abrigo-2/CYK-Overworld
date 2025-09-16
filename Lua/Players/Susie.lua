return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

--hp = 110  -- This will be overwritten by the Overworld's party hp at the start of every battle. You may not want to use this.
atk = 14
def = 4

-- CYK variables
mag = 3                                      -- MAGIC stat of the Player
powers = { "Rudeness", "Crudeness", "Guts" } -- Powers of the Player (Unused)
abilities = { "Rude Buster", "Ultra Heal" }  -- Abilities of the Player. If the Player has "Act", he won't be able to use spells!
playerColor = { 1, 0, 1 }                    -- Color used in this Player's main UI
atkBarColor = { .5, 0, .5 }                  -- Color used in this Player's atk bar
atkHitColor = { 234/255,  121/255, 200/255 } -- Color used in this Player's atk bar's hitzone
damageColor = { .8,  .6, .8 }                -- Color used in this Player's damage text

AddSpell("Rude Buster", "Rude Damage", 30*5/2, "Enemy")
AddSpell("Ultra Heal",  "Best Healing", 13*5/2, "Player")

-- Check the "Special Variables" page of the documentation to learn how to modify this mess
animations = {
    RudeBuster =    { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 },                     1 / 14, { next = "Idle" },                              },
    Defend =        { { 0, 1, 2, 3, 4, 5 },                                                     1 / 15, { next = "DefendEnd", targetShift = { -7, -20 } } },
    DefendEnd =     { { 0 },                                                                    1,      { loop = "ONESHOT", targetShift = { -7, -20 } } },
    DefendSpeech =  { { 0 },                                                                    1,      { loop = "ONESHOT", targetShift = { -7, -20 } } },
    Down =          { { 0 },                                                                    1,      { loop = "ONESHOT" },                           },
    EndBattle =     { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }, 2 / 15, { loop = "ONESHOT" }                            },
    Fight =         { { 0, 1, 2, 3, 4, 5 },                                                     1 / 15, { loop = "ONESHOT" }                            },
    Hurt =          { { 0 },                                                                    .6,      { next = "Idle" },                              },
    Idle =          { { 0, 1, 2, 3 },                                                           1 /  6, { targetShift = { -7, -20 } },                  },
    Intro =         { { 0, 1, 2, 3, 4, 5, 5, 5, 1 },                                            1 / 15, { next = "Idle" }                               },
    Item =          { { 0, 1, 2, 3, 4, 4 },                                                     1 / 14, { next = "Idle" }                            },
    Magic =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8 },                                            1 / 14, { next = "Idle", actionFrame=8 }                            },
    PrepareAct =    { { 0 },                                                                    1,      { loop = "ONESHOT" },                           },
    PrepareFight =  { { 0 },                                                                    1,      { loop = "ONESHOT" },                           },
    PrepareItem =   { { 0, 1 },                                                                 2 / 15, { },                                            },
    PrepareMagic =  { { 0, 1, 2, 3 },                                                           2 / 15, { },                                            },
    PrepareSpare =  { { 0 },                                                                    1,      { loop = "ONESHOT" },                           },
    Spare =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },                                     1 / 15, { next = "Idle", actionFrame=5 }                               },
    SliceAnim =     { { 0, 1, 2, 3 },                                                           2 / 15, { loop = "ONESHOTEMPTY" }                       },
}
healAnimOffsetX = -2
healAnimOffsetY = -10
bubbleOffsetX = -84
bubbleOffsetY = -25


rudeBusterEndMagic = -1
rudeBusterStartFrame = -1
rudeBusterEndFrame = -1
rudeBustersTrail = { }
rudeBustersHit   = { }
rudeBusterActive = false
rudeBusterAttacked = false
rudeBusterBoosted = false
function UpdateTurn(frame, absoluteFrame)
    if subAction == "Rude Buster" or rudeBusterActive then
        if not rudeBusterActive then
            rudeBusterEndFrame   = -1
            rudeBusterStartFrame = -1
            rudeBusterAttacked = false
            rudeBusterActive = true
            rudeBusterBoosted = false
            SetCYKAnimation("RudeBuster")
        end


        if sprite.currentframe >= 7 and rudeBusterStartFrame == -1 then
            rudeBusterStartFrame = absoluteFrame
            Audio.PlaySound("rudebusterswing")
        end

        if rudeBusterStartFrame > -1 then
            local currentFrame = absoluteFrame - rudeBusterStartFrame
            -- Boosts Rude Buster
            if (currentFrame > 0 and currentFrame <= 20) and Input.Confirm == 1 then
                rudeBusterBoosted = true
            end

            local HitFrame = 20
            -- Before RudeBuster connects, these sprites are created as a trail.
            if currentFrame < HitFrame then
                if (currentFrame) % 2 == 0 then
                    local num = (currentFrame) / 2
                    local startX = sprite.absx + 3 * sprite.width / 4
                    local startY = sprite.absy + sprite.height / 4
                    local shiftX = num / 10 * ((target.sprite.absx + target.sprite.width / 2) - startX)
                    local shiftY = (num / 10 * ((target.sprite.absy + target.sprite.height / 2) - startY)) - 20 * math.cos(math.rad(84 - num * 18))
                    local currPos = { x = startX + shiftX, y = startY + shiftY }
                    
                    local rudeBuster = CreateSprite("RudeBuster/6", "Entity")
                    rudeBuster.SetPivot(1, 0.5)
                    rudeBuster.absx = currPos.x
                    rudeBuster.absy = currPos.y
                    
                    local shrinkPercentX = 0.625 * (num+1)/10 + .375
                    local shrinkPercentY = 0.7   * (num+1)/10 + .3
                    rudeBuster.Scale(
                        2.4 * shrinkPercentX,  2 * shrinkPercentY * 1.3
                    )
                    rudeBuster["startFrame"] = absoluteFrame
                              
                    num = num + 1
                    shiftX = num / 10 * ((target.sprite.absx + target.sprite.width / 2) - startX)
                    shiftY = (num / 10 * ((target.sprite.absy + target.sprite.height / 2) - startY)) - 20 * math.cos(math.rad(84 - num * 18))
                    rudeBuster.rotation = math.deg(math.atan2(startY + shiftY - currPos.y, startX + shiftX - currPos.x))

                    table.insert(rudeBustersTrail, rudeBuster)
                end
            -- These sprites are created once the enemy is hit.
            elseif currentFrame == HitFrame then
                for i = 1, 8 do
                    local rudeBuster = CreateSprite("RudeBuster/0", "Entity")
                    
                    local xMod =   5 --+ ( (i >= 3 and i <= 6) and 25 or -25 )
                    local yMod = -10 --+ ( (i <= 4) and -25 or 25 )
                    rudeBuster.absx = target.sprite.absx + target.sprite.width/2  + xMod
                    rudeBuster.absy = target.sprite.absy + target.sprite.height/2 + yMod
                    
                    rudeBuster.rotation = 45 + 90 * math.floor((i - 1) / 2)
                    rudeBuster.Scale(2.5, 2.5)
                    rudeBuster.alpha = 6/8
                    
                    rudeBuster["startFrame"] = absoluteFrame
                    rudeBuster["hit"] = true
                    rudeBuster["hitPlus"] = (i%2 == 0)
                    
                    table.insert(rudeBustersHit, rudeBuster)
                end
                Attack(target, rudeBusterBoosted and 2 or 1, "RudeBuster")
                rudeBusterAttacked = true
            end

            -- Update the Buster's trails
            for i = #rudeBustersTrail, 1, -1 do
                local rB = rudeBustersTrail[i]
                local frame = absoluteFrame - rB["startFrame"]
                    
                if currentFrame < HitFrame then
                    -- Trail's alpha.
                    if #rudeBustersTrail <= 2 then
                        rB.alpha = 0.42 * (i / #rudeBustersTrail)
                        rB.alpha = rB.alpha + 0.08
                    else
                        rB.alpha = 0.6 * (i / #rudeBustersTrail)
                        if i == #rudeBustersTrail then
                            rB.alpha = 1  end
                    end

                    rB.yscale = rB.yscale * 0.99
                    rB.xscale = rB.xscale * 1.015
                else
                    if (currentFrame == HitFrame and i == #rudeBustersTrail) then
                        rB.alpha = 0.6
                    end

                    if currentFrame > HitFrame+5 then
                        rB.alpha = rB.alpha - 0.06 * (1-rB.alpha)
                    end

                    --local yscale = rB.yscale - (1/10)
                    --rB.yscale = (yscale>0) and yscale or 0
                    rB.yscale = rB.yscale * 0.94
                end

                if frame == 30 then
                    rB.Remove()
                    table.remove(rudeBustersTrail, i)
                    rB = nil
                elseif frame % 4 == 0 then
                    rB.Set("RudeBuster/" .. tostring(6 - (frame%28) / 4))
                end
            end
            -- Update the Buster's Hit trails
            for i = #rudeBustersHit, 1, -1 do
                local rB = rudeBustersHit[i]
                local frame = absoluteFrame - rB["startFrame"]
                local lastFrame = 35

                -- Movement.
                local rotation = math.rad(rB.rotation)
                local coeff = (rudeBusterBoosted and 7.75 or 7.15) * (1.2 - frame / lastFrame) * (rB["hitPlus"] and 1.18 or 1.04)
                rB.Move(math.cos(rotation) * coeff, math.sin(rotation) * coeff)
                rB.xscale = rB.xscale * .88

                if frame == lastFrame then
                    rB.Remove()
                    table.remove(rudeBustersHit, i)
                    if #rudeBustersHit == 0 and not rudeBusterAttacked then
                        rudeBusterActive = false
                    end
                    rB = nil
                elseif frame % 6 == 0 then
                    rB.Set("RudeBuster/" .. tostring((frame%36) / 6))
                end
            end

        end

        if GetCurrentState() == "PLAYERTURN" and CYK.turn == ID then
            if rudeBusterAttacked and #rudeBustersHit == 0 then
                local autoskip = (CYK.TxtMgr.text.currentReferenceCharacter <= 1)
                if rudeBusterEndFrame < 0 then
                    rudeBusterEndFrame = frame + 18
                elseif (frame > rudeBusterEndFrame) and (Input.Confirm == 1 or autoskip) then
                    rudeBusterEndFrame = -1
                    rudeBusterActive = false
                    EndPlayerTurn()
                end
            end

        end

    end
end

-- Started when this Player casts a spell through the MAGIC command
-- This is called at the start of the turn.
function PrepareCustomSpell(target, spell)

    local text = { name .. " cast " .. subAction .. "!" }
    
    -- You could, for instance, change the animation to be played here as well.
    --if spell == "Ultra Heal" then
    --    SetCYKAnimation("Fight")  end

    BattleDialog(text)
end

-- This is called once the MAGIC or otherwise overwritten animation is done playing.
function HandleCustomSpell(target, spell)
    local spellData = CYK.spells[spell]

    if    spell == "Rude Buster" then
        WaitBeforeNextPlayerTurn()
    elseif spell == "Ultra Heal" then
        target.Heal( math.ceil(mag * 1.5) + 11 )
    end
end

-- Function called whenever this entity's animation is changed.
-- Make it return true if you want the animation to be changed like normal, otherwise do your own stuff here!
function HandleAnimationChange(newAnim)
    local oldAnim = self.sprite["currAnim"]
    -- Susie has a special animation in case she gets a speechbubble while defending.
    if (oldAnim == "DefendEnd" or oldAnim == "DefendSpeech") and newAnim == "DefendEnd" then
        if bubble == nil then  return true end
        
        local isSpeaking = ( bubble.alpha > 0 )
        SetCYKAnimation( isSpeaking and "DefendSpeech" or "DefendEnd" )
        return false
    end
    return true
end

blurs = {}
function Update()
    if rudeBusterActive and (GetCurrentState() ~= "PLAYERTURN" or CYK.turn ~= ID) then
        UpdateTurn(-21, CYK.frame)
    end

    if #blurs > 0 then
        local deleteQueue = { }
        
        -- Move and fade the blurs.
        for i = 1, #blurs do
            blurs[i].Move( -0.6*(#blurs-i), 0 )
            blurs[i].alpha = blurs[i].alpha - 1/60
            if blurs[i].alpha <= 0 then
                table.insert(deleteQueue, i)
            end
        end

        -- Delete leftover blurs.
        for i = #deleteQueue, 1, -1 do
            blurs[deleteQueue[i]].Remove()
            table.remove(blurs, deleteQueue[i])
        end

    end
end


----- DO NOT MODIFY BELOW -----
end