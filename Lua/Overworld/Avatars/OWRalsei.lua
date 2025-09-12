return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

-- Stats section
hp = 45  -- The amount of hp for the player. 
maxhp = 70


-- Movement section.
-- The direction in which the player faces. Goes 1 to 4. (No diagonal support)
direction = 1

-- Collision box! This is only taken into acount for movement. The player's exact coordinate point is used on anything else.
hitbox = {
    -- The box's offset from the player's origin.
    startX = -12,
    startY = 0,
    -- Size.
    width  = 24,
    height = 28
}

-- Animation section. 
-- The folder inside Overworld/ in which the sprites will be searched for.
animsFolder = "Ralsei"

animations = {
    Idle =  { { 1, 2, 3, 4 },
                1, {} 
            },
    Walk =  { { 2, 1, 4, 1,         -- 1
                6, 5, 8, 5,         -- 2
                10, 9, 12, 9,       -- 3
                14, 13, 16, 13, },  -- 4

                8 / 30, {} 
            },
    BattleIntro =  { { 1 },
                       1 / 15, {} 
            },
    HitEnemy =  { { 1 },
                    1, {} 
            },
}

----- DO NOT MODIFY BELOW -----
end