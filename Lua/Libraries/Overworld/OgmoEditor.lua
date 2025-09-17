return function(self)

    -- Enum.
    self.allDirectionsEnum = { {0, 1} ,  {1, 0} ,  {0, -1} ,  {-1, 0} }  -- Enum
    self.savepoints = {}  -- Stores the savepoint sprites.

    -- Fade sprite thing
    self.fader = CreateSprite("px", "Background")
    self.fader.SetPivot(0, 0)
    self.fader.x = 0
    self.fader.y = 0
    self.fader.Scale(640, 560)
    self.fader.color = { 0, 0, 0, 0 }

    self.roomNext = ""  -- Carries over the ID for the next room.
    
    -- Used for fading the screen to black when a room is changed.
    self.isFadeIn    = false
    self.isFadeOut   = false
    self.fadingFrame = 0    -- Frame used during the room's Fade In/Out animations

    self.BG = nil   -- The Sprite object for the Overworld's Background.
    self.spriteTrashQueue = {}  -- Add here sprites that couldn't be parented, in order to delete them once the Room is destroyed.
    
    -- Used for fading out the current track.
    self.bgmFadeout = false
    self.BGM = {frame = 0, name ="nil", volumeMax = 7}

    self.originID = 1   -- Used for determining the position that the players will be placed at when the Room is created.

    self.allRooms = {}  -- Contains the data for every room within the mod.
    self.room = {}      -- Contains the data for only the currently created room.
    self.roomName = ""

    self.lastBattleTrigger = nil  -- Used to automatically hide the sprite inside the "sprite" property. 

    -- First, loads the path of every available room into the allRooms table.
    for key, value in pairs(Misc.ListDir("/Lua/Overworld/Rooms/")) do
        local fakekey = string.gsub(value, "/Lua/Overworld/Rooms/", "")
        fakekey = string.gsub(value, ".json", "")

        self.allRooms[fakekey] = "/Lua/Overworld/Rooms/" .. value
    end

    -- Then, converts all the json data from the rooms into tables
    function self.ConvertRoomsfromJson()
        for key, value in pairs(self.allRooms) do
            local jsonString = ""
            local file = Misc.OpenFile(value, "r")
            file = file.ReadLines()
            for i=1, #file do
                jsonString = jsonString .. file[i]
            end
            
            file = json.decode_ot_error(jsonString)
            
            self.allRooms[key] = file
        end
    end
    self.ConvertRoomsfromJson()

    -- Names a tile according to its adjacent tiles, e.g. it'll spout whether a tile is at the center, at the top right...
    function self.FindTileAdjacence(tiledata, Xpos, Ypos)
        local x = Xpos
        local y = Ypos
        local id = {empty = -1, full = 0}
        local safedata = tiledata
        -- Oh, this'll be fun.
        --#region Checkers
        -- Check if up/down exists
        if safedata[y-1] == nil then
            safedata[y-1] = {}
        end
        if safedata[y+1] == nil then
            safedata[y+1] = {}
        end
        if safedata[y-1][Xpos] == nil then
            safedata[y-1][Xpos] = id.empty
        end
        if safedata[y+1][Xpos] == nil then
            safedata[y+1][Xpos] = id.empty
        end

        -- Check if left/right exists
        if safedata[Ypos][x-1] == nil then
            safedata[Ypos][x-1] = id.empty
        end
        if safedata[Ypos][x+1] == nil then
            safedata[Ypos][x+1] = id.empty
        end

        -- Check if corners exists
        if safedata[y-1][x-1] == nil then
            safedata[y-1][x-1] = id.empty
        end
        if safedata[y-1][x+1] == nil then
            safedata[y-1][x+1] = id.empty
        end
        if safedata[y+1][x-1] == nil then
            safedata[y+1][x-1] = id.empty
        end
        if safedata[y+1][x+1] == nil then
            safedata[y+1][x+1] = id.empty
        end
        --#endregion

        -- Corners
        if safedata[y-1][x-1] == id.empty 
        and safedata[Ypos][x-1] == id.empty 
        and safedata[y-1][Xpos] == id.empty 
        
        then    return "topleft"

        elseif safedata[y-1][x+1] == id.empty 
        and safedata[Ypos][x+1] == id.empty 
        and safedata[y-1][Xpos] == id.empty 
        
        then    return "topright"
        elseif safedata[y+1][x+1] == id.empty 
        and safedata[Ypos][x+1] == id.empty 
        and safedata[y+1][Xpos] == id.empty 
        
        then    return "bottomright"
        elseif safedata[y+1][x-1] == id.empty 
        and safedata[Ypos][x-1] == id.empty 
        and safedata[y+1][Xpos] == id.empty 
        
        then    return "bottomleft"
        
        -- Not corners??
        elseif safedata[Ypos][x-1] == id.empty then
            return "right"
        elseif safedata[Ypos][x+1] == id.empty then
            return "left"
        elseif safedata[y-1][Xpos] == id.empty then
            return "bottom"
        elseif safedata[y+1][Xpos] == id.empty then
            return "top"
        
        -- Center
        else
            return "center"
        end
    end

    function self.switchBGM(audio)
        if self.BGM.name == "nil" then
            self.BGM.name = audio
            
            NewAudio.SetVolume("BGM", self.BGM.volumeMax)
            NewAudio.PlayMusic("BGM",  self.BGM.name,  true, self.BGM.volumeMax)
            
        else
            self.BGM.name = audio

            local bgm = NewAudio.GetAudioName("BGM"):gsub("music:", "")
            if not (bgm == "" or bgm == "empty") then
                self.BGM.frame = 0
                self.bgmFadeout = true
            end

        end

    end

    -- Fades the background music out. That is, from music to silence.
    function self.UpdateBGMFade()
        if self.bgmFadeout then
            self.BGM.frame = self.BGM.frame + 1
            local f = self.BGM.frame

            if f <= 4 then
                --wait
            elseif NewAudio.GetVolume("BGM") > 0 then
                local volumeStep = self.BGM.volumeMax / 25
                NewAudio.SetVolume("BGM", NewAudio.GetVolume("BGM") - volumeStep )
            else
                self.bgmFadeout = false

                if self.BGM.name == "stop" then
                    NewAudio.Stop( "BGM")
                    NewAudio.SetVolume("BGM", self.BGM.volumeMax)
                else
                    NewAudio.SetVolume("BGM", self.BGM.volumeMax)
                    NewAudio.PlayMusic("BGM",  self.BGM.name,  true, self.BGM.volumeMax)
                end
                self.BGM.name = "nil"
            end
        end
    end

    function self.CreateRoom(roomID)
        local room = table.copy(self.allRooms[roomID])

        if room.values.hasBackground then
            local background = "Assets/bg/" .. roomID
            if  Misc.FileExists(background) then
                self.BG = CreateSprite(background, "OWBackground")
                self.BG.alpha = 1
            else
                self.BG = CreateSprite("px", "OWBackground")
                self.BG.alpha = 0
            end
            self.BG.SetPivot(0,1)
            self.BG.MoveTo(0, 0)
        end
        

        for i=1, #room.layers do
            local layer = room.layers[i]
            
            -- "solid" is a data layer only, so it skips the tile sprite's creation.
            if layer.name == "solid" then
                room.layers["solid"] = table.copy(room.layers[i])
                room.layers[i] = nil
            -- Create tiles for any Tile layers
            elseif layer.data2D ~= nil then
                local tilesetName = tostring(layer.tileset)
                
                local alltiles = {}
                local allanimtiles = {}
                
                -- Tiles are layered like this:
                -- Adjacent tiles > Animated tiles
                
                -- Y'know, I don't think this code was necesa
                local hasAnimatedTiles = false
                local animatedTiles = { frames={}, speed=1, path="" }
                local tilesSpritePath = "Overworld/Tilesets/" .. tilesetName .. "/"
                if Misc.DirExists("Sprites/Overworld/Tilesets/" .. tilesetName .. "/animated") then
                    animatedTiles.frames = self.tilesets[tilesetName][1]
                    animatedTiles.speed = self.tilesets[tilesetName][2]
                    animatedTiles.path = tilesSpritePath .. "/animated/"
                    hasAnimatedTiles = true
                end

                -- Not having a center tile is useful for animated tilesets with aditional borders (e.g, the Field's tileset.)
                local hasCenterTile = self.tilesets[tilesetName][3]

                for Yid=1, #layer.data2D do
                    alltiles[Yid] = {}
                    allanimtiles[Yid] = {}
                    for Xid=1, #layer.data2D[Yid] do
                        if layer.data2D[Yid][Xid] == 0 then
                            if hasAnimatedTiles then
                                local animtile = CreateSprite("px", "animated"..layer.name)
                                animtile.SetAnimation(animatedTiles.frames, animatedTiles.speed, animatedTiles.path)
                                animtile.SetPivot(0,1)
                                local rowX = (Xid*layer.gridCellWidth) - layer.gridCellWidth
                                local rowY = (-Yid*layer.gridCellHeight) + layer.gridCellHeight
                                animtile.MoveTo(rowX, rowY)

                                allanimtiles[Yid][Xid] = animtile

                                -- CLUTCH: For the field tileset, offset the animation of tiles according to their X position.
                                -- That way you'll get the nifty *swaying-in-the-wind* effect!
                                if tilesetName == "field" then
                                    animtile.currentframe = ((Xid + Yid) % #animatedTiles.frames) + 1
                                    animtile.currenttime  = (animtile.currentframe - 1) * animtile.animationspeed
                                end
                            end

                            local adjacentTile = self.FindTileAdjacence(layer.data2D, Xid, Yid)
                            if not hasCenterTile and adjacentTile == "center" then
                                -- This happens, and it means the center tile is hollow!
                            else
                                local newtile = CreateSprite(tilesSpritePath .. adjacentTile, layer.name)
                                newtile.SetPivot(0,1)
                                local rowX = (Xid*layer.gridCellWidth) - layer.gridCellWidth
                                local rowY = (-Yid*layer.gridCellHeight) + layer.gridCellHeight
                                newtile.MoveTo(rowX, rowY)

                                alltiles[Yid][Xid] = newtile
                            end
                        end
                    end
                end
                room.layers[i].data2D = alltiles
                room.layers[i].animdata2D = allanimtiles
                
            -- This will check for available positions in which to place the player at during room creation. 
            elseif layer.name == "AvatarOrigin" then
                for id=1, #layer.entities do
                    if layer.entities[id].name == "Player"  then
                        if layer.entities[id].values.originID == self.originID then
                            -- OgmoEditor uses 0 to 3, so we add up 1 so to be consistent with Lua.
                            self.party[1].direction = layer.entities[id].values.direction + 1
                            
                            self.SetAnim(self.party[1], "Idle", true)
                            local originPosition = {layer.entities[id].x+19, -layer.entities[id].y}
                            self.party[1].MoveToAbs(originPosition[1], originPosition[2])

                            for i=1, #self.party do
                                if i > 1 then
                                    self.party[i].direction = self.party[1].direction
                                    self.party[i].beforeDirection   = self.party[1].direction
                                    self.SetAnim(self.party[i], "Idle", true)
                                    self.Movement.ResetFollowPosition(i, originPosition[1], originPosition[2], self.party[1].direction)
                                    
                                    self.party[i].MoveToAbs(originPosition[1], originPosition[2]+2)
                                    self.party[i].beforePos.x = originPosition[1]
                                    self.party[i].beforePos.y = originPosition[2] + 2
                                end
                            end

                        end
                    end
                end
            elseif layer.name == "Triggers" then
                local allActItems = {}
                for id=1, #layer.entities do
                    local object = {}
                    object.x      = layer.entities[id].x  -- Starting position of the object.
                    object.y      = -layer.entities[id].y
                    object.width  = layer.entities[id].width  or 40 -- Size of the collition.
                    object.height = layer.entities[id].height or 40
                    object.name   = layer.entities[id].name
                    object.id     = layer.entities[id].id  -- The object's ID you can find in Ogmo.

                    local hitbox = CreateSprite("px", "OWEntities") -- in another timeline, this would be in the "Top" layer...
                    hitbox.SetPivot(0, 1)
                    hitbox.Scale(object.width, object.height)
                    hitbox.alpha = (CYKDebugLevel > 0) and 0.7 or 0

                    if object.name == "Interactable" then
                        hitbox.color = {0.2, 0.15, 0.75}

                        local dialogueID  = layer.entities[id].values.dialogueID
                        if dialogueID == "" then
                            error("Room \"" .. roomID .. "\" in Triggers layer, Interactable ID " .. layer.entities[id].id .. ", dialogueID field is empty.")
                        end
                        object.text = dialogueID

                        object.checkedAmount = {1, layer.entities[id].values.dialoguesTotal}
                        object.isDetecting   = true

                    elseif object.name == "Battle" then
                        hitbox.color = {0.82, 0.86, 0.24}
                        object.isDetecting = true
                        object.encounterName = layer.entities[id].values.encounterName
                        
                    elseif object.name == "SavePoint" then
                        hitbox.color = {0.74, 0.88, 1.0}
                        
                        object.text = "save"
                        local hasText  = layer.entities[id].values.hasText
                        if not hasText then
                            object.text = "" end
                        
                        object.location = layer.entities[id].values.location

                        local obj = CreateSprite("Overworld/SavePoint/0", "OWEntities")
                        obj.SetAnimation( {0, 1, 2, 3, 4, 5}, 2/15, "Overworld/SavePoint/" )

                        obj.SetPivot(0, 1)

                        obj.MoveToAbs(layer.entities[id].x, -layer.entities[id].y)
                        obj.Move(0, 0)
                        table.insert(self.savepoints, obj)


                    elseif object.name == "Door" then
                        object.roomNext  = layer.entities[id].values.roomNext
                        object.originID  = layer.entities[id].values.originID
                        object.nextBGM   = layer.entities[id].values.nextBGM
                        hitbox.color   = {0.65, 0.75, 0.7}

                        if self.allRooms[object.roomNext] == nil then
                            NewAudio.Stop( "BGM")
                            error("Room '" .. roomID .. "' Door object id " .. layer.entities[id].id .. ", the room it references by '".. tostring(object.roomNext) .. "' doesn't exist.")
                        end
                        
                    end

                    object.hitbox = hitbox
                    object.hitbox.MoveToAbs(object.x, object.y)
                    table.insert(allActItems, object)
                end

                room.layers[layer.name] = layer
                room.layers[layer.name].entities = allActItems
                room.layers[i] = nil
            elseif layer.name == "Assets" then
                local allassets = {}
                for id=1, #layer.entities do
                    local spritePath = layer.entities[id].values.spritePath
                    spritePath = string.gsub(spritePath, "proj:../../Sprites/", "")

                    local sprite = CreateSprite(spritePath, "OWEntities")
                    sprite.SetPivot(0.5, 0)  -- *has* to pivot to the bottom of the sprite, for proper YSort-ing.

                    sprite["id"] = layer.entities[id].id

                    if layer.entities[id].values then
                        local rescale = layer.entities[id].values.rescale
                        if rescale then
                            sprite.Scale(2, 2)  end
                        
                        sprite["ysort"] = false
                        -- Whether to include this sprite into the Overworld's YSortQueue
                        local hasYSort = layer.entities[id].values.hasYSort
                        if hasYSort then
                            sprite["ysort"] = true   end
                    end

                    sprite.MoveToAbs(
                         layer.entities[id].x + (layer.entities[id].width / 2), 
                        -layer.entities[id].y - (layer.entities[id].height)
                    )
                    allassets[id] = sprite
                end
                room.layers[layer.name] = room.layers[i]
                room.layers[layer.name].entities = allassets

                self.overworldYSortQueue = table.copy(allassets)
                for key,v in pairs(self.allAvatars) do
                    table.insert(self.overworldYSortQueue, self.allAvatars[key].sprite)
                end
                
            end
        end
        self.room = room
        self.roomName = roomID

        self.OnRoomSetup(roomID)
    end
    
    function self.DestroyCurrentRoom()
        local room = self.room
        if self.BG ~= nil then
            self.BG.Remove()
        end
        
        room.layers["solid"] = {}
        -- Remove any sprites stored within their respective layers.
        -- Only those sprites, and sprites parented to those are removed here.
        for key, v in pairs(room.layers) do
            local layer = room.layers[key]
            if layer.name == "Ground" then
                local tiles = room.layers[key].data2D
                local animtiles = room.layers[key].animdata2D
                if animtiles ~= nil then
                    for ky, tiley in pairs(animtiles) do
                        for kx, tilex in pairs(animtiles[ky]) do
                            animtiles[ky][kx].Remove()
                        end
                    end
                end
                for ky, tiley in pairs(tiles) do
                    for kx, tilex in pairs(tiles[ky]) do
                        tiles[ky][kx].Remove()
                    end
                end
            elseif layer.name == "Triggers" then
                for id=1, #layer.entities do
                    room.layers[key].entities[id].hitbox.Remove()
                end

                if #self.savepoints ~= 0 then
                    self.savepoints[1].Remove()  end
                self.savepoints = {}
            elseif layer.name == "Assets" then
                for id=1, #layer.entities do
                    room.layers[key].entities[id].Remove()
                end
                self.overworldYSortQueue = {}
            end
        end

        -- Remove any sprites added to the trash queue
        for i=1, #self.spriteTrashQueue do
            self.spriteTrashQueue[i].Remove()
        end
        self.spriteTrashQueue = {}
        self.room = {}
    end

    function self.StartSwitchTo(room)
        self.StopPlayer()

        self.fader.MoveTo(Misc.cameraX, Misc.cameraY)
        self.roomNext = room
        
        self.fadingFrame = 0
        self.isFadeIn = true
    end

    function self.UpdateRoomFadeout()
        if self.isFadeIn then
            self.fadingFrame = self.fadingFrame + 1
            local f = self.fadingFrame
            if f < 22 then
                self.fader.alpha = self.fader.alpha+0.05
            end

            if f == 28 then
                self.DestroyCurrentRoom()
                self.CreateRoom(self.roomNext)

                self.fadingFrame = 0
                self.isFadeIn = false
                self.isFadeOut = true
            end
        elseif self.isFadeOut then
            self.fadingFrame = self.fadingFrame + 1
            local f = self.fadingFrame
            self.fader.MoveTo(Misc.cameraX, Misc.cameraY)
            if f < 22 then
                self.fader.alpha = self.fader.alpha-0.05
            end

            if f == 4 then
                Overworld.canControl = true end

            if f == 24 then
                self.fadingFrame = 0
                self.isFadeOut = false
            end

        end
    end

    
    function self.DetectRoomTriggers()
        if not self.room.layers == nil then return end
        -- Scan every trigger and check whether they should be turned on.
        local layer = self.room.layers["Triggers"]
        for i=1, #layer.entities do
            local trigger = layer.entities[i]
            local x = self.party[1].sprite.absx
            local y = self.party[1].sprite.absy


            if Input.Confirm == 1 then
                local direction = self.party[1].direction
                
                x = x + ( self.allDirectionsEnum[direction][1] * 26 )
                y = y + ( self.allDirectionsEnum[direction][2] * 26 )
                
                y = y + (self.party[1].hitbox.height / 2)

                if  not ((x >= trigger.hitbox.x and x <= trigger.hitbox.x+trigger.width) 
                and  (y <= trigger.hitbox.y and y >= trigger.hitbox.y-trigger.height)) then goto continue end
            
                if trigger.name == "Interactable" and trigger.isDetecting then
                    
                    local nextDialogue = (trigger.checkedAmount[1] == 1) and 
                        trigger.text or trigger.text .. "-" .. tostring(trigger.checkedAmount[1])
                    
                    -- Allow a trigger to have more dialogues the more times they are checked.
                    if trigger.checkedAmount[1] < trigger.checkedAmount[2] then
                        trigger.checkedAmount[1] = trigger.checkedAmount[1] + 1
                    end

                    self.HandleInteractable(nextDialogue)

                    return
                elseif trigger.name == "SavePoint" then
                    Overworld.SaveObj.locationName = trigger.location

                    if trigger.text == "" then
                        Overworld.SaveObj.Show()
                        Overworld.SaveObj.active = true
                    else
                        Overworld.TextBox.CreateTextbox( self.Dialogues.getDialogue(self.roomName, trigger.text) )
                        Overworld.TextBox.closingMode = Overworld.TextBox.closingModeEnum.toSavepoint
                    end
                    
                    Audio.PlaySound("menu/snd_power")
                    self.StopPlayer()

                    return
                end
            end
            
            -- The following triggers are always accounted for, whether the player presses Confirm or not.
            if  not ((x >= trigger.hitbox.x and x <= trigger.hitbox.x+trigger.width) 
                and  (y <= trigger.hitbox.y and y >= trigger.hitbox.y-trigger.height)) then goto continue end

            if trigger.name == "Battle" then
                if trigger.isDetecting then
                    self.lastBattleTrigger = trigger

                    trigger.isDetecting = false
                    Overworld.StartBattleIntro(trigger.encounterName)
                end
                return
            elseif trigger.name == "Door" then
                self.originID = trigger.originID
                self.StartSwitchTo(trigger.roomNext)

                if trigger.nextBGM ~= "" then
                    self.switchBGM(trigger.nextBGM)
                end

                self.RoomExiting(self.roomName, trigger.roomNext)
            end
            
            ::continue::
        end
    end

    -- Return an object in a particular layer of the current room, by using its id. You can find which id belongs where in Ogmo.
    function self.FindObjectInRoom(layer, id)
        if self.room.layers[layer] == nil then
            error("Layer \"" ..layer.."\" doesn't exist in room " ..self.roomName.. "! Check your project's layer in Ogmo.")
        end
        
        local objectPool = self.room.layers[layer].entities
        for i=1, #objectPool do
            local obj = objectPool[i]
            
            if layer=="Assets" then
                if obj["id"] == id then
                    return obj end
            elseif obj.id == id then
                return obj
            end
        end
        error("Object " ..type.." id " ..tostring(id).. " doesn't exist in room" .. self.roomName)
    end

    -- Call this function within text so that a sprite in the Overworld will play a little animation while the Textbox is typing.
    function TalkingSprite(id, talking)
        -- This function only looks for an object within the Triggers layer that's got a sprite property. You can add one manually.
        local object = Overworld.FindObjectInRoom("Triggers", id)

        if object["sprite"] ~= nil then
            if talking then
                object["sprite"].SetAnimation( object["talking"], object["animspeed"], object["animPrefix"] )
                self.talkingSprites[id] = id
            else
                object["sprite"].SetAnimation( object["quiet"],   object["animspeed"], object["animPrefix"] )
                self.talkingSprites[id] = nil
            end
        else
            error("Object within Triggers layer with an ID of " .. id .. ": \"sprite\" property doesn't exist. You may add one yourself at the function OnRoomSetup")
        end
    end
    self.talkingSprites = { }  -- Fixes a bug. You'll see.


end