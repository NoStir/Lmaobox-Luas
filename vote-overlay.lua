-- TF2 vote overlay
-- Discord: @purrspire
-- 7/27/2026

local CALLBACK_ID = "ReliableVoteOverlay"
local RESULT_SECONDS = 4
local STALE_VOTE_SECONDS = 90
local MAX_OPTIONS = 5

local PANEL_MARGIN = 16
local PANEL_MAX_WIDTH = 680
local OPTION_SPACING = 32

local titleFont = draw.CreateFont("Verdana", 28, 800, FONTFLAG_OUTLINE)
local questionFont = draw.CreateFont("Verdana", 22, 700, FONTFLAG_OUTLINE)
local bodyFont = draw.CreateFont("Verdana", 20, 600, FONTFLAG_OUTLINE)

local activeVote = nil
local pendingOptions = nil

local issueFallbacks = {
    ["#TF_vote_kick_player_other"] = "Kick player: %s? (no reason given)",
    ["#TF_vote_kick_player_idle"] = "Kick player: %s? (accused of being idle)",
    ["#TF_vote_kick_player_cheating"] = "Kick player: %s? (accused of cheating)",
    ["#TF_vote_kick_player_scamming"] = "Kick player: %s? (accused of scamming)",
    ["#TF_vote_restart_game"] = "Restart the map?",
    ["#TF_vote_changelevel"] = "Change current level to %s?",
    ["#TF_vote_nextlevel"] = "Set the next level to %s?",
    ["#TF_vote_nextlevel_choices"] = "Vote for the next map",
    ["#TF_vote_scramble_teams"] = "Scramble the teams?",
    ["#TF_vote_should_scramble_round"] = "Scramble teams next round?",
    ["#TF_vote_td_start_round"] = "Start the current round?",
    ["#TF_vote_changechallenge"] = "Change the MvM mission to %s?",
    ["#TF_vote_eternaween"] = "Activate Halloween mode?",
    ["#TF_vote_autobalance_enable"] = "Enable autobalance?",
    ["#TF_vote_autobalance_disable"] = "Disable autobalance?",
    ["#TF_vote_classlimits_enable"] = "Enable class limits?",
    ["#TF_vote_classlimits_disable"] = "Disable class limits?",
    ["#TF_playerid_noteam"] = "%s"
}

local failureReasons = {
    [0] = "Vote failed",
    [3] = "Vote failed: yes votes did not exceed no votes",
    [4] = "Vote failed: not enough players voted"
}

local function safeString(value, fallback)
    if type(value) ~= "string" or value == "" then
        return fallback or "Unknown"
    end

    return value
end

local function oneLine(value)
    return safeString(value):gsub("[\r\n]+", " / ")
end

local function isPlaceholderText(value)
    if type(value) ~= "string" then
        return true
    end

    local lowered = string.lower(value)
    return lowered == ""
        or lowered == "unknown vote"
        or lowered:find("%%voteissue%%") ~= nil
        or lowered:find("%%target%%") ~= nil
        or lowered:find("%%details%%") ~= nil
end

local function playerName(index)
    if not index or index <= 0 then
        return nil
    end

    local name = client.GetPlayerNameByIndex(index)
    if not name or name == "" then
        return nil
    end

    return name
end

local function callerName(index)
    if index == 99 then
        return "Server"
    end

    return playerName(index) or ("Entity #" .. tostring(index or "?"))
end

local function teamName(team)
    if team == 2 then
        return "RED only"
    elseif team == 3 then
        return "BLU only"
    end

    return "All players"
end

local function substituteDetail(template, details)
    local detail = safeString(details, "")
    local result, replacements = template:gsub("%%s1", function()
        return detail
    end)

    if replacements == 0 then
        result = result:gsub("%%s", function()
            return detail
        end)
    end

    return oneLine(result)
end

local function resolveLocalizedText(token, details)
    token = safeString(token, "Unknown vote")

    local localized = client.Localize(token)
    if localized and localized ~= "" and localized ~= token then
        local resolved = substituteDetail(localized, details)
        if not isPlaceholderText(resolved) then
            return resolved
        end
    end

    local fallback = issueFallbacks[token]
    if fallback then
        return substituteDetail(fallback, details)
    end

    if details and details ~= "" then
        return oneLine(details)
    end

    return oneLine(token:gsub("^#", ""))
end

local function resolveOption(option, index)
    option = safeString(option, "Option " .. tostring(index))

    local localized = client.Localize(option)
    if localized and localized ~= "" and localized ~= option then
        return oneLine(localized)
    end

    return oneLine(option:gsub("^#", ""))
end

local function copyOptions(source)
    local result = {}
    if not source then
        return result
    end

    for i = 1, math.min(source.count or 0, MAX_OPTIONS) do
        result[i] = source[i]
    end

    return result
end

local function isPlayerIndex(index)
    return type(index) == "number"
        and index >= 1
        and index <= globals.MaxClients()
end

local function findPlayerIndexByName(name)
    if type(name) ~= "string" or name == "" then
        return nil, nil
    end

    local wanted = string.lower(name)
    for index = 1, globals.MaxClients() do
        local candidate = playerName(index)
        if candidate and string.lower(candidate) == wanted then
            return index, candidate
        end
    end

    return nil, nil
end

local function optionsIndicateYesNo(options)
    if not options or options.count ~= 2 then
        return false
    end

    local first = string.lower(safeString(options[1], ""))
    local second = string.lower(safeString(options[2], ""))
    return first == "yes" and second == "no"
end

local function callerMayVoteNo()
    local value = client.GetConVar("sv_vote_holder_may_vote_no")
    return tonumber(value) == 1
end

local function beginVote(
    team,
    voteId,
    callerIndex,
    issue,
    details,
    isYesNo,
    targetIndex
)
    local issueIsKick = type(issue) == "string"
        and string.lower(issue):find("kick", 1, true) ~= nil
    local target = playerName(targetIndex)

    if issueIsKick then
        local matchedIndex, matchedName = findPlayerIndexByName(details)
        if matchedIndex then
            targetIndex = matchedIndex
            target = matchedName
        end
    end

    local resolvedDetails = safeString(details, "")

    if target and issueIsKick then
        resolvedDetails = target
    end

    local resolvedIsYesNo = isYesNo == true
        or issueIsKick
        or optionsIndicateYesNo(pendingOptions)

    local options
    if resolvedIsYesNo then
        options = {"Yes", "No"}
    else
        options = copyOptions(pendingOptions)
    end

    local counts = {0, 0, 0, 0, 0}
    local voters = {}
    local localChoice = nil
    local localChoiceReason = nil
    local localIndex = client.GetLocalPlayerIndex()
    local isKickVote = issueIsKick
    local callerForcedYes = resolvedIsYesNo
        and isPlayerIndex(callerIndex)
        and not callerMayVoteNo()

    if callerForcedYes then
        counts[1] = counts[1] + 1
        voters[callerIndex] = 1

        if localIndex == callerIndex then
            localChoice = 1
            localChoiceReason = "caller"
        end
    end

    if isKickVote then
        if isPlayerIndex(targetIndex) and targetIndex ~= callerIndex then
            counts[2] = counts[2] + 1
            voters[targetIndex] = 2

            if localIndex == targetIndex then
                localChoice = 2
                localChoiceReason = "target"
            end
        end
    end

    activeVote = {
        team = team or 0,
        voteId = voteId,
        callerIndex = callerIndex or 99,
        caller = callerName(callerIndex),
        targetIndex = targetIndex,
        target = target,
        issueToken = safeString(issue, "Unknown vote"),
        question = resolveLocalizedText(issue, resolvedDetails),
        details = resolvedDetails,
        isYesNo = resolvedIsYesNo,
        isKickVote = isKickVote,
        callerForcedYes = callerForcedYes,
        options = options,
        counts = counts,
        voters = voters,
        potentialVotes = 0,
        localChoice = localChoice,
        localChoiceReason = localChoiceReason,
        pendingChoice = nil,
        pendingAt = nil,
        startedAt = globals.RealTime(),
        result = nil,
        resultUntil = nil
    }

    pendingOptions = nil
end

local function readVoteStart(msg)
    local bf = msg:GetBitBuffer()
    local oldBit = bf:GetCurBit()
    bf:SetCurBit(0)

    local ok, team, voteId, callerIndex, issue, details, yesNo, targetIndex =
        pcall(function()
            return bf:ReadByte(),
                bf:ReadInt(32),
                bf:ReadByte(),
                bf:ReadString(256),
                bf:ReadString(256),
                bf:ReadBit() ~= 0,
                bf:ReadByte()
        end)

    bf:SetCurBit(oldBit)

    if ok then
        beginVote(
            team,
            voteId,
            callerIndex,
            issue,
            details,
            yesNo,
            targetIndex
        )
    end
end

local function readVotePass(msg)
    local bf = msg:GetBitBuffer()
    local oldBit = bf:GetCurBit()
    bf:SetCurBit(0)

    local ok, _, voteId, passToken, details = pcall(function()
        return bf:ReadByte(),
            bf:ReadInt(32),
            bf:ReadString(256),
            bf:ReadString(256)
    end)

    bf:SetCurBit(oldBit)

    if ok
        and activeVote
        and (activeVote.voteId == nil or activeVote.voteId == voteId) then
        activeVote.result = resolveLocalizedText(passToken, details)
        activeVote.resultUntil = globals.RealTime() + RESULT_SECONDS
    end
end

local function readVoteFailed(msg)
    local bf = msg:GetBitBuffer()
    local oldBit = bf:GetCurBit()
    bf:SetCurBit(0)

    local ok, _, voteId, reason = pcall(function()
        return bf:ReadByte(), bf:ReadInt(32), bf:ReadByte()
    end)

    bf:SetCurBit(oldBit)

    if ok
        and activeVote
        and (activeVote.voteId == nil or activeVote.voteId == voteId) then
        activeVote.result = failureReasons[reason]
            or ("Vote failed: reason " .. tostring(reason))
        activeVote.resultUntil = globals.RealTime() + RESULT_SECONDS
    end
end

local function localPlayerCanVote(vote)
    if vote.team == 0 or vote.team == 255 then
        return true
    end

    local player = entities.GetLocalPlayer()
    return player ~= nil and player:GetTeamNumber() == vote.team
end

local function submitVote(option)
    if not activeVote
        or activeVote.result
        or activeVote.localChoice
        or activeVote.pendingChoice then
        return
    end

    if not localPlayerCanVote(activeVote) then
        return
    end

    if option < 1 or option > #activeVote.options then
        return
    end

    client.Command("vote option" .. tostring(option), true)
    activeVote.pendingChoice = option
    activeVote.pendingAt = globals.RealTime()
end

local function handleVoteOptions(event)
    local count = math.min(math.max(event:GetInt("count"), 0), MAX_OPTIONS)
    local options = {count = count}

    for i = 1, count do
        options[i] = resolveOption(event:GetString("option" .. tostring(i)), i)
    end

    pendingOptions = options
end

local function handleVoteCast(event)
    if not activeVote then
        return
    end

    local voterIndex = event:GetInt("entityid")
    local option = event:GetInt("vote_option") + 1
    if option >= 1 and option <= MAX_OPTIONS then
        local previousOption = activeVote.voters[voterIndex]

        if previousOption == nil then
            activeVote.counts[option] = (activeVote.counts[option] or 0) + 1
        elseif previousOption ~= option then
            activeVote.counts[previousOption] = math.max(
                (activeVote.counts[previousOption] or 0) - 1,
                0
            )
            activeVote.counts[option] = (activeVote.counts[option] or 0) + 1
        end

        activeVote.voters[voterIndex] = option
    end

    if voterIndex == client.GetLocalPlayerIndex() then
        activeVote.localChoice = option
        activeVote.localChoiceReason = activeVote.localChoiceReason or "submitted"
        activeVote.pendingChoice = nil
        activeVote.pendingAt = nil
    end
end

local function handleVoteChanged(event)
    if not activeVote then
        return
    end

    for i = 1, MAX_OPTIONS do
        local reportedCount = event:GetInt("option" .. tostring(i))
        activeVote.counts[i] = math.max(
            activeVote.counts[i] or 0,
            reportedCount
        )
    end

    activeVote.potentialVotes = event:GetInt("potentialVotes")
end

local function handleVoteStartedFallback(event)
    if activeVote and not isPlaceholderText(activeVote.question) then
        return
    end

    local options = pendingOptions
    local isYesNo = options
        and options.count == 2
        and string.lower(options[1] or "") == "yes"
        and string.lower(options[2] or "") == "no"

    beginVote(
        event:GetInt("team"),
        nil,
        event:GetInt("initiator"),
        event:GetString("issue"),
        event:GetString("param1"),
        isYesNo,
        nil
    )
end

local function handleGameEvent(event)
    local name = event:GetName()

    if name == "vote_options" then
        handleVoteOptions(event)
    elseif name == "vote_cast" then
        handleVoteCast(event)
    elseif name == "vote_changed" then
        handleVoteChanged(event)
    elseif name == "vote_started" then
        handleVoteStartedFallback(event)
    elseif name == "vote_ended" and activeVote and not activeVote.result then
        activeVote.result = "Vote ended"
        activeVote.resultUntil = globals.RealTime() + RESULT_SECONDS
    end
end

local function handleUserMessage(msg)
    local id = msg:GetID()

    if id == 46 then
        readVoteStart(msg)
    elseif id == 47 then
        readVotePass(msg)
    elseif id == 48 then
        readVoteFailed(msg)
    end
end

local function drawText(x, y, text, r, g, b)
    draw.Color(r or 235, g or 235, b or 235, 255)
    draw.TextShadow(x, y, text)
end

local function drawVote()
    if not activeVote then
        return
    end

    local now = globals.RealTime()
    if activeVote.resultUntil and now >= activeVote.resultUntil then
        activeVote = nil
        return
    end

    if not activeVote.result
        and now - activeVote.startedAt > STALE_VOTE_SECONDS then
        activeVote = nil
        return
    end

    if engine.Con_IsVisible() or engine.IsGameUIVisible() or engine.IsChatOpen() then
        return
    end

    if activeVote.pendingAt and now - activeVote.pendingAt > 2.5 then
        activeVote.pendingChoice = nil
        activeVote.pendingAt = nil
    end

    if not activeVote.result
        and not activeVote.localChoice
        and not activeVote.pendingChoice then
        for i = 1, #activeVote.options do
            if input.IsButtonPressed(KEY_F1 + i - 1) then
                submitVote(i)
                break
            end
        end
    end

    local screenW, screenH = draw.GetScreenSize()
    local width = math.min(PANEL_MAX_WIDTH, screenW - PANEL_MARGIN * 2)
    local x = PANEL_MARGIN
    local optionCount = math.max(#activeVote.options, 1)
    local height = 178 + optionCount * OPTION_SPACING
    local preferredY = math.floor(screenH * 0.20)
    local y = math.max(12, math.min(preferredY, screenH - height - 12))

    draw.Color(15, 18, 22, 235)
    draw.FilledRect(x, y, x + width, y + height)
    draw.Color(210, 160, 70, 255)
    draw.OutlinedRect(x, y, x + width, y + height)

    draw.SetFont(titleFont)
    drawText(x + 16, y + 12, activeVote.result and "VOTE RESULT" or "VOTE CALLED",
        activeVote.result and 245 or 255,
        activeVote.result and 220 or 190,
        activeVote.result and 120 or 80)

    draw.SetFont(questionFont)
    drawText(x + 16, y + 50, activeVote.question, 255, 255, 255)

    draw.SetFont(bodyFont)
    drawText(x + 16, y + 82,
        "Called by: " .. activeVote.caller
            .. "  |  Scope: " .. teamName(activeVote.team),
        190, 205, 220)

    if activeVote.details ~= ""
        and oneLine(activeVote.details) ~= activeVote.question then
        drawText(x + 16, y + 112, "Details: " .. oneLine(activeVote.details),
            190, 205, 220)
    end

    local optionY = y + 142
    if activeVote.result then
        drawText(x + 16, optionY, activeVote.result, 245, 220, 120)
        return
    end

    if #activeVote.options == 0 then
        drawText(x + 16, optionY,
            "Waiting for vote options; use the stock panel if they do not arrive.",
            255, 190, 100)
    else
        for i, option in ipairs(activeVote.options) do
            local selected = activeVote.localChoice == i
            local pending = activeVote.pendingChoice == i
            local label = string.format(
                "F%d  %s  [%d vote%s]%s%s",
                i,
                option,
                activeVote.counts[i] or 0,
                (activeVote.counts[i] or 0) == 1 and "" or "s",
                selected and "  - YOUR VOTE" or "",
                pending and "  - SENT..." or ""
            )

            if selected then
                drawText(x + 16, optionY + (i - 1) * OPTION_SPACING,
                    label, 110, 225, 130)
            elseif pending then
                drawText(x + 16, optionY + (i - 1) * OPTION_SPACING,
                    label, 245, 205, 100)
            else
                drawText(x + 16, optionY + (i - 1) * OPTION_SPACING, label)
            end
        end
    end

    local footer = "Press F1-F" .. tostring(math.max(#activeVote.options, 1))
        .. " to vote"
    if activeVote.potentialVotes > 0 then
        footer = footer .. "  |  Eligible voters: "
            .. tostring(activeVote.potentialVotes)
    end

    if not localPlayerCanVote(activeVote) then
        footer = "You are not eligible for this team-specific vote"
    elseif activeVote.localChoice then
        if activeVote.localChoiceReason == "caller" then
            footer = "Vote locked automatically: Yes (you called the vote)"
        elseif activeVote.localChoiceReason == "target" then
            footer = "Vote locked automatically: No (you are the target)"
        else
            footer = "Vote submitted: "
                .. activeVote.options[activeVote.localChoice]
        end
    elseif activeVote.pendingChoice then
        footer = "Vote sent; waiting for server confirmation"
    end

    drawText(x + 16, y + height - 30, footer, 185, 200, 215)
end

callbacks.Unregister("DispatchUserMessage", CALLBACK_ID)
callbacks.Unregister("FireGameEvent", CALLBACK_ID)
callbacks.Unregister("Draw", CALLBACK_ID)

callbacks.Register("DispatchUserMessage", CALLBACK_ID, handleUserMessage)
callbacks.Register("FireGameEvent", CALLBACK_ID, handleGameEvent)
callbacks.Register("Draw", CALLBACK_ID, drawVote)
