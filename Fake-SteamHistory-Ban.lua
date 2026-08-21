--===============================================================
--
-- # Discord
-- @ purrspire
--
-- # GitHub
-- @ NoStir
--
-- # Lbox forums
-- @ TimLeary
--
-- This script detects when the local player initiates a kick
-- vote and then sends a message in chat with a fake steamhistory
-- link, the target player's name, and a random ban date and time.
--
-- It also contains commented out code for logging vote events,
-- catching vote pass/fail events, and tracking votes that I used
-- for testing. I left it in for anyone that knows what they're
-- doing and wants to use it for their own purposes. 
--
--===============================================================

local votes = {}

--[[
local function log(text)
    client.ChatSay("\x04[Vote]\x01 " .. text)
end
]]

local function playerName(entityIndex)
    if not entityIndex or entityIndex <= 0 then
        return nil
    end

    local name = client.GetPlayerNameByIndex(entityIndex)

    if not name or name == "" then
        return nil
    end

    return name
end

local function randomID()
    local firsthalf = math.random(71561198, 76561198)
    local secondhalf = math.random(287178989, 787178566)

    return string.format("%d%09d", firsthalf, secondhalf)
end

local function randomDate()
    local year = math.random(2025, 2026)
    local minMonth = year == 2025 and 8 or 1
    local maxMonth = year == 2025 and 12 or 6

    return ("%04d-%02d-%02d"):format(
        year,
        math.random(minMonth, maxMonth),
        math.random(1, 28)
    )
end

local function randomTime()
    return ("%02d:%02d:%02d"):format(
        math.random(0, 23),
        math.random(0, 59),
        math.random(0, 59)
    )
end

callbacks.Unregister("DispatchUserMessage", "VoteTracker")
callbacks.Register("DispatchUserMessage", "VoteTracker", function(msg)

    local id = msg:GetID()
    local bf = msg:GetBitBuffer()

    if id == 46 then
        bf:SetCurBit(0)

        local team = bf:ReadByte() 
        local voteId = bf:ReadInt(32)
        local callerIndex = bf:ReadByte()
        local issue = bf:ReadString(256)
        local details = bf:ReadString(256)
        local isYesNo = bf:ReadBit() ~= 0
        local targetIndex = bf:ReadByte()

        local caller = playerName(callerIndex) or ("entity #" .. callerIndex)
        local target = playerName(targetIndex)

        if not target or target == "" then
            target = (details and details ~= "") and details
        end

        local playerIndex = client.GetLocalPlayerIndex()
        if playerIndex ~= callerIndex then
            return
        end
--[[ 
        votes[voteId] = {
            voteId = voteId,
            team = team,
            caller = caller,
            callerIndex = callerIndex,
            issue = issue,
            details = details,
            target = target,
            targetIndex = targetIndex
        }
]]
--[[
        log(string.format(
            "START | id=%d | caller=%s | issue=%q | details=%q | target=%s (#%d)",
            voteId,
            caller,
            issue,
            details,
            target,
            targetIndex
        ))
--]]
        if string.find(string.lower(issue), "kick", 1, true) then
            client.ChatSay(string.format(
            "https://steamhistory.net/id/%s | %s | Reason: [AC] Cheat Detected | Ban Date: %s %s",
            randomID(),
            target,
            randomDate(),
            randomTime()
            --"KICK | %s called a kick vote against %s",
            -- caller,
            ))
        end

--==================================================
-- #VotePass
--==================================================

--[[
        elseif id == 47 then
        bf:SetCurBit(0)

        local team = bf:ReadByte()
        local voteId = bf:ReadInt(32)
        local passMessage = bf:ReadString(256)
        local details = bf:ReadString(256)

        local vote = votes[voteId]

        if vote and string.find(string.lower(vote.issue), "kick", 1, true) then
            log("RESULT | kick against " .. vote.target .. " PASSED")
        else
            log(string.format(
                "RESULT | vote #%d PASSED | message=%q | details=%q",
                voteId,
                passMessage,
                details
            ))
        end

        votes[voteId] = nil
--]]

--==================================================
-- #VoteFailed
--==================================================
--[[
    elseif id == 48 then
        bf:SetCurBit(0)

        local team = bf:ReadByte()
        local voteId = bf:ReadInt(32)
        local reason = bf:ReadByte()

        local vote = votes[voteId]

        if vote and string.find(string.lower(vote.issue), "kick", 1, true) then
            log("RESULT | kick against " .. vote.target .. " FAILED")
        else
            log(string.format(
                "RESULT | vote #%d FAILED | reason=%d",
                voteId,
                reason
            ))
        end

        votes[voteId] = nil
--]]
    end
end)
