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
    self.cover.Scale(760, 560)
    self.cover.color = { 0, 0, 0 }
    self.cover.alpha = 0


    function self.CreateBackground(isActive, isFadeActive)
        self.isActive = isActive
        self.isFadeActive = isFadeActive

        if self.isActive then

            -- Purple squarey background
            self.grids = { }  -- Stores the grid's sprites.
            self.dir = { }    -- Stores the grid's movement direction and speed.

            for i = 1, 2 do
                local bg = CreateSprite("CreateYourKris/bg-default" .. (CYK.CrateYourKris and "Troll" or ""), "Background")
                bg.setParent(self.cover)
                bg.setPivot(1, 1)
                bg.x = 320
                bg.y = 240 + (i == 1 and 0 or -10)
                bg["startX"] = bg.x
                bg["startY"] = bg.y
                if i > 1 then
                    bg.alpha = 0.6
                end
                bg["alphaMax"] = bg.alpha
                table.insert(self.grids, bg)
                table.insert(self.dir, i == 1 and -.5 or .2)
            end

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
        self.cover.absy = Misc.cameraY
        self.cover.alpha = 0

        for i=1, #self.grids do
            self.grids[i].alpha = 0 end

        self.animframe = 0
        self.isBeingShown = true
    end
    function self.Hide ()
        self.cover.absx = Misc.cameraX
        self.cover.absy = Misc.cameraY
        
        self.cover.alpha = 1
        for i=1, #self.grids do
            self.grids[i].alpha = self.grids[i]["alphaMax"]
        end
        
        self.isActive = false

        self.animframe = 30
        self.isBeingHidden = true
    end

    -- Updates the background
    function self.Update()
        if self.isBeingShown then
            
            self.cover.alpha = self.cover.alpha + 1/30
            for i=1, #self.grids do
                self.grids[i].alpha = self.grids[i].alpha + self.grids[i]["alphaMax"]/30
            end
                
            self.animframe = self.animframe + 1

            if self.animframe >= 30 then
                self.isBeingShown = false end
            
        end

        if self.isBeingHidden then
            
            self.cover.alpha = self.cover.alpha - 1/30
            for i=1, #self.grids do
                self.grids[i].alpha = self.grids[i].alpha - self.grids[i]["alphaMax"]/30
            end

            if self.animframe <= 0 then
                for i = #self.grids, 1, -1 do
                    self.grids[i].Remove()
                    table.remove(self.grids, i)
                end
                self.cover.alpha = 0
                self.fade.Remove()
                
                self.isBeingHidden = false
            end

            self.animframe = self.animframe - 1
        end
        
        -- Move the purple square grids at different speeds if the background's active
        if self.isActive then
            for i = 1, #self.grids do
                local bg = self.grids[i]
                bg.Move(self.dir[i], -self.dir[i])
                if bg.x > bg["startX"] then
                    bg.x = bg.x - 51
                elseif bg.x < bg["startX"] - 51 then
                    bg.x = bg.x + 51
                end
                if bg.y > bg["startY"] + 51 then
                    bg.y = bg.y - 51
                elseif bg.y < bg["startY"] then
                    bg.y = bg.y + 51
                end
            end
        end

        -- Change the fade sprite's alpha in order do dim down the background
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

    -- Dims down the background
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