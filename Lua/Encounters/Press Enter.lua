require "Libraries/CYK/Util" -- NEEDED FOR CYK TO RUN

encountertext = "Is this Undertale? I think not..." -- Modify as necessary. It will only be read out in the action select screen.

wavetimer = 1
arenasize = { 155, 130 }
arenapos = { 320, 200 }  -- Position of the middle of the bottom of the arena at the start of the next wave.
arenacolor = { 0, 1, 0 } -- Color of the sides of the at the start of the next wave.
arenarotation = 0        -- Rotation of the arena at the start of the wave.
autolinebreak = true     -- Returns the text to the next line if it goes past a text object's boundary.

-- List of Players. Each Player added here must have a script with the same name in the mod's Lua/Players folder.
players = { "Kris", "Ralsei" }
-- Position of each Player on the screen. It is made of tables with two values.
-- Each table contains an x value and a y value. These values move the bottom left corner of each Player's sprite.
playerpositions = {
    { 80, 320 },
    { 80, 220 }
}


-- List of enemies. Each enemy added here must have a script with the same name in the mod's Lua/Monsters folder.
enemies = { "Poseur",}
-- Position of each enemy on the screen. It is made of tables with two values.
-- Each table contains an x value and a y value. These values move the bottom left corner of each enemy's sprite.
enemypositions = {
    { 492, 250 },
}

chapter2 = true  -- Toggles Chapter 2 functionality.

--unescape = false -- Uncomment me to remove the pesky QUITTING text when trying to exit the encounter!

-- Preloads all of CYK's animations to reduce loading times in-game, at the price of an increasing loading time at the start of the encounter
preloadAnimations = true

-- CYK's debug level:
-- 0- = No warning
-- 1  = Important warnings. (Collision shapes will be shown, too!)
-- 2  = All warnings
-- 3+ = All debug messages
CYKDebugLevel = 0

-- Characters used to display thie players' UI sprite in the font uidialog
-- Here, I used cyrillic characters as they are not used in English
fontCharUsedForPlayer = { Kris = "Ђ", Susie = "Ѓ", Ralsei = "Є", Ieslar = "Љ", KRISP = "Њ", ZOOZIE = "Ћ" }
fontCharUsedForPlayer["2FPEST"] = "Ќ"

skipintro = false      -- Skips the battle intro animation.
pauseowmusic = true    -- Pause the overworld's background track when a fight starts.
background = false     -- Set this variable to false to disable the square-grid background. (or whatever is the default background)
backgroundfade = true  -- Set this variable to false to disable the fade effect on the background when entering a wave. Advised to keep as true.


-- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
possible_attacks = { }
nextwaves = { "empty" }

encounterLastLoaded = ""

function indexOf(array, value)
    for i, v in ipairs(array.name) do
        if v == value then
            return i
        end
    end
    return nil
end

function EncounterStarting()
    State("NONE")

    -- Add the Overworld here....
    Overworld = (require "Overworld/OverworldCore")()

    -- Volume. So the sound effects stand out.
    Overworld.BGM.volumeMax = .45
    NewAudio.SetVolume( "BGM", Overworld.BGM.volumeMax)

    -- Load the game's data saved at a previous Savepoint, if there's any.
    if GetAlMightyGlobal("saveLocationName") ~= nil then

        Overworld.story = GetAlMightyGlobal("saveStoryProgress")
        for i=1, #Overworld.storyFlags do
            Overworld.storyFlags[i] = GetAlMightyGlobal("saveStoryFlag" .. tostring(i))
        end

        for i=1, 4 do  -- Max ammount of party members saved at the time. Change if you will.
            local partyName = GetAlMightyGlobal( "saveParty" .. tostring(i) )
            if partyName ~= "" then
                Overworld.party[i] = Overworld.allAvatars[partyName]
            end
        end

        Overworld.originID = 0  -- ID 0 is used specifically for the Savepoints!
        Overworld.CreateRoom(GetAlMightyGlobal("saveRoom"))

        Overworld.SaveObj.locationName = GetAlMightyGlobal("saveLocationName")
        local str = Overworld.SaveObj.font .. Overworld.SaveObj.locationName
        Overworld.SaveObj.location.SetText(str)

        if GetAlMightyGlobal("saveBGM") ~= "nil" then
            NewAudio.PlayMusic("BGM", GetAlMightyGlobal("saveBGM"), true, Overworld.BGM.volumeMax)  end
    else
        -- This should run if the player doesn't have a Save file, a.k.a, this is the first time they run this mod.
        -- Consider this the spot to set your "New Game" variables.

        Overworld.party[1] = Overworld.allAvatars["OWKris"] -- This will set your current party members. Can exceed 3! They just won't show up in battle.
        Overworld.party[2] = Overworld.allAvatars["OWRalsei"]
        --Overworld.party[3] = Overworld.allAvatars["OWGentle"]
        
        self.canControl = true  -- Set true so the player can move around from the get-go, as soon as the mod is loaded.

        Overworld.originID = 1
        Overworld.CreateRoom("Room1")

        NewAudio.PlayMusic("BGM", "fields_requiem", true, Overworld.BGM.volumeMax) -- The starting Overworld's BGM track.
        Overworld.BGM.name = "fields_requiem"
    end

    -- Add the items, one by one. They don't need to be in the inventory.
    Inventory.AddCustomItem("Dark Candy", "Heals 40HP", 0, "Player")
    Inventory.AddCustomItem("Dark Burger", "Burnt as hell 70HP", 0, "Player")
    Inventory.AddCustomItem("Bandage", "Apt healing", 0, "Player")

    -- Rather than using Inventory.SetInventory, you'll have to use:
    OWinventory = {"Dark Candy", "Dark Candy", "Dark Burger", "Bandage"} -- This carries over your inventory after a fight.

    -- For playtesting purposes...
    -- Uncoment these functions to mute the game's background music.
    --[[
    Overworld.BGM.volumeMax = 0
    NewAudio.SetVolume("BGM", Overworld.BGM.volumeMax)
    NewAudio.Stop( "BGM")
    Audio.Volume(0)
    --]]
    

end


function Update()
    if GetCurrentState() == "NONE" then Overworld.Update() end
    Overworld.UpdateBlur()
end 


--#region Related to battles
encounterFile = (require "Battles/Example")()

-- In order to reduce lag, the enounter's file is *actually* loaded at Overworld.StartBattleIntro()
function LoadBattleValues()
    pauseowmusic = false
    if encounterFile.music ~= "none" then
        pauseowmusic = true
        Audio.LoadFile(encounterFile.music)
        Audio.Pause()
    end

    -- Overwrite CYK variables with the ones of the encounter.
    encountertext       = encounterFile.encountertext
    arenacolor          = encounterFile.arenacolor
    arenarotation       = encounterFile.arenarotation
    
    players             = encounterFile.players
    playerpositions     = encounterFile.playerpositions
    _enemies            = encounterFile.enemies
    enemypositions      = encounterFile.enemypositions

    if #players == 0 then
        error(tostring(encounterFile.players[1]))
    end

    background          = encounterFile.background
    backgroundfade      = encounterFile.backgroundfade
    skipintro           = encounterFile.skipintro or false

    possible_attacks    = encounterFile.possible_attacks
end

function EnemyDialogueStarting() encounterFile.EnemyDialogueStarting()
end

function EnemyDialogueEnding()  encounterFile.EnemyDialogueEnding()
end

-- Called after the defense round ends
function DefenseEnding()        encounterFile.DefenseEnding()
end

function HandleSpare(player, enemy) 
    encounterFile.HandleSpare(player, enemy)
end

function EnteringState(newstate, oldstate) 
    encounterFile.EnteringState(newstate, oldstate)
end

-- The code for this is run in two bits: *This* happens as soon as the player's turn begins.
function HandleItemDialogue(user, targets, itemID)
    if itemID == "Manual" then
        BattleDialog({ user.name .. " reads the Manual." })
    elseif itemID == "Rock" then
        BattleDialog({ user.name .. " throws the Rock at " .. targets[1].name .. ".[w:10]\nIt collides![w:10] " .. targets[1].name .. " loses 5 HP!"})
    else  -- Consider this the default text.
        BattleDialog({ user.name .. " used the " .. itemID .. "!" })
    end
end

-- ...and *this* is called once the Item animation stops running.
function HandleItem(user, targets, itemID, itemData)
    if itemID == "Dark Candy" then    targets[1].Heal(40)
    elseif itemID == "Dark Burger" then   targets[1].Heal(70)
    elseif itemID == "Bandage" then    targets[1].Heal(100)
    
    elseif itemID == "Nut" then
        for i = 1, #targets do
            targets[i].Heal(20)
        end
    elseif itemID == "Rock" then
        targets[1].Hurt(5, user)
    
    elseif itemID == "Manual" then
        local text = { user.name .. " reads the Manual." }
        for i = 1, #targets do
            -- You can call enemy / Player entity files functions like so:
            --targets[i].UseItem(itemID)
        end
    end
end


require "Libraries/CYK/CYKPreProcessing"  -- NEEDED FOR CYK TO RUN