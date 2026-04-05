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
    self.party = {}  -- The list of all *current* party members. Set manually.

    self.partyNames = {} -- The names of the currenty party members.


    -- [[Uncomment when optimizing. 
    require ("Libraries/OverworldOptimized/Util")(self)



    self.TextBox = (require "Libraries/OverworldOptimized/TextboxManager")(self)
    self.Dialogues = (require "Libraries/OverworldOptimized/DialogueLoader")() -- Contains the dialogue JSON data in a single file.

    self.CutsceneObj = (require "Overworld/Cutscenes")(self)

    self.roomName = ""
    self.talkingSprites = {}


    require ("Overworld/RoomHandler")(self)

    
    self.story = 1           -- Keeps track of sequential events.
    self.storyFlags = { 0 }  -- Hard to explain. Think of it like this: It keeps track of non sequential events.

    self.cameraFollowPlayer = true -- Camera will follow the first party member.
    self.canControl = true   -- Whether the player can move and interact


    function self.Update()

        self.CutsceneObj.UpdateCutscene()
        
        self.TextBox.UpdateTextbox()
    end

    -- Starts a battle, without the intro.
    function self.StartBattleIntro(encounter, playhorn)
        -- Stop control at the Overworld.
        self.cameraFollowPlayer = false
        self.canControl = false

        if optimizedForOneEncounter then
            local file = "Battles/" .. encounter
            
            if battleLastLoaded ~= encounter then
                battleFile = require (file)()
            end
            battleLastLoaded = encounter
            LoadBattleValues()

            State("SETUP")
            return
        end
    end
    function self.StartBattleOutro()
        self.battleTransF = 0
        self.isBattleOutro = true

        self.OnEncounterEnding(battleLastLoaded)
    end

    -- Ignore all the functions below: They've been left for retrocompatibility.

















    -- Stop the party's Walk animation and take away control.
    function self.StopPlayer()
        self.canControl = false
    end

    -- Swap the party member at a given place. You can even swap with nil!
    -- ... a shame it isn't called "null", otherwise I could make a really funny nod here.
    function self.SwapPartyMember(placeInParty, memberName)
        
        -- Remove party member.
        if     memberName == ""   then
            if self.party[placeInParty] == nil then return end

            table.remove( self.party, placeInParty )
        
        -- Add new party member.
        elseif self.party[placeInParty] == nil then
            self.party[placeInParty] = self.allAvatars[memberName]
        
        -- Swap with existing party member
        else     
            if placeInParty == 1 then
                self.party[placeInParty] = self.allAvatars[memberName]  -- Replace party member value.
            else
                -- Replace party member value.
                self.party[placeInParty] = self.allAvatars[memberName]
            end
        end

        self.party[placeInParty].beforePos.x = self.party[placeInParty].posX
        self.party[placeInParty].beforePos.y = self.party[placeInParty].posY

        self.GeneratePartyBattleNames()
    end

    function self.GeneratePartyBattleNames()
        self.partyNames = {}
        for i=1, math.min(3, #self.party) do
            if self.party[i] ~= "" then
                table.insert(self.partyNames, self.party[i].battleName )
            end
        end
    end


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
            
                blur.alpha = blur.alpha - 1/48*Time.mult
                if blur.alpha <= 0.21 then
                    blur.Remove()
                end
            end
        end
    end

    function self.UpdateBattleTransition()
        self.UpdateBlur()
    end

    --#endregion
    


    return self
end