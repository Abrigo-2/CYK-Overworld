return function(CYK)
    local self = { }

    -- savebox
    self.sprite = CreateSprite("UI/Save Screen", "LowerUI")
    self.sprite.MoveTo(0, 0)
    self.sprite.SetPivot(0, 0)
    
    -- Texts from the box
    self.texts = {}
    self.font = "[font:uidialog][instant]"

    -- Player's name.
    self.name = CreateText( { self.font .. "Kris" }, 
                            {0, 0}, 200, "UpperUI")
    self.name.MoveTo(33, 126)
    self.name.SetParent(self.sprite)
    table.insert(self.texts, self.name)


    -- Amount of Level
    self.stats = CreateText( { self.font .. "LV 1" }, 
                            {0, 0}, 80, "UpperUI")
    self.stats.MoveTo(243, 126)
    self.stats.SetParent(self.sprite)
    table.insert(self.texts, self.stats)

    -- Savepoint's location.
    self.location = CreateText( { self.font .. "??????" }, 
                            {0, 0}, 420, "UpperUI")
    self.location.MoveTo(33, 86)
    self.location.SetParent(self.sprite)
    table.insert(self.texts, self.location)

    -- Confirm "button"
    self.confirm = CreateText( { self.font .. "Save" }, 
                            {0, 0}, 420, "UpperUI")
    self.confirm.MoveTo(63, 26)
    self.confirm.SetParent(self.sprite)
    table.insert(self.texts, self.confirm)

    -- Back/Cancel button.
    self.back = CreateText( { self.font .. "Return" }, 
                            {0, 0}, 420, "UpperUI")
    self.back.MoveTo(243, 26)
    self.back.SetParent(self.sprite)
    table.insert(self.texts, self.back)

    -- Heart Cursor
    self.cursor = CreateSprite("UI/cursor", "UpperUI")
    self.cursor.color = {1,0,0}
    self.cursor.MoveTo(42, 37)
    self.cursor.SetParent(self.sprite)

    for i=1, #self.texts do
        self.texts[i].progressmode = "none"
        self.texts[i].HideBubble()
    end

    self.States = {none=0, Active=1, afterSave=2} -- a State machine!
    self.state = self.States.none -- afterSave happens once the player has saved succesfully, and all the text turns yellow.
    self.isCancelSelected = false -- Checks whether the cursor is hovering next to the Confirm or the Cancel options.

    self.locationName = ""  -- The name of the SAVEPOINT.


    function self.Update()
        if self.state == self.States.afterSave then
            if Input.Confirm == 1 then
                self.Hide()
                Overworld.canControl = true
            end
        else
            if Input.Right == 1 then
                self.isCancelSelected = true
                self.cursor.MoveTo(10, -50)
            elseif Input.Left == 1 then
                self.isCancelSelected = false
                self.cursor.MoveTo(-169, -50)
            end

            if Input.Confirm == 1 then
                if self.isCancelSelected then
                    self.Hide()
                    Overworld.canControl = true
                else
                    -- Actually save data.
                    SetAlMightyGlobal("saveStoryProgress", Overworld.story)
                    for i=1, #Overworld.storyFlags do
                        SetAlMightyGlobal( "saveStoryFlag" .. tostring(i), Overworld.storyFlags[i])
                    end

                    for i=1, 4 do  -- Max ammount of party members saved at the time. Change if you will.
                        local partyName = ""
                        if i <= #Overworld.party then
                            partyName = Overworld.party[i].name end
                        SetAlMightyGlobal( "saveParty" .. tostring(i), partyName)
                    end

                    SetAlMightyGlobal("saveLocationName", self.locationName)
                    SetAlMightyGlobal("saveBGM",  Overworld.BGM.name)
                    SetAlMightyGlobal("saveRoom", Overworld.roomName)

                    -- ...workin on it. workin on WHAT?
                    Audio.PlaySound("menu/snd_save")

                    -- VFX
                    for i=1, #self.texts do
                        self.texts[i].color = {1, 1, 0}
                    end
                    self.back.alpha = 0
                    self.confirm.SetText(self.font .."File saved.")

                    local str = self.font .. self.locationName
                    self.location.SetText(str)
                    
                    self.cursor.alpha = 0
                    self.state = self.States.afterSave
                end

            end

        end

    end

    -- Shows.
    function self.Show()
        -- MOVE!
        self.sprite.x = Misc.cameraX + 106
        self.sprite.y = Misc.cameraY + 196

        -- SHOW.
        self.cursor.alpha = 1
        self.sprite.alpha = 1
        for i=1, #self.texts do
            self.texts[i].alpha = 1
        end
        self.confirm.SetText("[font:uidialog][instant]Save")
        self.cursor.MoveTo(-169, -50)
    end

    -- Goes into a corner, gallantly curls into a ball and cries.
    function self.Hide()
        self.cursor.alpha = 0
        self.sprite.alpha = 0
        for i=1, #self.texts do
            self.texts[i].color = {1, 1, 1}
            self.texts[i].alpha = 0
        end

        self.locationName = ""

        self.isCancelSelected = false
        self.state = self.States.none

    end
    self.Hide()

    return self
end