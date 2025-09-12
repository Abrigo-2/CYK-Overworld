return function(self)

    -- Tileset data that I can't (or didn't know how to) store in Ogmo
    self.tilesets = {}
    self.tilesets["field"] = {
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 2, 3, 4, 5, 6, 7, 8}, -- Animation frames
        3/30, -- Speed
        false -- Has a center tile
    
    }
    self.tilesets["redzone"] = {
        {0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 4, 4, 4, 4, 3, 2, 1}, -- Animation frames
        4/15, -- Speed
        false -- Has a center tile
    }

    -- speakerInfo data for the Textbox may also be added from here!
    self.TextBox.speakerInfo["Lancer"] = "[voice:v_lancer]"
    self.TextBox.speakerInfo["Gentle"] = "[novoice]"

    -- Called every frame, right after detections for triggers.
    function self.RoomUpdate(roomName)
        if self.room.layers == nil then return end
        
        if roomName == "Room1" or roomName == "Room4" then
            local poseur = Overworld.FindObjectInRoom("Triggers", 2)
            local running = poseur["sprite"] and poseur.isDetecting
            if running then
                
                if  poseur.hitbox.x + (poseur["dirX"]*8)  < 160 then
                    poseur["dirX"] =  0
                    poseur["dirY"] = -1
                end
                if  poseur.hitbox.x + (poseur["dirX"]*8) > 880 then
                    poseur["dirX"] =  0
                    poseur["dirY"] =  1
                end
                if (-poseur.hitbox.y) - (poseur["dirY"]*8) > 600 then
                    poseur["dirX"] =  1
                    poseur["dirY"] =  0
                end
                if (-poseur.hitbox.y) - (poseur["dirY"]*8) < 114 then
                    poseur["dirX"] = -1
                    poseur["dirY"] =  0
                end
                
                poseur.hitbox.Move(poseur["dirX"]*8, poseur["dirY"]*8)
                -- Manually move the sprite, sadly. Adjust the offset as well.
                poseur["sprite"].x = poseur.hitbox.x + 40
                poseur["sprite"].y = poseur.hitbox.y - 40
            end
        end

    end

    -- Called after everything else on the room has been created.
    -- Here you may create aditional sprites for every room, using the objects added in Ogmo as a reference.
    function self.OnRoomSetup(roomName)
        if     roomName == "Room1" or roomName == "Room4" then
            -- The poseur enemy that moves around the field.
            local poseur = self.FindObjectInRoom("Triggers", 2)
            poseur["sprite"]    = CreateSprite("CreateYourKris/Monsters/Poseur/Idle/0", "OWEntities")
            poseur["sprite"].SetAnimation( 
            { 0, 1, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, 
            3/15, "CreateYourKris/Monsters/Poseur/Idle" )

            poseur["sprite"].MoveTo(poseur.x+36, poseur.y-44)
            poseur["sprite"].SetPivot(.5, 0)
            poseur["sprite"].SetParent(poseur.hitbox)  -- With ysort enabled, though, you'll have to move it manually.

            poseur["sprite"]["ysort"] = true
            table.insert(self.overworldYSortQueue,  poseur["sprite"])
            table.insert(self.spriteTrashQueue,     poseur["sprite"])

            poseur["dirX"] = -1
            poseur["dirY"] = 0

            -- Change the encounter of the poseur enemy, according to the current party.
            if self.party[3] ~= nil then
                if self.party[3].name == "OWSusie" then
                    poseur.encounterName = "S-Example"  end
                
                if self.party[3].name == "OWGentle" then
                    poseur.encounterName = "Z-Example"  end

            end
        elseif roomName == "PartyChangingRoom" then
            local lancer = self.FindObjectInRoom("Triggers", 0)
            -- Check if lancer already was created, since this function will be ran more than once.
            if lancer["sprite"] == nil then
                lancer["animPrefix"] =  "Overworld/Lancer"
                lancer["quiet"]      =  { 0 }
                lancer["talking"]    =  { 1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 9, 9 }

                lancer["sprite"]    = CreateSprite("Overworld/Lancer/0", "OWEntities")
                lancer["animspeed"] = 1/9

                lancer["sprite"].SetPivot(0.5, .5)
                lancer["sprite"].MoveTo(lancer.x+25, lancer.y)
                lancer["sprite"].SetParent(lancer.hitbox)  -- Do this, and you won't have to delete it manually once the room is destroyed!
            end

            -- Following code just hides the carboard cutouts.
            if self.party[3] ~= nil then
                local susie = self.FindObjectInRoom("Assets", 3)
                susie.alpha = 1
                if self.party[3].name == "OWSusie" then
                    susie.alpha = 0 end
                
                local gentle = self.FindObjectInRoom("Assets", 5)
                gentle.alpha = 1
                if self.party[3].name == "OWGentle" then
                    gentle.alpha = 0 end

            end

            local starwalker = self.FindObjectInRoom("Assets", 4)
            starwalker.alpha = 1
            if self.party[4] ~= nil or self.party[3] == nil then
                starwalker.alpha = 0 end
            
        end
    end
    
    -- Happens on the bridge between a room and another.
    function self.RoomExiting(roomCurrent, roomNext)
    end

    -- You'll normally use this function to "hide" or "disable" an enemy after its given encounter.
    function self.OnEncounterEnding(encounter)
        local room = self.roomName
        if (room =="Room1" and encounter == "WhatevertheGeek") then
            NewAudio.PlayMusic("BGM",  "AUDIO_FROLIC",  true, 0.65)
            self.story = 3
        end

        if (room =="hallway002" and encounter == "ming_cat") then
            local kitty = self.FindObjectInRoom("CombatNode", 3)
            kitty["sprite"].alpha = 0

            self.story = 3
            self.OnRoomSetup(room)
        end
    end

    -- Called whenever the player interacts with an Interactable trigger by pressing the Confirm button.
    -- Modify if you don't want to simply start a textbox.
    function self.HandleInteractable(nextDialogue)
        if nextDialogue == "party-starwalker" and self.party[3] == nil then
            nextDialogue = "party-starwalker-cant"
        end


        local isAbove      = (Overworld.party[1].posY < Misc.cameraY+182)

        Overworld.TextBox.CreateTextbox( 
            self.Dialogues.getDialogue(self.roomName, nextDialogue),
            isAbove, Overworld.TextBox.closingModeEnum.toControllable
        )

        self.StopPlayer()
    end
    
    -- Handles a choice picked during the end of a Textbox. This way, you can use the information given to perform different code.
    function self.HandleChoice(pick)
        if pick == "close" then
            self.canControl = ( self.currentCutscene == nil )
            return
        end
        
        if pick == "party-susie-add" then
            Audio.PlaySound("pickup")
            self.SwapPartyMember(3, "OWSusie")
            self.OnRoomSetup(self.roomName)

        elseif pick == "party-gentle-add" then
            Audio.PlaySound("pickup")
            self.SwapPartyMember(3, "OWGentle")
            self.OnRoomSetup(self.roomName)

        elseif pick == "party-starwalker-add" then
            Audio.PlaySound("pickup")
            self.SwapPartyMember(4, "OWStarwalker")
            self.OnRoomSetup(self.roomName)
        end

        self.TextBox.CreateTextbox( Overworld.Dialogues.getDialogue(self.roomName, pick) )
    end

end