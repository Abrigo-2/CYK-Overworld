return function(newENV)
_ENV = newENV
----- DO NOT MODIFY ABOVE -----

-- Stats section
hp = 110  -- The amount of hp for the player. 


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
animsFolder = "Susie"

animations = {
    Idle =  { { 1, 2, 3, 4 },
                1, {} 
            },
    Walk =  { { 2, 1, 3, 1,         -- 1
                5, 4, 6, 4,         -- 2
                8, 7, 9, 7,         -- 3
                11, 10, 12, 10, },  -- 4

                8 / 30, {} 
            },
    BattleIntro =  { { 1 },
                       1 / 15, {} 
            },
}


----- DO NOT MODIFY BELOW -----
end