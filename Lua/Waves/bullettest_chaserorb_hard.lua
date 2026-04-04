require "Libraries/CYK/Sandboxing/WaveBegin" -- NEEDED FOR CYK TO RUN PROPERLY

-- The chasing attack from the documentation example.
mult = 1.5
mult2 = 11.1
orbs = {nil, nil, nil}
orbs[1] = CreateProjectile('bullet', Arena.width*mult*1.5, Arena.height*mult)
orbs[2] = CreateProjectile('bullet', -Arena.width*mult*1.5, Arena.height*mult)
orbs[3] = CreateProjectile('bullet', 0, -Arena.height*mult)

for i=1, 3 do
    orbs[i].SetVar('xspeed', 0)
    orbs[i].SetVar('yspeed', 0)
end

local lastPlayerSpot = {x=0, y=0}
timer = 0

function Update()
    if timer % 16 == 0 then
        lastPlayerSpot.x = Player.x
        lastPlayerSpot.y = Player.y 

        mult2 = mult2 / 1.015
    end
    timer = timer + 1

    if timer == 3 then
        -- This line may seem odd, but it changes the player's speed for the wave.
        FakeArena.playerSpeed = 5
    end

    for i=1, 3 do
        local chasingbullet = orbs[i]

        local xdifference = lastPlayerSpot.x - chasingbullet.x
        local ydifference = lastPlayerSpot.y - chasingbullet.y
        
        local xspeed = chasingbullet.GetVar('xspeed') + (xdifference / ((18 + 0.5*i) * mult2) )
        local yspeed = chasingbullet.GetVar('yspeed') + (ydifference / (18 * mult2) )
        
        if math.abs(xspeed) > 8.2 then
            xspeed = xspeed * 0.84 end
        if math.abs(yspeed) > 6.2 then
            yspeed = yspeed * 0.84 end
        
        chasingbullet.Move(xspeed*0.92, yspeed*0.92)
        chasingbullet.SetVar('xspeed', xspeed)
        chasingbullet.SetVar('yspeed', yspeed)
    end
end

--function OnHit()
--    return "150%", 2
--end

require "Libraries/CYK/Sandboxing/WaveEnd" -- NEEDED FOR CYK TO RUN PROPERLY