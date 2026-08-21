client.RemoveConVarProtection("sv_cheats")
client.SetConVar("sv_cheats", 1)

-- Check the current value of 'mat_fullbright'
local fullBright = client.GetConVar("mat_fullbright")

-- Convert 'fullBright' to a number for comparison
fullBright = tonumber(fullBright)

-- If 'mat_fullbright' is 0, set it to 1; if it's 1, set it to 0
if fullBright == 0 then
    client.Command("mat_fullbright 1")
elseif fullBright == 1 then
    client.Command("mat_fullbright 0")
end
