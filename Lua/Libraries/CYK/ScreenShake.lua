return function(CYK)
    local self = { }

    self.stuffToShake = { }
    self.shakeInProgress = nil
    self.shakeStartX = 0
    self.shakeStartY = 0

    -- As oposed to the original CYK's module, this use the Misc.camera object to shake the screen, rather than the inividual sprites.
    function self.Shake(intensity, frames)
        local shake = { frames = frames, fading = true }

        if not intensity then    intensity = 4                end
        if not shake.frames then shake.frames = 10            end

        if not shake.fading then shake.fading = false         end

        shake.xMove = intensity
        shake.yMove = intensity
        shake.start = CYK.frame

        if not self.shakeInProgress then
            self.shakeStartX = Misc.cameraX
            self.shakeStartY = Misc.cameraY
        end

        self.shakeInProgress = shake
    end

    -- Update the screen shaking effect
    function self.Update()
        if self.shakeInProgress then
            local shake = self.shakeInProgress
            local frame = CYK.frame - shake.start

            local fadingCoeff = shake.fading and frame / shake.frames or 1
            
            -- Sets the position in to move the camera at.
            local newX = self.shakeStartX
            local newY = self.shakeStartY
            
            -- perform shake while active like what do you want me to tell you just frikin read. 
            if frame < shake.frames then
                local xMove = shake.xMove * (1 - 2 * math.random())
                local yMove = shake.yMove * (1 - 2 * math.random())

                newX = newX + xMove * fadingCoeff
                newY = newY + yMove * fadingCoeff
            end

            -- Moves the camera AND relevant UI nodes.
            Misc.MoveCameraTo(newX, newY)

            CYK.UI.relocateUI()

            if frame == shake.frames then
                self.shakeInProgress = nil  end
            
        end
    end

    return self
end