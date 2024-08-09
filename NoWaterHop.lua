--local FL_INWATER = 1 << 10
local FL_ONGROUND = 1 << 0
local FL_DUCKING = 1 << 1
local FL_WATERJUMP = 1 << 2
local FL_ONTRAIN = 1 << 3
local FL_INRAIN = 1 << 4
local FL_FROZEN = 1 << 5
local FL_ATCONTROLS = 1 << 6
local FL_CLIENT = 1 << 7
local FL_FAKECLIENT = 1 << 8
local FL_INWATER = 1 << 9

draw.SetFont(draw.CreateFont("Tahoma", 16, 800))
local function drawInfo()
    draw.Color(255, 255, 255, 255)
    local me = entities.GetLocalPlayer()
    if not me then return end

    local flags = me:GetPropInt("m_fFlags")
    
    local xyz = me:GetPropInt("xyz")

    local screenSize = {x = 0, y = 0}
    screenSize.x, screenSize.y = draw.GetScreenSize()

    local drawPOS = {x = screenSize.x * 0.05, y = screenSize.y * 0.20}
    local moveFactorY = 0.05
    local moveFactorX = 0.15

    --[[
        FL_ONGROUND = (1 << 0),
      FL_DUCKING = (1 << 1),
      FL_WATERJUMP = (1 << 2),
      FL_ONTRAIN = (1 << 3),
      FL_INRAIN = (1 << 4),
      FL_FROZEN = (1 << 5),
      FL_ATCONTROLS = (1 << 6),
      FL_CLIENT = (1 << 7),
      FL_FAKECLIENT = (1 << 8),
      FL_INWATER = (1 << 9),
    ]]

    local 

    local Info = {
        "On ground: " .. tostring(flags & FL_ONGROUND == FL_ONGROUND),
        "Ducking: " .. tostring(flags & FL_DUCKING == FL_DUCKING),
        "Water jump: " .. tostring(flags & FL_WATERJUMP == FL_WATERJUMP),
        "On train: " .. tostring(flags & FL_ONTRAIN == FL_ONTRAIN),
        "In rain: " .. tostring(flags & FL_INRAIN == FL_INRAIN),
        "Frozen: " .. tostring(flags & FL_FROZEN == FL_FROZEN),
        "At controls: " .. tostring(flags & FL_ATCONTROLS == FL_ATCONTROLS),
        "Client: " .. tostring(flags & FL_CLIENT == FL_CLIENT),
        "Fake client: " .. tostring(flags & FL_FAKECLIENT == FL_FAKECLIENT),
        "In water: " .. tostring(flags & FL_INWATER == FL_INWATER),

    }

    for i, info in ipairs(Info) do
        draw.Text(drawPOS.x, drawPOS.y, info)
        drawPOS.y = drawPOS.y + (screenSize.y * moveFactorY)

        if drawPOS.y > screenSize.y * 0.80 then
            drawPOS.y = screenSize.y * 0.20
            drawPOS.x = drawPOS.x + (screenSize.x * moveFactorX)
        end
    end
end

callbacks.Register("Draw", drawInfo)