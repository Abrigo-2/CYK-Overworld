return function()
    local self = { }

    
    self.allDialogues = {}

    --[[ Comment when optimizing.

    -- First, loads the path of every available dialogue file into the allDialogues table.
    -- Remember: These must have the same name as the Room they'll be used with!
    for key, value in pairs(Misc.ListDir("/Lua/Overworld/Dialogues/")) do
        local fakekey = string.gsub(value, "/Lua/Overworld/Dialogues/", "")
        fakekey = string.gsub(value, ".json", "")

        self.allDialogues[fakekey] = "/Lua/Overworld/Dialogues/" .. value
    end

    -- Then, converts all the json data into tables
    function self.ConvertDialoguesfromJson()
        for key, value in pairs(self.allDialogues) do
            local jsonString = ""
            local file = Misc.OpenFile(value, "r")
            file = file.ReadLines()
            for i=1, #file do
                jsonString = jsonString .. file[i]
            end
            
            local file = json.decode_ot_error(jsonString)

            self.allDialogues[key] = file
        end
    end
    self.ConvertDialoguesfromJson()
    

    function self.getDialogue(room, id)
        if self.allDialogues[room] == nil then
            error("The file \"Overworld/Dialogues/" .. room .. ".json\" doesn't exist. Add a valid JSON file within the respective folder.")
        elseif self.allDialogues[room][id] == nil then
            error("Dialogue ID \"" .. id .. "\", in room \"" .. room .. "\", doesn't exist. Check the respective JSON within the Dialogues folder.")
        end
        
        return table.copy(self.allDialogues[room][id])
        
    end
    --]]

    function self.ConvertDialoguesfromJson_Optimized()
        local jsonString = ""
        local file = Misc.OpenFile("/Lua/Overworld/AllDialogues.json", "r")
        file = file.ReadLines()
        for i=1, #file do
            jsonString = jsonString .. file[i]
        end
        
        local file = json.decode_ot_error(jsonString)

        self.allDialogues["AllDialogues"] = file
    end

    -- [[ Uncomment when optimizing.
    self.ConvertDialoguesfromJson_Optimized()

    function self.getDialogue(room, id)
        return table.copy(self.allDialogues["AllDialogues"][id]) end
    --]]

    return self
end