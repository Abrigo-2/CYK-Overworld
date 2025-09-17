return function(CYK)
    local self = { }

    -- Textbox sprite.
    self.textbox = CreateSprite("UI/Textbox", "LowerUI")
    self.textbox.SetPivot(0, 0)
    self.textbox["offsetX"] = 24
    self.textbox["offsetY"] = 12
    self.textbox.alpha = 0

    -- The corners of the textbox.
    self.corners = {}
    for i = 1, 4 do
        local c = CreateSprite("UI/Corners/0", "LowerUI")
        c.setAnimation(
            {0, 0, 1, 2, 3,
            4, 4, 3, 2, 1 }, 1/5, "UI/Corners")
        c.SetParent(self.textbox)
        c.SetPivot(0, 1)
        c.alpha = 0
        self.corners[i] = c
    end
    -- Top left
    self.corners[1].y = 83
    -- Bottom left
    self.corners[2].Scale(1, -1)
    -- Top right
    self.corners[3].Scale(-1, 1)
    self.corners[3].x = 296
    self.corners[3].y = 83
    -- Bottom right
    self.corners[4].Scale(-1, -1)
    self.corners[4].x = 296

    -- The X position and max width are overwritten later, so don't bother modifying these.
    -- If you want to change the X positions, check self.textAnchor.
    -- If you want to change the max width, check the hardcoded values within ScanTextLine
    
    -- Main text
    self.text = CreateText({ "" }, {600, 200}, 500, "UpperUI")
    self.text.SetParent(self.textbox)
    self.text.progressmode = "none"
    self.text.HideBubble()
    self.text.x = 30
    self.text.y = 109
    self.text.deleteWhenFinished = false

    -- SHINY SPARKLING text!!!
    self.textShiny = CreateText({ "" }, {600, 200}, 500, "UpperUI")
    self.textShiny.SetParent(self.textbox)
    self.textShiny.progressmode = "none"
    self.textShiny.HideBubble()
    self.textShiny.x = 30
    self.textShiny.y = self.text.y
    self.textShiny.deleteWhenFinished = false

    -- Little star at the side of the text.
    self.textstar = CreateText({ "" }, {600, 200}, 540, "LowerUI")
    self.textstar.SetParent(self.textbox)
    self.textstar.progressmode = "none"
    self.textstar.HideBubble()
    self.textstar.x = 41
    self.textstar.y = self.text.y + 3
    self.textstar.deleteWhenFinished = false

    
    -- SPEAKER INFO
    self.speakerInfo = {}
    self.speakerInfo["Ralsei"] = "[voice:v_ralsei]"
    self.speakerInfo["Susie"] = "[voice:v_susie]"

    self.faceSprite = CreateSprite("empty", "UpperUI")
    self.faceSprite.SetPivot(0.5, 0)
    self.faceSprite.SetAnchor(0, 0)
    self.faceSprite.SetParent(self.textbox)
    self.faceSprite.x = 84
    self.faceSprite.y = 30
    self.faceSprite.alpha = 0

    self.textAnchor = {72, 172}  -- Determines the position for the text, and its shiny effect. Second value is when there's a mugshot on.
    self.starOffset = 30

    self.dialogueCurrent = 1         -- The ID of the current page (dialogue) being diplayed
    self.dialogueTotal  = ""           -- The maximum amounts of pages. Once dialogueCurrent exceeds it, the textbox will try to close. 

    self.isAbove = false  -- Moves the textbox to the top, in case it was told to via SetText

    self.closingModeEnum = { toNothing=1, toControllable=2, toChoice=3, toSavepoint=4 }
    self.closingMode = true  -- Determines what the textbox is ought to do when closing.

    self.States = { DIALOGUE=false, CHOICE=true }
    self.state = self.States.DIALOGUE

    self.isActive = false  -- More of a shorthand. The code usually considers the Textbox's alpha rather than this,


    -- I never grasped the concept of recursivity btw.
    function self.replaceWaitShorthand(txt, it)
        local s2 = string.sub(txt, it+1)
        s2 = string.reverse(s2)
        s2 = string.sub(s2, string.len(s2)) .. "]"

        local s1 = string.sub(txt, 1, it-1) .. "[w:"
        local send = s1 .. s2 .. string.sub(txt, it+2)
        return send
    end

    -- Shows the textbox instead of making a new one
    function self.CreateTextbox(text, isAbove, closingMode)
        local _isAbove = isAbove or false
        local _closingMode = closingMode or self.closingModeEnum.toControllable

        self.SetText(text, _isAbove, _closingMode)
    end

    -- Sets the textbox's text
    function self.SetText(text, isAbove, closingMode)
        self.text.progressmode = "none"
        self.closingMode = closingMode
        self.isAbove = isAbove

        self.dialogueCurrent = 1

        self.text.x  = self.textAnchor[1]
        self.textstar.x = self.textAnchor[1] - self.starOffset

        self.textbox.MoveToAbs(
            Misc.cameraX + self.textbox["offsetX"], 
            Misc.cameraY + self.textbox["offsetY"] + (self.isAbove and 292 or 0))
        
        self.textbox.alpha = 1
        for i = 1, 4 do
            self.corners[i].alpha = 1 end

        self.state = self.States.DIALOGUE
        

        -- This would be a good place to pause your cutscene/animation!!
        Overworld.canControl = false
        self.isActive = true


        -- Determines if a choice will be prompted by the end of this dialogue.
        -- This will happen if the last text argument is a table, rather than a string.
        if type(text[#text]) ~= "string" then
            self.choiceMeta = table.copy(text[#text])
            table.remove(text, #text)

            self.closingMode = self.closingModeEnum.toChoice
        end

        local newtext = {}
        local textstar = table.copy(text)
        local textShiny = table.copy(text)
        for i = 1, #text do
            -- find fake command earlier
            while string.find(text[i], "°") ~= nil do
                local txt = text[i]
                text[i] = self.replaceWaitShorthand(txt, string.find(txt, "°"))
            end

            local commandsEnd = self.GetCommandEnd(text[i])
            local textCommands = commandsEnd > 1 and string.sub(text[i], 1, commandsEnd - 1) or ""
            local textRealText = commandsEnd > 1 and string.sub(text[i], commandsEnd, #text[i]) or text[i]
            local voiceinfo = ""

            if string.find(textCommands, "SetMugshot") then
                local speakerid = textCommands:gsub("func:SetMugshot,", "")
                speakerid = speakerid.split(speakerid, '.')[1]
                
                voiceinfo = speakerid:gsub("%[", "")
                if self.speakerInfo[voiceinfo] == nil then
                    error("Value " .. voiceinfo .. " wasn't set in speakerInfo. Make sure to check the TextboxManager script.")
                else
                    voiceinfo = self.speakerInfo[voiceinfo]
                end

            end
            newtext[i] = "[font:uidialog2OW][speed:1.5][voice:monsterfont-s]" .. textCommands .. voiceinfo .. "¤¤" .. string.gsub(string.gsub(textRealText, "\n", "\n¤¤"), "\r", "\n")
            textShiny[i] = "[font:vertgradientOW][speed:1.5][novoice]".. "¤¤" .. string.gsub(string.gsub(self.SilenceText(textRealText), "\n", "\n¤¤"), "\r", "\n")

            textstar[i]   = "[font:uidialog2OW][speed:1.5]" .. self.SilenceText(textCommands) .. "[novoice]*[charspacing:-37] [charspacing:1][alpha:00]" ..
                        string.gsub(string.gsub(self.SilenceText(textRealText), "\n", "\n[alpha:ff]*[charspacing:-37] [charspacing:1][alpha:00]"), "\r", "\n")
            
        end

        self.dialogueTotal = newtext
        self.ScanTextLine()
        self.text.SetText(newtext)
        self.textShiny.SetText(textShiny)
        self.textstar.SetText(textstar)

    end

    -- Handles a string and "silences" any dangerous command in it
    function self.SilenceText(text)
        local index = 1
        local bracketCount = 0
        local bracketBegin = -1
        while index <= #text do
            local char = text[index]
            -- Char is opening bracket
            if char == "[" then
                if bracketCount == 0 then
                    bracketBegin = index
                end
                bracketCount = bracketCount + 1
            -- Char is closing bracket
            elseif char == "]" then
                bracketCount = bracketCount - 1
                -- If this is the end of a command, isolate it and see what we should do depending on what it is
                if bracketCount == 0 then
                    local command = string.sub(text, bracketBegin + 1, index - 1)
                    local commandName = string.split(command, ":")[1]
                    -- Remove any func, color or alpha call
                    if commandName == "func" or commandName == "color" or commandName == "alpha" then
                        text = string.sub(text, 1, bracketBegin - 1) .. (#text < index and "" or string.sub(text, index + 1, #text))
                        index = bracketBegin - 1
                    -- Add [novoice] to any font or voice call
                    elseif commandName == "font" or commandName == "voice" then
                        text = string.sub(text, 1, index) .. "[novoice]" .. (#text < index and "" or string.sub(text, index + 1, #text))
                        index = index + 9
                    end
                    bracketBegin = -1
                -- Too many brackets: omit it
                elseif bracketCount < 0 then
                    bracketCount = 0
                end
            end

            index = index + 1
        end
        return text
    end

    function self.GetCommandEnd(text)
        local braCount = 0
        local charIndex = 1
        while braCount > 0 or text[charIndex] == "[" do
            if text[charIndex] == "[" then
                braCount = braCount + 1
            elseif text[charIndex] == "]" then
                braCount = braCount - 1
            end
            charIndex = charIndex + 1
            if #text < charIndex then
                charIndex = #text + 1
                break
            end
        end
        return charIndex
    end


    -- Called when all of the dialogue's lines have been read.
    function self.TextboxEnd()
        -- Takes care of an Overworld bug.
        for k, id in pairs(Overworld.talkingSprites) do
            if id ~= nil then  TalkingSprite(id, false)  end
        end

        -- Textbox related.
        self.cold = 0
        if  self.closingMode == self.closingModeEnum.toChoice then
            self.text.SetText("[novoice]")
            self.textShiny.SetText("[novoice]")
            self.textstar.SetText("[novoice]")

            self.SetChoice(self.choiceMeta)
            self.state = self.States.CHOICE
        else
            self.Close()
            if self.closingMode == self.closingModeEnum.toSavepoint then
                Overworld.SaveObj.Show()
                Overworld.SaveObj.state = Overworld.SaveObj.States.Active
            -- The Textbox is closing to neither a Savepoint nor a choice: check whether to return player control.
            else
                Overworld.canControl = (self.closingMode == self.closingModeEnum.toControllable)
            end

        end
    end

    -- Set the Textbox's labels blank, then hides its sprites. 
    function self.Close()
        self.SetText({ "[novoice]" }, false, self.closingMode)
        self.textstar.SetText("[novoice]")
        
        self.textbox.alpha = 0
        for i = 1, 4 do
            self.corners[i].alpha = 0 end
        
        self.isActive = false
    end

    self.cold = 0 -- cooldown for skipping text.
    function self.ScanTextLine(nextLine)
        -- Takes care of an Overworld bug.
        for k, id in pairs(Overworld.talkingSprites) do
            if id ~= nil then  TalkingSprite(id, false)  end
        end

        -- Textbox related.
        local doNextLine = false
        self.faceSprite.alpha = 0
        if nextLine then
            if self.text.allLinesComplete then
                self.Close()
            else
                self.dialogueCurrent = self.dialogueCurrent + 1
                doNextLine = true
            end
        end
        if self.dialogueCurrent <= #self.dialogueTotal or not nextLine then
            local text = self.dialogueTotal[self.dialogueCurrent < #self.dialogueTotal and self.dialogueCurrent or #self.dialogueTotal]
            if string.find(text, "SetMugshot") then
                self.text.x  = self.textAnchor[2]
                self.textstar.x = self.textAnchor[2] - self.starOffset
                self.text.textMaxWidth = 384
                self.faceSprite.alpha = nextLine and 1 or 0

                self.textShiny.x  = self.text.x
                self.textShiny.textMaxWidth = self.text.textMaxWidth
            else
                self.text.x  = self.textAnchor[1]
                self.textstar.x = self.textAnchor[1] - self.starOffset
                self.text.textMaxWidth = 498

                self.textShiny.x  = self.text.x
                self.textShiny.textMaxWidth = self.text.textMaxWidth
            end
        end
        if doNextLine then
            self.text.NextLine()
            self.textShiny.NextLine()
            self.textstar.NextLine()
        end
    end


    -- Displays a choice
    self.choiceMeta = {}  -- Contains the text displayed for each choice, and their IDs
    
    self.choiceLabel = {}

    for i=1, 4 do
        self.choiceLabel[i] = CreateText({ "" }, {666, 666}, 172, "UpperUI")
        self.choiceLabel[i].SetParent(self.textbox)
        self.choiceLabel[i].progressmode = "none"
        self.choiceLabel[i].HideBubble()
        self.choiceLabel[i].deleteWhenFinished = false

        self.choiceLabel[i].alpha = 0
    end

    self.cursor = CreateSprite("UI/cursor", "UpperUI")
    self.cursor.color = {1,0,0, 0}
    self.cursor.SetParent(self.textbox)

    self.choiceActive = 0  -- The choice option which is currently lit yellow and has the cursor next to it.

    function self.SetChoice(data)
        self.faceSprite.alpha = 0
        self.cursor.alpha = 1

        local sidePositions = {
            {296, 112},
            {486, 78},
            {224, 36},
            {62,  78}
        }

        for i=1, 4 do
            local current = self.choiceLabel[i]
            if #data[i] > 0 then
                current.SetText("[font:uidialog][novoice][instant]" .. data[i][1])

                local offset = 0
                if i < 4 then
                    offset = current.GetTextWidth() / 2
                end
                current.MoveTo(sidePositions[i][1]-offset, sidePositions[i][2])
                current.alpha = 1
                current.color = {1, 1, 1}
            else
                current.alpha = 0
            end
        end

        self.choiceActive = 0
        self.cursor.MoveTo(0, 0)

    end
    function self.MoveChoiceCursor(nextChoice)
        -- If the next choice is empty, then just don't do anything.
        if self.choiceLabel[nextChoice].alpha ~= 1 then return end
        
        -- First, makes every option white.
        for i=1, 4 do
            self.choiceLabel[i].color = {1, 1, 1}
        end
        
        -- Then move the cursor, set as active.
        local offsetX = -20
        local offsetY = 8
        self.cursor.MoveToAbs(
            self.choiceLabel[nextChoice].absx + offsetX, 
            self.choiceLabel[nextChoice].absy + offsetY
        )
        self.choiceActive = nextChoice

        self.choiceLabel[nextChoice].color = { 1, 1, 0 }
    end

    function self.UpdateTextbox()
        if self.textbox.alpha == 1 then
           
            -- Move the cursor around during a choice.
            if self.state == self.States.CHOICE then
                if Input.Up == 1 then 
                    self.MoveChoiceCursor(1) end 
                if Input.Right == 1 then
                    self.MoveChoiceCursor(2) end 
                if Input.Down == 1 then 
                    self.MoveChoiceCursor(3) end 
                if Input.Left == 1 then 
                    self.MoveChoiceCursor(4) end 
                
                if Input.Confirm == 1 and self.choiceActive ~= 0 then
                    self.cursor.alpha = 0
                    for i=1, 4 do
                        local current = self.choiceLabel[i]
                        current.alpha = 0
                    end

                    self.Close()
                    self.state = self.States.DIALOGUE
                    Overworld.HandleChoice(self.choiceMeta[self.choiceActive][2])
                end
            -- Advance or skip text.
            else
                -- Cooldown before skipping to the next text.
                if self.cold > 0 then
                    self.cold = self.cold - 1   end

                -- Skipping text.
                if (self.cold <= 0 and Input.Menu == 2) then
                    if (self.text.currentLine == self.text.lineCount()-1) then
                        self.TextboxEnd()
                    else
                        self.ScanTextLine(true)
                        self.cold = 6
                    end
                end

                if Input.Confirm == 1 and self.text.allLinesComplete then
                    self.TextboxEnd()
                elseif Input.Confirm == 1 and self.text.lineComplete then
                    self.ScanTextLine(true)
                end
            end
            
            if not self.text.allLinesComplete then
                self.textbox.MoveToAbs(
                Misc.cameraX + self.textbox["offsetX"], 
                Misc.cameraY + self.textbox["offsetY"] + (self.isAbove and 292 or 0))
            end
        end
    end

    function SetMugshot(faceSprite)
        local faceSpriteData = string.split(faceSprite, '.')
        if #faceSpriteData ~= 2 then
            error("SetMugshot needs an argument which is exactly composed of the name of the entity, a dot and the name of the mugshot.\nExample: Ralsei.Normal, Poseur.Pissed", 2)
        end

        Overworld.TextBox.faceSprite.alpha = 1
        Overworld.TextBox.faceSprite.Set("Overworld/FaceSprite/" .. faceSpriteData[1] .. "/" .. faceSpriteData[2])
    end

    return self
end