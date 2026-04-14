# Lua Callbacks

*Source: https://lmaobox.net/lua/Lua_Callbacks/*

---



# Lua Callbacks


Callbacks are the functions that are called when certain events happen. They are usually the most key parts of your scripts, and include functions like `Draw()`, which is called every frame - and as such is useful for drawing. Different callbacks are called in different situations, and you can use them to add custom functionality to your scripts.


## Callbacks


### Draw()


Called every frame. It is called after the screen is rendered, and can be used to draw text or objects on the screen.


### DrawModel( DrawModelContext:ctx )


Called every time a model is just about to be drawn on the screen. You can use this to change the material used to draw the model or do some other effects.\


### DrawStaticProps( StaticPropRenderInfo:info )


Called every time static props are just about to be drawn on the screen. You can use this to change colors, materials, or do some other effects.


### CreateMove( UserCmd:cmd )


Called every input update (66 times/sec), allows to modify viewangles, buttons, packet sending, etc. Useful for changing player movement or inputs.


### FireGameEvent( GameEvent:event )


Called for all available game events. Game events are small packets of information that are sent from the server to the client, data about a situation that has happened.


### DispatchUserMessage( UserMessage:msg )


Called on every user message of type [UserMessage](../Lua_Classes/UserMessage/). User messages are small packets of information that are sent from the server to the client, data about a situation that has happened.


### SendStringCmd( StringCmd:cmd )


Called when console command is sent to server, ex. chat command "say".


### FrameStageNotify( stage:integer )


Called multiple times per frame for each stage of the frame, such as rendering start, end, network update start, end, etc. You can do some actions here better than anywhere else. Make sure to check the E_ClientFrameStage constant.
This used to be PostPropUpdate if you only updates on NETWORK_UPDATE_START. PostPropUpdate is now deprecated, please do not use it.


### RenderView( ViewSetup:view )


Called before the players view of type [ViewSetup](../Lua_Classes/ViewSetup/) is rendered. You can use this to change the view, such as changing the view angles, fov, or origin.


### PostRenderView( ViewSetup:view )


Called after a players view of type [ViewSetup](../Lua_Classes/ViewSetup/) is rendered. This is an ideal place to draw custom views (such as camera views) on the screen, as the primary view has already been rendered.


### RenderViewModel( ViewSetup:vmview )


Called before the players viewmodel view of type [ViewSetup](../Lua_Classes/ViewSetup/) is rendered. You can use this to change the rendering of the viewmodel, such as changing the viewmodel angles, fov, or origin.


### ServerCmdKeyValues( StringCmd:keyvalues )


Called when the client sends a keyvalues message to the server. Keyvalues are a way of sending data to the server, and are used for many things, such as sending MVM Upgrades, using items, and more.


### OnFakeUncrate( Item:crate, Table:crateLootList )


Called when a fake crate is to be uncrated. This is called before the crate is actually uncrated. You can return a table of items that will be shown as uncrated. The loot list is useful as a reference for what items can be uncrated in this crate, but you can create any items you want.


### OnLobbyUpdated( GameServerLobby:lobby )


Called when a lobby is found or updated. This can also be called before the lobby is joined, so you can use this to decide whether or not to join the game (abandon), or to do something with the list of players in the lobby if youre in the game.


### SetRichPresence( String:key, String:value )


Called when the rich presence is updated. Key is the name of the rich presence, and value is the value of the rich presence. Return the value you want to set this key to, or nil to not change it.


### GCSendMessage( typeID:integer, data:StringCmd)


Called when a message is being sent to the GC. You can use this to intercept messages sent to the GC, and modify them or not send them at all.


### GCRetrieveMessage( typeID:integer, data:StringCmd)


Called when a message is being received from the GC. You can use this to intercept messages received from the GC, and modify them or not process them at all. Return E_GCResults.k_EGCResultOK to process the message, or E_GCResults.k_EGCResultNoMessage to not process it.


### SendNetMsg( NetMessage:msg, reliable:boolean, voice:boolean )


Called when a message of type [NetMessage](../Lua_Classes/NetMessage/) is being sent to the server. You can use this to intercept messages sent to the server, and modify them or not send them at all. Return true to send the message, or false to not send it.


### DoPostScreenSpaceEffects()


This is called after the screen space effects are rendered. You can use this to draw custom screen space effects, such as a custom bloom effect, or a custom blur effect, etc.


### ProcessTempEntities( Table entEvtTable )


Called immediately when server sends one or more temporary entities to the client. Table consists of [TempEntity](../Lua_Classes/TempEntity/) in first place and [EventInfo](../Lua_Classes/EventInfo/) in the second place for each temporary entity. You may modify the entity and event data or read the temporary entity netvars before it is destroyed.


### Unload()


Callback called when the script file which registered it is unloaded. This is called before the script is unloaded, so you can still use your script variables.


## Examples


Intercepting GC messages
```
-- Protobuf messages
callbacks.Register("GCSendMessage", function(typeID, data)

  print("GCSendMessage: " .. typeID .. " dataLength: " .. #data)

  return E_GCResults.k_EGCResultOK
end)

callbacks.Register("GCRetrieveMessage", function(typeID, data)

  print("GCRetrieveMessage: " .. typeID .. " dataLength: " .. #data)

  if typeID == 26 then
    return E_GCResults.k_EGCResultNoMessage
  end

  return E_GCResults.k_EGCResultOK
end)

```

Basic player ESP
```
local myfont = draw.CreateFont( "Verdana", 16, 800 )

local function doDraw()
    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end

    local players = entities.FindByClass("CTFPlayer")

    for i, p in ipairs( players ) do
        if p:IsAlive() and not p:IsDormant() then

            local screenPos = client.WorldToScreen( p:GetAbsOrigin() )
            if screenPos ~= nil then
                draw.SetFont( myfont )
                draw.Color( 255, 255, 255, 255 )
                draw.Text( screenPos[1], screenPos[2], p:GetName() )
            end
        end
    end
end

callbacks.Register("Draw", "mydraw", doDraw) 

```

Damage logger - by @RC
```
local function damageLogger(event)

    if (event:GetName() == 'player_hurt' ) then

        local localPlayer = entities.GetLocalPlayer();
        local victim = entities.GetByUserID(event:GetInt("userid"))
        local health = event:GetInt("health")
        local attacker = entities.GetByUserID(event:GetInt("attacker"))
        local damage = event:GetInt("damageamount")

        if (attacker == nil or localPlayer:GetIndex() ~= attacker:GetIndex()) then
            return
        end

        print("You hit " ..  victim:GetName() .. " or ID " .. victim:GetIndex() .. " for " .. damage .. "HP they now have " .. health .. "HP left")
    end

end

callbacks.Register("FireGameEvent", "exampledamageLogger", damageLogger)
-- Made by @RC: https://github.com/racistcop/lmaobox-luas/blob/main/example-damagelogger.lua

```

OnFakeUncrate callback
```
--- OnFakeUncrate gets called when user is unboxing a fake crate with a fake key, 
--- both could be created by our skinchanger and via CreateFakeItem method
callbacks.Register( "OnFakeUncrate", "abcd", function( itemCrate, lootTable )
    print( "OnFakeUncrate" )
    print( "itemCrate Name: " .. itemCrate:GetName() )

    for i = 1, #lootTable do
        print( "lootTable[" .. i .. "] Name: " .. lootTable[i]:GetName() )
    end

    return lootTable
end )

--- modify unboxing to always unbox rainbow flamethrower (15090)
callbacks.Register( "OnFakeUncrate", "abcd", function( itemCrate, lootTable )
    print( "OnFakeUncrate crate: " .. itemCrate:GetName() )

    local myLootTable = {}
    myLootTable[1] = itemschema.GetItemDefinitionByID(15090)

    return myLootTable
end )

```


