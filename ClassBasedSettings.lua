-- Constants for class indexes
local CLASS_SCOUT = 1
local CLASS_SNIPER = 2
local CLASS_SOLDIER = 3
local CLASS_DEMOMAN = 4
local CLASS_MEDIC = 5
local CLASS_HEAVY = 6
local CLASS_PYRO = 7
local CLASS_SPY = 8
local CLASS_ENGINEER = 9

-- Define a table with functions for each class customization including a default settings function
classCustomizationFunctions = {
    default = function() 
        print("Applying Default Global custom settings first...")
        gui.SetValue("aim bot", 1)
        gui.SetValue("trigger shoot", 0)
        gui.SetValue("aim fov", 20)
        gui.SetValue("aim key", 79)
        gui.SetValue("trigger key", 0)
        gui.SetValue("trigger shoot key", 0)
        gui.SetValue("auto airblast", 0)
        gui.SetValue("preserve target", 0)
        gui.SetValue("TARGET SWITCH DELAY (MS)", 0)
        gui.SetValue("priority", "closest to crosshair")
        gui.SetValue("nospread", 0)
        gui.SetValue("norecoil", 1)
    end,
    [CLASS_SCOUT] = function() 
        -- Custom settings for Scout
        print("Applying Scout custom settings...")
       --
    end,
    [CLASS_SNIPER] = function() 
        -- Custom settings for Sniper
        print("Applying Sniper custom settings...")
        gui.SetValue("aim bot", 0)
        gui.SetValue("trigger shoot", 1)
        gui.SetValue("trigger shoot key", 79)
    end,
    [CLASS_SOLDIER] = function() 
        -- Custom settings for Soldier
        print("Applying Soldier custom settings...")
        --
    end,
    [CLASS_DEMOMAN] = function() 
        -- Custom settings for Demoman
        print("Applying Demoman custom settings...")
        --
    end,
    [CLASS_MEDIC] = function() 
        -- Custom settings for Medic
        print("Applying Medic custom settings...")
        gui.SetValue("preserve target", 1)
        gui.SetValue("TARGET SWITCH DELAY (MS)", 750)
        gui.SetValue("priority", "lowest health")
    end,
    [CLASS_HEAVY] = function() 
        -- Custom settings for Heavy
        print("Applying Heavy custom settings...")
        gui.SetValue("aim bot", 0)
        gui.SetValue("nospread", 1)
        gui.SetValue("norecoil", 1)
    end,
    [CLASS_PYRO] = function() 
        -- Custom settings for Pyro
        print("Applying Pyro custom settings...")
        gui.SetValue("aim fov", 30)
        gui.SetValue("aim key", 0)
        gui.SetValue("auto shoot", 0)
        gui.SetValue("trigger key", 79)
        gui.SetValue("auto airblast", "RAGE")
    end,
    [CLASS_SPY] = function() 
        -- Custom settings for Spy
        print("Applying Spy custom settings...")
        gui.SetValue("aim fov", 5)
        gui.SetValue("melee aimbot", "RAGE")
    end,
    [CLASS_ENGINEER] = function() 
        -- Custom settings for Engineer
        print("Applying Engineer custom settings...")
        --
    end,
}

-- Registers the callback for handling game events
callbacks.Register("FireGameEvent", function(event)
    if event:GetName() == "player_changeclass" then
        local eventClassIndex = event:GetInt("class")
        
        classCustomizationFunctions.default()  -- Apply global default settings first

        if classCustomizationFunctions[eventClassIndex] then
            classCustomizationFunctions[eventClassIndex]()
        end
    end
end)

print("Customization template loaded. Adjust settings in the classCustomizationFunctions table.")
