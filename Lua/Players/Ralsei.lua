return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

--hp = 70  -- This will be overwritten by the Overworld's party hp at the start of every battle. You may not want to use this.
atk = 8
def = 4

-- CYK variables
mag = 7                                    -- MAGIC stat of the Player
powers = { "Kindness", "Fluffiness" }      -- Powers of the Player (Unused)
abilities = { "Pacify", "Heal Prayer" }    -- Abilities of the Player. If the Player has "Act", he won't be able to use spells!
playerColor = { 0, 1, 0 }                  -- Color used in this Player's main UI
atkBarColor = { 0, .5, 0 }                 -- Color used in this Player's atk bar
atkHitColor = { 180/255, 230/255, 29/255 } -- Color used in this Player's atk bar's hitzone
damageColor = { 128/255, 1, 128/255 }      -- Color used in this Player's damage text

AddSpell("Pacify", "Spare TIRED foe", 16*5/2, "Enemy")
AddSpell("Heal Prayer", "Heal Ally", 10*5/2, "Player")

-- Check the "Special Variables" page of the documentation to learn how to modify this mess
animations = {
    Defend =        { { 0, 1, 2, 3, 4 },                                    1 / 15, { loop = "ONESHOT", targetShift = { -14, 11 } } },
    Down =          { { 0 },                                                1,      { loop = "ONESHOT" },                           },
    EndBattle =     { { 0, 1, 3, 2, 3, 2, 3, 2, 4, 5, 6, 7, 8, 9, 10, 11 }, 2 / 15, { loop = "ONESHOT" }                            },
    Fight =         { { 0, 1, 2, 3, 4, 5 },                                 1 / 15, { loop = "ONESHOT" }                            },
    Hurt =          { { 0 },                                                .6,      { next = "Idle" },                              },
    Idle =          { { 0, 1, 2, 3, 4 },                                    1 /  7, { targetShift = { -14, 11 } },                  },
    Intro =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8 },                        1 / 15, { next = "Idle" }                               },
    Item =          { { 0, 1, 2, 3, 4, 5, 0, 6 },                           1 / 15, { next = "Idle", actionFrame=5 }                            },
    Magic =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8 },                        1 / 16, { next = "Idle", actionFrame=5 }                            },
    PrepareAct =    { { 0 },                                                1,      { loop = "ONESHOT" },                           },
    PrepareFight =  { { 0 },                                                1,      { loop = "ONESHOT" },                           },
    PrepareItem =   { { 0 },                                                1,      { loop = "ONESHOT" },                           },
    PrepareMagic =  { { 0, 1, 2, 3 },                                       2 / 15, { },                                            },
    PrepareSpare =  { { 0 },                                                1,      { loop = "ONESHOT" },                           },
    Sing =          { { 0, 1, 2 },                                          2 / 15, { }                                             },
    Spare =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 },                     1 / 16, { next = "Idle", actionFrame=5 }                              },
    SliceAnim =     { { 0, 1, 2, 3 },                                       2 / 15, { loop = "ONESHOTEMPTY" }                       },
}
healAnimOffsetX = 0
healAnimOffsetY = 6

-- Started when this Player casts a spell through the MAGIC command
-- This is called at the start of the turn.
function PrepareCustomSpell(target, spell)

    local text = { name .. " cast " .. subAction .. "!" }
    -- You could, for instance, change the animation to be played here as well.
    --if spell == "Pacify" then
    --    SetCYKAnimation("Fight")  end

    if spell == "Pacify" and not target.tired then
        if target.canspare then
            text[1] = text[1] .. "\nBut the foe was not [color:0008ff]TIRED[color:ffffff][charspacing:10]... [charspacing:1]try [color:ffff00]SPARING[color:ffffff]!"
        else
            text[1] = text[1] .. "\nBut the enemy wasn't [color:0008ff]TIRED[color:ffffff][charspacing:10]..."
        end
        
    end

    BattleDialog(text)
end

-- This is called once the MAGIC or otherwise overwritten animation is done playing.
function HandleCustomSpell(target, spell)
    local spellData = CYK.spells[spell]

    if spell == "Pacify" then
        if target.tired then target.TrySpare()
        else CYK.StartSecondaryAnimation(CYK.animationChannelsName.flashFailPacify, target)  end
    elseif spell == "Heal Prayer" then
        target.Heal(mag * 5)
    end

end

-- Function called whenever this entity's animation is changed.
-- Make it return true if you want the newAnim animation to be played, otherwise do your own stuff here!
function HandleAnimationChange(newAnim) end

----- DO NOT MODIFY BELOW -----
end