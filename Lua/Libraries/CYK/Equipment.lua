-- Weapons! Armors! None of this gets referenced in code anywhere yet,
-- so go WILD!!

return function(self)
    local self = { }

    self.Weapons = {}

    -- Add available weapons
    self.Weapons["SpookSword"] = {
        {atk= 4, def=0, mag=0}, -- Stats increased
        name = "SpookSword",
        description = "A scary sword. Smells mellow."
    }
    self.Weapons["Ragger"] = {
        {atk= 2, def=0, mag=0}, -- Stats increased
        name = "Ragger",
        description = "A rugged scarf. Sharp as a tack."
    }
    self.Weapons["OldScythe"] = {
        {atk= 10, def=0, mag=0}, -- Stats increased
        name = "OldScythe",
        description = "Monster's scythe. A bit old, but still usable."
    }
    self.Weapons["empty"] = {
        {atk= 0, def=0, mag=0}, 
        name = "empty",
        descrpition = "How did this happen."
    }


    self.Armors = {}

    -- Add available Armors
    self.Armors["AmberCard"] = {
        {atk= 0, def=1, mag=0}, 
        name = "AmberCard",
        descrpition = "A yellow sticker that grants defense."
    }
    self.Armors["CelxPin"] = {
        {atk= 0, def=2.6, mag=0}, 
        name = "CelxPin",
        descrpition = "A pin of a crow with a lime jacket."
    }
    self.Armors["CritPin"] = {
        {atk= 0, def=2.6, mag=0}, 
        name = "CritPin",
        descrpition = "A pin of a bee with candy colored horns."
    }
    self.Armors["empty"] = {
        {atk= 0, def=0, mag=0}, 
        name = "empty",
        descrpition = ""
    }

    return self
end