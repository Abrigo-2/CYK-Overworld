return function()
    -- Values
    local self = { }

    --#region Variables

    self.music = "ch4_battle" -- Song that plays during the encounter. Set to "none" to not do that.

    self.encountertext = "Is this Undertale? I think not..." -- Modify as necessary. It will only be read out in the action select screen.

    -- If you're looking for the arena variables, check out self.SetArena()
    self.arenacolor =  { 0, 1, 0 } -- Color of the sides of the arena? at the start of the next wave.
    self.arenarotation = 0         -- Rotation of the arena at the start of the wave.

    self.players = {  "Kris", "Ralsei", "Susie" }
    self.playerpositions = {
        { 78, 372 },
        { 78, 278 },
        { 16, 200 }
    }
    
    
    self.enemies = { "GigaPoseur" }
    self.enemypositions = {
        { 492, 250 },
    }
    
    self.background = true     -- Set this variable to false to disable CYK's background
    self.backgroundfade = true -- Set this variable to false to disable the fade effect on the background when entering a wave
    
    -- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
    self.possible_attacks = { "bullettest_bouncy", "bullettest_chaserorb", "bullettest_tunnel" }
    self.nextwaves = { "bullettest_bouncy" }

    --#endregion

    function self.EncounterStarting()
    end

    function self.EnemyDialogueStarting()
    end
    
    function self.EnemyDialogueEnding()
        nextwaves = { possible_attacks[math.random(1, #possible_attacks)] }
        self.SetArena(nextwaves[1])
    end

    function self.SetArena(nextwave)
        -- Consider these the defaults.
        wavetimer = 4
        arenasize = { 155, 130 }
        arenapos = { 320, 200 }
        
        if nextwave == "bullettest_bouncy" then
            -- Nothing.
        elseif nextwave == "bullettest_touhou" then
            wavetimer = 3
            arenasize = { 180, 146 }
            arenapos = { 320, 200 }
        
        elseif nextwave == "bullettest_chaserorb" then
            wavetimer = 3
            arenasize = { 160, 128 }
            arenapos = { 320, 200 }
        
        elseif nextwave == "bullettest_tunnel" then
            wavetimer = 6
            arenasize = { 196, 158 }
            arenapos = { 320, 218 }

        elseif nextwave == "empty" then
            wavetimer = 0
        end
    end
    
    -- Called after the defense round ends
    function self.DefenseEnding()
        -- To be frank, I don't remember why this's ought to be here.
        if enemies[1].targetType == "all" then
            enemies[1].targetType = "single"
        end
    
        encountertext = RandomEncounterText()
    end
    
    function self.HandleSpare(player, enemy) end
    
    
    function self.EnteringState(newstate, oldstate) end
    
    
    function self.HandleItem(user, targets, itemID, itemData)

    end

    function self.OnGameOver()
    end


    return self
end