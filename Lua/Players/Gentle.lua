return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

--hp = 321  -- This will be overwritten by the Overworld's party hp at the start of every battle. You may not want to modify this.
maxhp = 321
atk = 22
def = 0

-- CYK variables
mag = 22                                       -- MAGIC stat of the Player
powers =    { "" }                             -- Powers of the Player (Give them a use if you want.)
abilities = { "ChargedMash" }                  -- Abilities of the Player. If the Player has "Act", they won't be able to use spells!
playerColor = { .32, .32, .7 }                 -- Color used in this Player's main UI
atkBarColor = { 67/255, 72/255, 164/255 }      -- Color used in this Player's atk bar
atkHitColor = { .5, .5, 230/255 }              -- Color used in this Player's atk bar's hitzone
damageColor = { 144/255, 157/255, 228/255 }    -- Color used in this Player's damage text

AddSpell("ChargedMash", "Charged Damage", 66, "Enemy")

-- Check the "Special Variables" page of the documentation to learn how to modify this mess
animations = {
    Defend =        { { 0, 1, 2, 3, 4 },                                                 1 / 11, { heartShift = { -15, -20 }, targetShift = { -4, -12 },
                                                                                                   loop = "ONESHOT", posShift = { -20,  0 } }              },
    Down =          { { 0 },                                                             1,      { loop = "ONESHOT", heartShift = { -40, -50 } },          },
    EndBattle =     { { 0, 1, 2, 3, 4, 4, 4, 5, 6, 7, 8, 9, 10, 10, 11, 12, 13 },        2 / 15, { loop = "ONESHOT" }                                      },
    Fight =         { { 0, 0, 1, 2, 3 },                                                 1 / 15, { loop = "ONESHOT", posShift = { 0, -2 } }                },
    Magic =         { { 0, 0, 1, 2, 3, 4, 5, 6, 6, 7, 8, 9, 10, 11 },                    1 / 14, { loop = "ONESHOT", posShift = { 0, -2 } }                },
    Power =         { { 0, 1, 1, 2, 3, 4 },                                              1 / 15, { loop = "ONESHOT", posShift = { 0, -2 } }                },
    Hurt =          { { 0 },                                                             .6,      { next = "Idle", heartShift = { -15, -20 } },             },
    Intro =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8 },                                     1 / 15, { next = "Idle" },                                        },
    Idle =          { { 1, 2, 3, 0 },                                                    1 /  6, { heartShift = { -15, -20 }, targetShift = { -4, -12 } }, },
    Item =          { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },                              1 / 15, { next = "Idle", actionFrame=7 }                          },
    PrepareAct =    { { 0, 1, 2, 3 },                                                    1 /  6, { posShift = { 8,  4 } },                                 },
    PrepareMagic =  { { 0, 1, 2, 3 },                                                    1 /  6, { },                                                      },
    PrepareFight =  { { 0 },                                                             1,      { },                                                      },
    PrepareItem  =  { { 0, 1, 0, 1, 0, 2, 2, 2, 0, 1, 0, 1, 0, 3, 3, 3,
                        0, 1, 0, 1, 0, 1, 0, 4, 5, 4, 5, 4, 5, 1 },                      1 /  8, { },                                                      },
    PrepareSpare =  { { 0, 1, 2, 3 },                                                    1 /  6, { posShift = { 8,  4 } },                                 },
    Spare =         { { 0, 1, 2, 3, 4, 5, 6, 6, 7, 8, 9, 10 },                           1 / 12, { next = "Idle", actionFrame=4 }                          },
    SliceAnim =     { { 0, 1, 2, 3 },                                                    2 / 15, { loop = "ONESHOTEMPTY" },                                },
    -- Acts go here.
    Pose =          { { 0, 1, 2, 3 },                                                    1 /  4, { posShift = { 8,  4 } },                                 },
}
healAnimOffsetX = -3
healAnimOffsetY = -8


-- Started when this Player casts a spell through the MAGIC command
-- This is called at the start of the turn.
function PrepareCustomSpell(target, spell)
    BattleDialog({ name .. " cast " .. subAction .. "!" })
end

-- This is called once the MAGIC or otherwise overwritten animation is done playing.
function HandleCustomSpell(target, spell)
    castingActive = spell
    WaitBeforeNextPlayerTurn()
end

castingActive = ""
castingEnd = false

ChargedMashes = {}
MashRocks = {}
function UpdateTurn(frame, absoluteFrame)
    if castingActive == "ChargedMash" then
        if frame == 0 then
            for i=1, 6 do
               local blur = CreateSprite( sprite.spritename, "Background")
                blur.SetPivot(0, 0)
                blur.MoveToAbs(sprite.absx, sprite.absy)

                blur.alpha = 0.69 - 0.01 * i 
                table.insert(blurs, blur)
            end
            
            Audio.PlaySound("chargeup")
        elseif frame == 36 then
            SetCYKAnimation("Power")
            Audio.PlaySound("criticalslice")
        elseif frame == 44 then
            for i = 1, 3 do
                local charge = CreateSprite("ChargedMash/0", "Entity")
                charge["frame"] = 0
                charge.SetPivot(.5, 0)
                charge.Scale(2.1, 2.66)
                charge.absx = target.sprite.absx + target.sprite.width /2
                charge.absy = target.sprite.absy
                table.insert(ChargedMashes, charge)
            end
            
            Attack(target, 1, "ChargedMash")
        end

        for i=#ChargedMashes, 1, -1 do
            local cm = ChargedMashes[i]

            cm.xscale = cm.xscale * ((i==#ChargedMashes) and 1.04 or 1.023)
            cm.yscale = cm.yscale * ((i==#ChargedMashes) and 0.84 or 0.90)

            cm.alpha = 0.33
            if i == #ChargedMashes - 1 then
                cm.Move(-2.3*cm.xscale, 0)
            elseif i == #ChargedMashes - 2 then
                cm.Move( 2.3*cm.xscale, 0)
            else
                cm.alpha = .88
            end
            
            if frame%5 == 0 then
                if cm["frame"] > 7 then
                    cm.Remove()
                    table.remove(ChargedMashes, i)
                    cm = nil
                else
                    cm.Set("ChargedMash/" .. cm["frame"])
                    cm["frame"] = cm["frame"] + 1
                end
                
            end
        end

        if frame > 44 and #ChargedMashes == 0 then
            castingEnd = true
        end

    end

    local autoskip = (CYK.TxtMgr.text.currentReferenceCharacter <= 1)
    if castingEnd and (Input.Confirm == 1 or autoskip) then
        SetCYKAnimation("Idle")
        
        castingEnd = false
        castingActive = ""
        EndPlayerTurn()
    end
    
end

blurs = {}
function Update()
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

-- Function called whenever this entity's animation is changed.
-- Make it return true if you want the animation to be changed like normal, otherwise do your own stuff here!
function HandleAnimationChange(newAnim) end

----- DO NOT MODIFY BELOW -----
end