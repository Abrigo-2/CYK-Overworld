return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

-- Stats section
hp = 1


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
animsFolder = "Starwalker"

animations = {
    Idle =  { { 0, 0, 0, 0 },
                1, {} 
            },
    Walk =  { { 0, 0, 0, 0,      -- 1
                0, 0, 0, 0,      -- 2
                0, 0, 0, 0,      -- 3
                0, 0, 0, 0, },   -- 4

                8 / 30, {} 
            },
    BattleIntro =  { { 0, 0 },
                       1 / 15, {} 
            },
    HitEnemy =  { { 0 },
                    1, {} 
            },
}

----- DO NOT MODIFY BELOW -----
end