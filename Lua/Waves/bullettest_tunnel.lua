require "Libraries/CYK/Sandboxing/WaveBegin" -- NEEDED FOR CYK TO RUN PROPERLY

-- The sword tunnel attack but with the goofy-looking demo bullet.
spawntimer = 0
bullets = { }

targetYoffset = 0

cdtime = 6

function Update()
    
    spawntimer = spawntimer + 1

    if spawntimer == 10 then
        -- This line may seem odd, but it changes the player's speed for the wave.
        FakeArena.playerSpeed = 5
        
        targetYoffset = Player.y
    end
    if spawntimer >= 10 and (spawntimer%cdtime == 0) then
        for i=1, 2 do
            local bullet = CreateProjectile('bulletTall', 380, targetYoffset)
            local yoffset = (Player.sprite.height*1.88 + bullet.sprite.height/2) * ( (i==1) and 1 or -1 )
            bullet.MoveTo( bullet.x, bullet.y + yoffset )
            bullet.SetVar('velx', -6)
            bullet["TPGain"] = 0.5
            table.insert(bullets, bullet)
        end
    end

    if (spawntimer%(cdtime*4) == 0) then
        local increment = (math.random(-6, 5) + 1)*9.5
        local newYoffset = targetYoffset + increment
        
        -- Measure whether the next offset would be undodgeable.
        local tooHigh = ( (newYoffset) >= 48 )
        local tooLow  = ( (newYoffset) <= -48 )
        if tooHigh or tooLow then
            newYoffset = targetYoffset - increment  end
        
        targetYoffset = newYoffset
    end

    for i=1,#bullets do
        local bullet = bullets[i]
        local velx = bullet.GetVar('velx')
        local newposx = bullet.x + velx
        bullet.MoveTo(newposx, bullet.y)
        bullet.SetVar('velx', velx - 0.45)
    end
end

function OnHit()
    return "33%", .3
end

require "Libraries/CYK/Sandboxing/WaveEnd" -- NEEDED FOR CYK TO RUN PROPERLY