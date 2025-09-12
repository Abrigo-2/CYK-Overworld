return function(CYK)
    local self = { }

    self.currentCutscene = nil

    self.frame = 1  -- Frame!
    self.cut = 1    -- Like in a movie! A scene cut!

    -- Large, black sprite that covers the whole screen.
    self.fader = CreateSprite("px", "Top")
    self.fader.SetPivot(0, 1)
    self.fader.x = 0
    self.fader.y = 0
    self.fader.Scale(640, 560)
    self.fader.color = { 0, 0, 0, 0 }

    self.actor = {}

    -- During your animations, you can use this to divide your code into "cuts", for ease of use. Feel free not to use it, though.
    function self.nextCutAt(lastframe)
        -- Will check every frame if lastframe has been exceeded. Then, it'll move on to the next frame.
        if self.frame >= lastframe then
            self.frame = 0  -- Since nextCutAt is often ran right before the frame increment, it's best to leave at 0.
            self.cut = self.cut + 1
        end
    end

    self.isTextboxAbove = false  
    function self.Textbox(dialogueID)
        Overworld.TextBox.CreateTextbox(
            Overworld.Dialogues.getDialogue(Overworld.roomName, dialogueID),
            self.isTextboxAbove,
            Overworld.TextBox.closingModeEnum.toNothing
        )
    
    end
    
    -- Hides/Shows the Overworld's avatars, so that you may use other sprites during cutscenes.
    function self.ToggleAvatars(alpha)
        for i=1, #Overworld.party do
            Overworld.party[i].sprite.alpha = alpha
        end
    end

    function self.UpdateCutscene()
        self.WaitForCutsceneConditions(Overworld.roomName)

        if self.currentCutscene ~= nil then
            self.currentCutscene() end
    end

    -- The gist of it is, you use this function to manually check if the player is at the right room, at the right place, then start a Cutscene.
    function self.WaitForCutsceneConditions(roomID)
        -- To ensure each cutscene only happens once, and in a sequential order, you'll want to make use of the story variable.
        if Overworld.story == 1 and roomID == "Room2" and Overworld.party[1].posX > 308 then
            self.currentCutscene   = ClearingBreak
            self.frame = 1
            self.cut = 1
            
            Overworld.StopPlayer()
            Overworld.canControl = false

            Overworld.story = 2
        end

    end

    function ClearingBreak()
        if Overworld.TextBox.isActive then return end

        if self.cut == 1 then
            if self.frame == 1 then
                self.Textbox("scene1") end
            
            if self.frame == 2 then
                self.ToggleAvatars(0)

                self.actor[1] = CreateSprite("Overworld/Kris/Idle/2", "OWEntities")
                self.actor[1].SetAnimation( { "6", "7", "8", "5" }, 3/15, "Overworld/Kris/walk/" )
                self.actor[1].SetPivot(0.5, 0)
                self.actor[1].MoveTo(Overworld.party[1].posX, Overworld.party[1].posY)

                self.actor[1]["RequiredWalkTimeY"] = math.ceil( (-260 - self.actor[1].absy) / 2 ) + 56

                self.actor[2] = CreateSprite("Overworld/Ralsei/Idle/2", "OWEntities")
                self.actor[2].SetAnimation( { "6", "7", "8", "5" }, 3/15, "Overworld/Ralsei/walk/" )
                self.actor[2].SetPivot(0.5, 0)
                self.actor[2].MoveTo(Overworld.party[2].posX, Overworld.party[2].posY)

                self.actor[2]["RequiredWalkTimeX"] = math.ceil( ( 368 - self.actor[2].absx) / 2 )
                self.actor[2]["RequiredWalkTimeY"] = math.ceil( (-260 - self.actor[2].absy) / 2 ) + self.actor[2]["RequiredWalkTimeX"]
                self.actor[2]["DoneWalking"] = false

                Overworld.cameraFollowPlayer = false
                self.actor[1]["CameraMoveTimeX"] = math.ceil( ( ( 410) - self.actor[1].absx) / 3 )
                self.actor[1]["CameraMoveTimeY"] = math.ceil( ( (-300) - self.actor[1].absy) / 2 )
            end

            if self.frame >= 2 then
                -- Moving Kris...
                if (self.frame <= 56) then
                    self.actor[1].Move(3, 0)

                    if (self.frame == 56) then
                        self.actor[1].SetAnimation( { "2", "3", "4", "1" }, 3/15, "Overworld/Kris/walk/" )
                    end
                elseif (self.frame <= self.actor[1]["RequiredWalkTimeY"]) then
                    self.actor[1].Move(0, 2)

                    if (self.frame == self.actor[1]["RequiredWalkTimeY"]) then
                        self.actor[1].SetAnimation( { "Overworld/Kris/Cutscene/1" } )
                        --self.actor[1].Scale(-1, 0)  -- this doesn't seem to work.
                        Audio.PlaySound("getup")
                    end
                end
                
                -- Moving Ralsei...
                if (self.frame <= 2 + self.actor[2]["RequiredWalkTimeX"]) then
                    self.actor[2].Move(2, 0)

                    if (self.frame == self.actor[2]["RequiredWalkTimeX"]) then
                        self.actor[2].SetAnimation( { "2", "3", "4", "1" }, 3/15, "Overworld/Ralsei/walk/" )
                    end
                elseif (self.frame <= self.actor[2]["RequiredWalkTimeY"]) then
                    self.actor[2].Move(0, 2)

                    if (self.frame == self.actor[2]["RequiredWalkTimeY"]) then
                        self.actor[2].SetAnimation({ "Overworld/Ralsei/Idle/3" })
                    end
                elseif (self.frame == self.actor[2]["RequiredWalkTimeY"] + 24) then
                    self.actor[2].SetAnimation({ "Overworld/Ralsei/Cutscene/1" })
                    Audio.PlaySound("getup")

                    self.actor[2]["DoneWalking"] = true
                end

                -- Moving the camera...
                if self.frame <= self.actor[1]["CameraMoveTimeX"] then
                    Misc.MoveCamera(3, 0)
                elseif (self.frame <= self.actor[1]["CameraMoveTimeY"]) then
                    Misc.MoveCamera(0, 2)
                end

                -- Check for cutscene's end.
                if self.actor[2]["DoneWalking"] then
                    self.nextCutAt(0)  -- Limit at 0 so it'll always happen.
                end

            end

        elseif self.cut == 2 then
            if self.frame == 1 then
                self.Textbox("scene2")

                -- Hurrying text prompt.
                self.actor[1]["scene2Text"] = CreateText(
                    { "[font:uidialog2][instant]* Press the Confirm button" }, 
                    {Misc.cameraX, Misc.cameraY}, 500, "LowerUI" )
                
                self.actor[1]["scene2Text"].progressmode = "none"
                self.actor[1]["scene2Text"].HideBubble()
                self.actor[1]["scene2Text"].alpha = 0

            elseif self.frame >= 24 then
                if self.frame >= 140 then
                    if  self.actor[1]["scene2Text"].alpha < 0.24 then
                        self.actor[1]["scene2Text"].alpha = self.actor[1]["scene2Text"].alpha + 0.24/240
                    end

                    self.actor[1]["scene2Text"].absx = Misc.cameraX + 208 + math.random(-8, 8)
                    self.actor[1]["scene2Text"].absy = Misc.cameraY + 32  + math.random(-6, 6)
                end
                
                if Input.Confirm == 1 or Input.Menu > 0 then
                    self.actor[1]["scene2Text"].Remove()
                    self.nextCutAt(0)
                end
            end

        elseif self.cut == 3 then
            if self.frame == 1 then
                self.actor[2].SetAnimation( { "Overworld/Ralsei/Idle/3" } )
                Audio.PlaySound("getup")
            
            elseif self.frame == 12 then
                self.Textbox("scene3")
            end

            local CameraPanningTime = 30
            if self.frame == 13 then
                self.actor[1].SetAnimation( { "Overworld/Kris/Idle/3" } )
                Audio.PlaySound("getup")

                self.actor[1]["CameraMoveSpeedX"] = (self.actor[1].absx - (Misc.cameraX + 320)) / CameraPanningTime
                self.actor[1]["CameraMoveSpeedY"] = (self.actor[1].absy - (Misc.cameraY + 220)) / CameraPanningTime
                
            elseif self.frame > 24 and self.frame <= (24 + CameraPanningTime) then
                Misc.MoveCamera(self.actor[1]["CameraMoveSpeedX"], self.actor[1]["CameraMoveSpeedY"])
            end

            if self.frame == (24 + CameraPanningTime + 12) then
                Overworld.party[1].MoveToAbs( self.actor[1].absx, self.actor[1].absy )
                Overworld.PlayerLookAt(Overworld.party[1],  3)

                Overworld.party[2].MoveToAbs( self.actor[2].absx, self.actor[2].absy )
                Overworld.PlayerLookAt(Overworld.party[2],  2, true)
                
                Overworld.Movement.MakeFollowPathTowardPlayer(2,  -- Party member ID
                    self.actor[2].absx, self.actor[2].absy,  -- "From" position
                    self.actor[1].absx, self.actor[1].absy,  -- "Towards" position
                    2) -- Direction the party member will look at during the walk.

                -- We don't need the actors anymore, so we send them home.
                self.actor[1].Remove()
                self.actor[2].Remove()
                self.actor = {}

                self.ToggleAvatars(1)  -- Make the party members visible again.
                
                
                self.currentCutscene   = nil
                Overworld.cameraFollowPlayer = true
                Overworld.canControl = true
            end

        end

        self.frame = self.frame + 1
        
    end

    return self
end