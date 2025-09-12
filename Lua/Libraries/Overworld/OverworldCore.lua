return function()

    -- The audio channel for the background music
    NewAudio.CreateChannel( "BGM")
    NewAudio.Stop( "BGM")

    -- Sprite layers... I'm considering renaming them.
    CreateLayer("OWBackground", "Background", true)
    CreateLayer("animatedGround", "OWBackground")
    CreateLayer("BelowBackground", "OWBackground", true)
    CreateLayer("Ground", "animatedGround")
    
    CreateLayer("BackEntity", "Ground")
    CreateLayer("OWEntities", "BackEntity")

    CreateLayer("Fader", "Top", true)

    -- load the JSON library. This will help parse Dialogues and Ogmo's rooms files.
    json = require("Libraries/jsonLua/json")

    local self = { }

    self._ENV_BASE = _ENV_BASE

    self.allAvatars = {}  -- The list of every potential party member.
    self.party = {}  -- The list of every *current* party members. Set manually.

    require ("Libraries/Overworld/AvatarAnims")(self) 
    require ("Libraries/Overworld/AvatarManager")(self)

    self.Movement = (require "Libraries/Overworld/Movement")() 
    self.TextBox = (require "Libraries/Overworld/TextboxManager")(self)

    self.SaveObj = (require "Libraries/Overworld/SaveScreen")(self)

    self.overworldYSortQueue = {}   -- All entities that YSort will be aplied to
    require ("Libraries/Overworld/OgmoEditor")(self)
    require ("Overworld/RoomHandler")(self)

    self.Dialogues = (require "Libraries/Overworld/DialogueLoader")(self)

    self.CutsceneObj = (require "Overworld/Cutscenes")(self)
    
    self.story = 1           -- Keeps track of sequential events.
    self.storyFlags = { 0 }  -- Hard to explain. Think of it like this: It keeps track of non sequential events.

    self.cameraFollowPlayer = true -- Camera will follow the first party member.
    self.canControl = true   -- Whether the player can move and interact

    --#region Battle Transition related
    self.battleTransF = 0

    self.isBattleIntro = false
    self.isBattleOutro = false

    blurs = {}
    function self.CreateBlurs(spawnX, spawnY, sprite)
        local blur = CreateSprite( sprite, "Background")
        blur.SetPivot(0.5, 0)
        --blur.Scale(2, 2)
        blur.MoveToAbs(spawnX, spawnY)

        blur.alpha = 0.5
        table.insert(blurs,blur)
    end

    function self.UpdateBlur()
        for i = 1, #blurs do
            local blur = blurs[i]
            if blur.isactive then
            
                blur.alpha = blur.alpha - 1/40*Time.mult
                if blur.alpha <= 0.2 then
                    blur.Remove()
                end
            end
        end
    end

    --#endregion

    -- Stop the party's Walk animation and take away control.
    function self.StopPlayer()
        for i=1, #self.party do
            self.SetAnim(self.party[i], "Idle")
            self.party[i].directionKeyQueue = {}
            self.party[i].isNotWalking = true
        end
        self.canControl = false
    end

    -- Swap the party member at a given place. You can even swap with nil!
    function self.SwapPartyMember(placeInParty, memberName)
        
        -- Remove party member.
        if     memberName == ""   then
            if self.party[placeInParty] == nil then return end

            self.party[placeInParty].sprite.alpha = 0

            table.remove( self.party, placeInParty )

            for i=1, #self.party do
                if i > 1 then
                    local last = self.Movement.followDistance*(i-1)
                    self.party[i].MoveToAbs(
                        self.Movement.followPosition[i][last].x,
                        self.Movement.followPosition[i][last].y
                    )
                    self.PlayerLookAt(self.party[i], self.Movement.followPosition[i][last].direction)
                end
            end
        
        -- Add new party member.
        elseif self.party[placeInParty] == nil then
            self.party[placeInParty] = self.allAvatars[memberName]

            if placeInParty > 1 then
                -- Moves the next party member right infront of the player. You can move them from there later.
                self.party[placeInParty].MoveToAbs(self.party[1].posX, self.party[1].posY - 10)
                
                self.Movement.followPosition[placeInParty] = { }
                self.Movement.ResetFollowPosition(placeInParty,
                    self.party[1].posX, self.party[1].posY - 4, 3)
            end

            self.PlayerLookAt(self.party[placeInParty], 3)

            self.party[placeInParty].sprite.alpha = 1
        
        -- Swap with existing party member
        else
            -- Hide past party member.
            self.party[placeInParty].sprite.alpha = 0
            
            if placeInParty == 1 then
                self.allAvatars[memberName].MoveToAbs(self.party[1].posX, self.party[1].posY)

                self.party[placeInParty] = self.allAvatars[memberName]  -- Replace party member value.
            else
                -- Replace party member value.
                self.party[placeInParty] = self.allAvatars[memberName]

                -- Move the next party member to where the past one was.
                local last = self.Movement.followDistance*(placeInParty-1)
                self.party[placeInParty].MoveToAbs(
                    self.Movement.followPosition[placeInParty][last].x,
                    self.Movement.followPosition[placeInParty][last].y
                )
                self.PlayerLookAt(self.party[placeInParty], self.Movement.followPosition[placeInParty][last].direction)
            end

            self.party[placeInParty].sprite.alpha = 1
        end

        self.party[placeInParty].beforePos.x = self.party[placeInParty].posX
        self.party[placeInParty].beforePos.y = self.party[placeInParty].posY

        self.ApplyYSortToOverworldQueue(self.overworldYSortQueue)
    end

    -- Starts a battle, with the intro OR without it
    function self.StartBattleIntro(encounter, playhorn)
        local playhorn = playhorn or true
        
        -- Stop control at the Overworld.
        self.cameraFollowPlayer = false
        self.canControl = false

        -- Load the Encounter from the Battle's folder.
        local file = "Battles/" .. encounter
        encounterLastLoaded = encounter
        encounterFile = require (file)()
        LoadBattleValues()
        
        if skipintro then
            for i=1, #self.party do
                self.party[i].sprite.alpha = 0
                self.party[i].posBeforeBattle.x = self.party[i].posX
                self.party[i].posBeforeBattle.y = self.party[i].posY
                self.party[i].MoveTo(
                    playerpositions[i][1]+40,
                    playerpositions[i][2]-2
                )
            end
            State("SETUP")
            NewAudio.Pause("BGM")
        else
            self.battleTransF = playhorn and 0 or 29
            self.isBattleIntro = true
        end

    end
    function self.StartBattleOutro()
        self.battleTransF = 0
        self.isBattleOutro = true

        -- If the fight was triggered by a Battle trigger, and this one has a Sprite, it wil automatically hide it!
        if self.lastBattleTrigger ~= nil then
            if self.lastBattleTrigger["sprite"] ~= nil then
                self.lastBattleTrigger["sprite"].alpha = 0
            end
        end
        self.lastBattleTrigger = nil

        self.OnEncounterEnding(encounterLastLoaded)
    end

    function self.UpdateBattleTransition()
        if self.isBattleIntro then
            self.battleTransF = self.battleTransF + 1
            local f = self.battleTransF
            if f == 1 then
                for i=1, #self.party do
                    if self.party[i].animations.HitEnemy ~= nil then
                        self.SetAnim(self.party[i], "HitEnemy")
                    else
                        self.SetAnim(self.party[i], "Idle") end

                    self.party[i].sprite.alpha = 1
                    self.party[i].directionKeyQueue = {}
                    self.party[i].isNotWalking = true
                end
                Audio.PlaySound("tensionhorn", 8)
            end
            if f == 30 then
                State("SETUP")
                NewAudio.Pause("BGM")
                
                -- We use #playerpositions rather than #self.party, so that only the players involved in the fight will move into place.
                for i=1, #playerpositions do
                    if i <= #self.party then
                    self.SetAnim(self.party[i], "BattleIntro")
                    self.party[i].sprite.layer = "Entity"
                    
                    self.party[i].posBeforeBattle.x = self.party[i].posX
                    self.party[i].posBeforeBattle.y = self.party[i].posY
                    end
                end
                
            end
            
            local placingTime = 26  -- The amount of frames it'll take to move the players into position.
            -- + 30 accounts for the 30 frames it takes the horn to blare twice.
            if f > 30 and f <= 30+placingTime then
                for i=1, #playerpositions do
                    if i <= #self.party then
                    local player = self.party[i]

                    local xspeed = (Misc.cameraX + playerpositions[i][1] + 40) - self.party[i].posBeforeBattle.x
                    local yspeed = (Misc.cameraY + playerpositions[i][2]) - self.party[i].posBeforeBattle.y
                    player.Move( xspeed/placingTime, yspeed/placingTime )
                    
                    --player.Move(
                    --    lerp(player.posX, Misc.cameraX + playerpositions[i][1]+35, 0.08),
                    --    lerp(player.posY, Misc.cameraY + playerpositions[i][2], 0.08)
                    --)
                    self.CreateBlurs(player.posX, player.posY, player.sprite.spritename)
                    end
                end

            end

            if f == 30+placingTime+2 then
                --Hide player avatars
                for i=1, #playerpositions do
                    if i <= #self.party then
                        self.party[i].MoveTo(
                            playerpositions[i][1]+40,
                            playerpositions[i][2]-2
                        )
                        self.party[i].sprite.alpha = 0
                    end
                end

                self.isBattleIntro = false
                self.battleTransF = 0
                State("INTRO")
            end
        end
        if self.isBattleOutro then
            self.battleTransF = self.battleTransF + 1
            local f = self.battleTransF
            if f == 1 then
                for i=1, #playerpositions do
                    if i <= #self.party then
                        self.SetAnim(self.party[i], "Idle")
                        self.party[i].sprite.layer = "Entity"
                        self.party[i].sprite.alpha = 1
                    end
                end
            end
            
            if NewAudio.GetVolume("BGM") < self.BGM.volumeMax then
                local volumeStep = self.BGM.volumeMax / 16
                NewAudio.SetVolume("BGM", NewAudio.GetVolume("BGM") + volumeStep)
            else
                NewAudio.SetVolume("BGM", self.BGM.volumeMax) end
            
            local placingTime = 26  -- The amount of frames it'll take to move the players into position.
            -- + 1 accounts for...... (?????????)
            if f > 1 and f < placingTime then
                for i=1, #playerpositions do
                    if i <= #self.party then
                    local player = self.party[i]
                    
                    local xspeed = self.party[i].posBeforeBattle.x - ( Misc.cameraX + playerpositions[i][1] + 40 )
                    local yspeed = self.party[i].posBeforeBattle.y - ( Misc.cameraY + playerpositions[i][2] )
                    player.Move( xspeed/placingTime, yspeed/placingTime )
                    
                    --local xspeed = lerp(player.posX, self.party[i].posBeforeBattle.x, 0.12)
                    --local yspeed = lerp(player.posY, self.party[i].posBeforeBattle.y, 0.12)
                    --player.Move(xspeed, yspeed)
                    end
                end
            end

            if f == placingTime+4 then
                for i=1, #playerpositions do
                    if i <= #self.party then
                        self.party[i].sprite.layer = "OWEntities"
                        self.party[i].MoveToAbs(
                            self.party[i].posBeforeBattle.x,
                            self.party[i].posBeforeBattle.y
                        )
                    end
                end
                self.cameraFollowPlayer = true
                self.canControl = true

                self.isBattleOutro = false
                self.battleTransF = 0
            end
        end
        self.UpdateBlur()
    end

    -- "Sortable entities are ordered in proximity to the camera." Duh, past me???
    function self.ApplyYSortToOverworldQueue(sortQueue)
        local spritesToSort = {}
        
        if #sortQueue == 0 then return end
        for i=1, #sortQueue do
            -- Moves all sprites on queue to a lower layer
            sortQueue[i].layer = "BackEntity"

            -- If the sprites have a "ysort" property set to true, add them to the *actual* sorting table
            local applicable = (sortQueue[i]["ysort"] ~= nil) and sortQueue[i]["ysort"] or false
            if applicable then
                table.insert(spritesToSort, sortQueue[i])  end
            
        end

        -- Then, order the sprites within said table by their Y value, then add them back into the layer from that order.
        -- Changing their layers like this achieves the sorting effect.
        table.sort(spritesToSort, function(a, b) return a.y > b.y end)
        for i=1, #spritesToSort do
            spritesToSort[i].layer = "OWEntities"
        end
    end

    -- Update
    function self.Update()
        self.UpdateFollowUps()

        self.CutsceneObj.UpdateCutscene()

        --Movement related
        if #self.party > 0 and self.canControl then
            -- everything february 2022 me held dear.
            self.Movement.UpdatePlayerMovement(self.party)
            self.UpdatePlayerIdleAnim()

            self.ApplyYSortToOverworldQueue(self.overworldYSortQueue)
            self.DetectRoomTriggers()
        end
        self.RoomUpdate(self.roomName)

        if self.SaveObj.state > 0 then
            self.SaveObj.Update() end
        -- This needs to go afterwards, lest something bad happens.
        self.TextBox.UpdateTextbox()

        -- The camera will follow the player. No easing or smoothing.
        if #self.party > 0 and self.cameraFollowPlayer and GetCurrentState() == "NONE" then
            local cameraPos = {self.party[1].sprite.absx, self.party[1].sprite.absy}

            local width  = self.room.width  or 0
            local height = self.room.height or 0
            height = -height
            
            local borderX = math.clamp(cameraPos[1], 0+320,    width-320)
            local borderY = math.clamp(cameraPos[2], height+240,   0-260)
            
            Misc.MoveCameraTo(borderX-320, borderY-220)
        end

        self.UpdateRoomFadeout()
        self.UpdateBGMFade()

        self.UpdateBattleTransition()
    end

    return self
end