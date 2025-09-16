-- This library handles everything related to the background
return function(CYK)
    local self = { }

    self.isActive = false   -- These two will be replaced once the next Battle file is loaded, so dread not.
    self.isFadeActive = false

    self.isBeingShown = false
    self.isBeingHidden = false

    self.animframe = 0

    -- Hide that old UT
    CYK.hider = CreateSprite("px", "Background")
    CYK.hider.absx = 320
    CYK.hider.absy = 240
    CYK.hider.Scale(640, 480)
    CYK.hider.color = { 0, 0, 0 }

    self.cover = CreateSprite("px", "Background")
    self.cover.SetPivot(0, 0)
    self.cover.absx = 0
    self.cover.absy = 0
    self.cover.Scale(640, 560)
    self.cover.color = { 0, 0, 0 }
    self.cover.alpha = 0

    
    function wrap(x_max, x_min, x)
        return (((x - x_min) % (x_max - x_min)) + (x_max - x_min)) % (x_max - x_min) + x_min 
    end

    function self.CreateBackground(isActive, isFadeActive)
        self.isActive = isActive
        self.isFadeActive = isFadeActive

        -- Cool (i hope!) lines
        self.frontrow = { }
        self.backrow = { }

        if self.isActive then
            --#region Front Lines
            for i = 0, 1 do
                local bg = CreateSprite("CreateYourKris/bg-blue", "Background")
                bg.SetPivot(1, 0)
                bg.absx = (640 + (i * 720)) + Misc.cameraX
                bg.absy = Misc.cameraY

                bg["runX"] = 640 + (i * 720)
                bg["runY"] = 0

                table.insert(self.frontrow, bg)
            end
            for i = 0, 1 do
                local bg = CreateSprite("CreateYourKris/bg-blue", "Background")
                bg.SetPivot(1, 0)
                bg.absx = (640 + (i * 720)) + Misc.cameraX
                bg.absy = Misc.cameraY - 562

                bg["runX"] = 640 + (i * 720)
                bg["runY"] = -562

                table.insert(self.frontrow, bg)
            end
            --#endregion

            --#region Back Lines 
            for i = 0, 1 do
                local bg = CreateSprite("CreateYourKris/bg-blue", "Background")
                bg.SetPivot(0, 1)
                bg.absx = Misc.cameraX + (0 - (i * 720)) 
                bg.absy = Misc.cameraY + 480
                bg.alpha = 0.6

                bg["runX"] = 0 - (i * 720)
                bg["runY"] = 480

                table.insert(self.backrow, bg)
            end
            for i = 0, 1 do
                local bg = CreateSprite("CreateYourKris/bg-blue", "Background")
                bg.SetPivot(0, 1)
                bg.absx = Misc.cameraX + (0 - (i * 720))
                bg.absy = Misc.cameraY - 80
                bg.alpha = 0.6

                bg["runX"] = 0 - (i * 720)
                bg["runY"] = -80

                table.insert(self.backrow, bg)
            end
            --#endregion

            self.Show()
        end

        -- This black sprite is used to "fade" the background
        -- It's actually just this sprite's alpha changing so the background can be darker
        if self.isFadeActive then
            self.fade = CreateSprite("px", "Background")
            self.fade.absx = Misc.cameraX + 320
            self.fade.absy = Misc.cameraY + 240
            self.fade.Scale(640, 480)
            self.fade.color = { 0, 0, 0 }
            self.fade.alpha = 0
    
            self.shown = true
            self.maxHideTimer = -1
            self.hideTimer = -1
            self.anim = nil
        end
        
    end

    -- This functions are dedicated to the intro/outro of the background in the Overworld.
    function self.Show ()
        self.cover.absx = Misc.cameraX
        self.cover.absy = Misc.cameraY-480
        self.cover.alpha = 1

        for i = 1, #self.frontrow do
            local bg = self.frontrow[i]
            bg.Move(0, -484)
        end

        for i = 1, #self.backrow do
            local bg = self.backrow[i]
            bg.Move(0, -484)
        end

        self.animframe = 0
        self.isBeingShown = true
    end
    function self.Hide ()
        self.cover.absx = Misc.cameraX
        self.cover.absy = Misc.cameraY
        self.cover.alpha = 1
        self.isActive = false

        self.animframe = 20
        self.isBeingHidden = true
    end

    -- Updates the background
    function self.Update()
        if self.isBeingShown then
            
            self.cover.Move(0, 24)

            for i = 1, #self.frontrow do
                self.frontrow[i].Move(0, 24) end

            for i = 1, #self.backrow do
                self.backrow[i].Move(0, 24) end

            self.animframe = self.animframe + 1

            if self.animframe >= 20 then
                self.isBeingShown = false end

        end

        if self.isBeingHidden then

            self.cover.Move(0, -24)

            for i = 1, #self.frontrow do
                self.frontrow[i].Move(0, -56) end

            for i = 1, #self.backrow do
                self.backrow[i].Move(0, -56) end

            if self.animframe <= 0 then
                for i = #self.frontrow, 1, -1 do
                    self.frontrow[i].Remove()
                    table.remove(self.frontrow, i)
                end
                for i = #self.backrow, 1, -1 do
                    self.backrow[i].Remove()
                    table.remove(self.backrow, i)
                end
                self.cover.alpha = 0
                self.fade.Remove()
                
                self.isBeingHidden = false
            end
            
            self.animframe = self.animframe - 1

        end
        
        local zero = {x = Misc.cameraX, y = Misc.cameraY}
        -- Move the cool blue lines at different speeds if the background's active
        if self.isActive then
            for i = 1, #self.frontrow do
                local bg = self.frontrow[i]
                bg.Move(-1, 1)
                bg["runX"] = bg["runX"] - 1
                bg["runY"] = bg["runY"] + 1

                
                if bg["runX"] <= 0 then
                    bg.absx = zero.x + 640 + 800
                    bg["runX"] = 640 + 800
                end
                if bg["runY"] >= 480  then
                    bg.absy = zero.y - 646
                    bg["runY"] = -644
                end
            end

            for i = 1, #self.backrow do
                local bg = self.backrow[i]
                bg.Move(2.5, 2.5)
                bg["runX"] = bg["runX"] + 2.5
                bg["runY"] = bg["runY"] + 2.5

                if bg["runX"] >= 640 then
                    bg.absx = zero.x - 801
                    bg["runX"] = -800
                end
                if bg["runY"] >= 1030  then
                    bg.absy = zero.y - 94
                    bg["runY"] = -92
                end

            end
        end

        -- Change the fade sprite's alpha when the background is fading in or out
        if self.anim and self.isFadeActive then
            local alpha = self.maxHideTimer == 0 and (self.anim == "show" and 0 or 0.5)
                                                 or  (self.anim == "show" and (self.hideTimer / self.maxHideTimer) * 0.5
                                                                          or  0.5 - self.hideTimer / self.maxHideTimer * 0.5)
            self.fade.alpha = alpha

            self.hideTimer = self.hideTimer - 1
            if self.hideTimer == -1 then
                self.shown = self.anim == "show"
                self.anim = nil
                return
            end
        end

    end

    -- Dims the background
    function self.Dimmen(show, timer)
        if self.isFadeActive then
            self.hideTimer = timer or 0
            self.maxHideTimer = timer or 0
            self.anim = show and "show" or "hide"
            self.shown = true
        end
    end

    return self
end