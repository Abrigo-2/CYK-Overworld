return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

--hp = 90  -- This will be overwritten by the Overworld's party hp at the start of every battle. You may not want to use this.
atk = 10
def = 4

-- CYK variables
mag = 0                               -- MAGIC stat of the Player
powers = { "Guts" }                   -- Powers of the Player (Unused)
abilities = { "Act" }                 -- Abilities of the Player. If the Player has "Act", they won't be able to use spells!
playerColor = { 0, 1, 1 }             -- Color used in this Player's main UI
atkBarColor = { 0, 0, .5 }            -- Color used in this Player's atk bar
atkHitColor = { 0, 162/255, 232/255 } -- Color used in this Player's atk bar's hitzone
damageColor = { 128/255, 1, 1 }       -- Color used in this Player's damage text

-- Check the "Special Variables" page of the documentation to learn how to modify this mess
animations = {
    Defend =        { { 0, 1, 2, 3, 4, 5 },                 1 / 15, { loop = "ONESHOT", heartShift = { -30, -30 }, targetShift = { -14, -22 } } },
    Down =          { { 0 },                                1,      { loop = "ONESHOT", heartShift = { -40, -50 } },                            },
    EndBattle =     { { 0, 1, 2, 3, 4, 5, 6, 7, 8 },        2 / 15, { loop = "ONESHOT" }                                                        },
    Fight =         { { 0, 1, 2, 3, 4, 5, 6 },              1 / 15, { loop = "ONESHOT", posShift = { 0, -12 } }                                 },
    Hurt =          { { 0 },                                .6,      { next = "Idle", heartShift = { -30, -30 } },                               },
    Intro =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8 },        1 / 15, { next = "Idle" },                                                          },
    Idle =          { { 0, 1, 2, 3, 4, 5 },                 1 /  7, { heartShift = { -30, -30 }, targetShift = { -14, -22 } },                  },
    Item =          { { 0, 1, 2, 3, 4, 5 },                 1 / 15, { next = "Idle" }                                                           },
    PrepareAct =    { { 0, 1 },                             2 / 15, { },                                                                        },
    PrepareFight =  { { 0 },                                1,      { },                                                                        },
    PrepareItem =   { { 0 },                                1,      { },                                                                        },
    PrepareSpare =  { { 0, 1 },                             2 / 15, { },                                                                        },
    Spare =         { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, 1 / 15, { next = "Idle", actionFrame=5 }                                                           },
    SliceAnim =     { { 0, 1, 2 },                          2 / 15, { loop = "ONESHOTEMPTY" },                                                  },
    -- Acts go below.
    Pose =          { { 0, 1, 2, 3 }, 1 / 4, { posShift = { 2, 0 } }                                                                            },
}

-- Started when this Player casts a spell through the MAGIC command.
-- Kris can't use spells. so this won't get used.
function HandleCustomSpell(target, spell) end

-- Function called whenever this entity's animation is changed.
-- Make it return true if you want the animation to be changed like normal, otherwise do your own stuff here!
function HandleAnimationChange(newAnim) end

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

----- DO NOT MODIFY BELOW -----
end