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


function indexOf(array, value)
    for i, v in ipairs(array.name) do
        if v == value then
            return i
        end
    end
    return nil
end


optimizedForOneEncounter = true  -- Loads and builds certain things as soon as the mod starts, rather than doing so at certain points.

battleLastLoaded = "Encounter-Only" -- Name of the last loaded Battle file. We make sure it matches the currently loaded battleFile to avoide the "require" call in OverworldCore.
battleFile = (require "Battles/Encounter-Only")()

poseurStatsBoost = 1.0  -- For funsies. Make sure to remove it within Overworld.HandleChoice()

function EncounterStarting()
    State("NONE")

    -- Add the Overworld here....
    Overworld = (require "OverworldOptimized/OverworldCore")()

    -- Since we're optimizing, you'll have to manually set the avatar data.
    Overworld.CreateAllAvatars_Optimized({"OWKris","OWRalsei","OWSusie","OWGentle",})

    Overworld.SetAvatarProperties_Optimized("OWKris",   90, "Kris")
    Overworld.SetAvatarProperties_Optimized("OWRalsei", 70, "Ralsei")
    Overworld.allAvatars["OWRalsei"].hp = 45
    Overworld.SetAvatarProperties_Optimized("OWSusie",  110, "Susie")
    Overworld.SetAvatarProperties_Optimized("OWGentle", 123, "Gentle")

    
    -- Load the game's data saved at a previous Savepoint, if there's any.
    for realI, v in pairs(Overworld.allAvatars) do
        local newhp = GetAlMightyGlobal( "saveAvatarHP_" .. realI)
        
        if newhp ~= nil then
            Overworld.allAvatars[realI].maxhp = newhp
            Overworld.allAvatars[realI].hp = newhp
        end
    end

    
    local defaultParty = {"OWKris", "OWRalsei", "OWSusie"}

    for i=1, 3 do  -- Only 3, deltarune isn't designed for more.
        local partyName = GetAlMightyGlobal( "saveParty" .. tostring(i) )
        if partyName ~= nil and partyName ~= "" then
            Overworld.party[i] = Overworld.allAvatars[partyName]
        else
            Overworld.party[i] = Overworld.allAvatars[defaultParty[i]]
        end
    end
    Overworld.GeneratePartyBattleNames()

    -- Add the items, one by one. They don't need to be in the inventory.
    Inventory.AddCustomItem("Dark Candy", "Heals 40HP", 0, "Player")
    Inventory.AddCustomItem("Dark Burger", "Burnt as hell 70HP", 0, "Player")
    Inventory.AddCustomItem("Bandage", "Apt healing", 0, "Player")

    -- Rather than using Inventory.SetInventory, you'll have to use:
    OWinventory = {"Dark Candy", "Dark Candy", "Dark Burger", "Bandage"}
    -- This would, theoretically, carry over your inventory after a fight.
    -- However, the code for storing/loading items isn't implemented in this example.
    -- You'll have to borrow the code from the other example.


    Misc.MoveCameraTo(0, 0) -- Place the camera somewhere.
    -- On your cutscene, before you switch to the "INTRO" state,
    -- ensure the camera is in the same position as when you started the encounter.

    -- This here loads the battle. To reduce lag, ensure "battleFile" and
    -- the argument over here point towards the same file. 
    Overworld.StartBattleIntro("Encounter-Only", false)
    --State("INTRO")

    -- Added this to test how you may do a cutscene. Comment this and uncomment the previous
    -- line to have only the encounter.
    Overworld.CutsceneObj.startSpecialCustscene[1] = true



    -- For playtesting purposes...
    -- Uncoment these functions to mute the game's background music.
    --Audio.Volume(0)
end


function Update()
    ------------- Required by +OW
    if GetCurrentState() == "NONE" then Overworld.Update() end
    Overworld.UpdateBlur()
    -------------
end 



-- In order to reduce lag, the enounter's file is *actually* loaded at Overworld.StartBattleIntro()
function LoadBattleValues()
    pauseowmusic = false
    if battleFile.music ~= "none" then
        pauseowmusic = true
        Audio.LoadFile(battleFile.music)
        Audio.Pause()
    end

    -- Overwrite CYK variables with the ones of the encounter.
    encountertext       = battleFile.encountertext
    arenacolor          = battleFile.arenacolor
    arenarotation       = battleFile.arenarotation
    
    players             = table.copy(Overworld.partyNames)  -- Notice the different argument here!!
    playerpositions     = battleFile.playerpositions
    _enemies            = table.copy(battleFile.enemies)
    enemypositions      = battleFile.enemypositions

    if #players == 0 then
        error("Empty Players table on Battle file Battle/" .. battleLastLoaded )
    end

    background          = battleFile.background
    backgroundfade      = battleFile.backgroundfade
    skipintro           = battleFile.skipintro or false

    possible_attacks    = table.copy(battleFile.possible_attacks)
end

function EnemyDialogueStarting()    battleFile.EnemyDialogueStarting()
end

function EnemyDialogueEnding()      battleFile.EnemyDialogueEnding()
end

-- Called after the defense round ends
function DefenseEnding()            battleFile.DefenseEnding()
end

function HandleSpare(player, enemy)     battleFile.HandleSpare(player, enemy)
end

function EnteringState(newstate, oldstate)
    -- You could, alternatively, use the Overworld.OnEncounterEnding() to run this code. Check that out.
    if oldstate == "BEFOREDONE" then
        unescape = false

        -------
        CYK.State("NONE")
        CYK.EncunterWrapUp()
        Overworld.isBattleOutro = false
        -------

        Overworld.CutsceneObj.startSpecialCustscene[2] = true
    end
    battleFile.EnteringState(newstate, oldstate)
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

-- ...and *this* is called once the Item animation reaches the actionFrame.
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