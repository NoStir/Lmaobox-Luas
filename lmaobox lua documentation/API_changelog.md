# API Changelog

*Source: https://lmaobox.net/lua/API_changelog/*

---



# API Changelog


All notable changes to LUA API will be documented in this file.


## [2nd Jun 2025]



- Added CreateTempEntityByName
- Added callback 'ProcessTempEntities'


## [11th Apr 2025]



- Added http.GetAsync
- Added GetInvisibility() / SetInvisibility into entity documentation
- Fixed examples in client class


## [15th Jan 2025]



- Fixed entity.ShouldDraw() incorrectly requiring int parameter
- Fixed item.SetAttribute to correctly accept string attribute such as item name


## [17th Dec 2024]



- Fixed DoPostSpaceScreenEffects callback not being called back
- Fixed render.DepthRange to take floats, not ints
- Fixed OnFakeUncrate callback, it now expect you to return loopTable, either the original one modified or your own, see new example in https://lmaobox.net/lua/Lua_Callbacks/


## [4th Dec 2024]



- entity:SetAbsAngles(Vector)
- entity:GetAbsAngles()
- DrawModelContext:SetColorModulation(r,g,b) - modulate via renderview for non studio models
- DrawModelContext:SetAlphaModulation(a) - modulate via renderview, for non studio models
- DrawModelContext::Execute() - render model in place with current overrides
- Testing performance improvements for Lua object creation, may or may not crash randomly for no reason let us know if that happens
- Fixed static props color modulation not working
- added callback RenderViewModel( ViewSetup:view ) -> Change viewsetup to change how viewmodel is rendered, nothing else is affected
- FrameStageNotify(stage) callback, extending PostPropUpdate callback which is now legacy only.
- fixed ent:SetAbsAngles()
- entity:GetVAngles() / SetVAngles() - set 3rd person view angles for player
- E_ClientFrameStage for FSN callback
- entity:GetInvisibility() / SetInvisibility() - set player invisibility level from 0 to 1
- render.DrawScreenSpaceQuad()
- render.Viewport( x:integer, y:integer, w:integer, h:integer)
- render.GetViewport()
- render.GetDepthRange()
- render.DepthRange( zNear:number, zFar:number)
- render.GetRenderTarget()
- render.SetRenderTarget(texture)
- render.ClearColor3ub
- render.ClearBuffer
- render.ClearColor4ub
- render.OverrideAlphaWriteEnable()
- render.OverrideDepthEnable
- render.PushRenderTargetAndViewport()
- render.SetStencilEnable( enable:boolean )
- render.PopRenderTargetAndViewport()
- render.SetStencilFailOperation( failOp:integer )
- render.SetStencilZFailOperation( zFailOp:integer )
- render.SetStencilPassOperation( passOp:integer )
- render.SetStencilCompareFunction( compareFunc:integer )
- render.SetStencilTestMask( mask:integer )
- render.SetStencilReferenceValue( comparationValue:integer )
- render.SetStencilWriteMask( mask:integer )
- E_StencilOperation and E_StencilComparisonFunction enums
- render.ForcedMaterialOverride( material )
- render.GetBlend()
- render.SetBlend()
- render.GetColorModulation()
- render.SetColorModulation()
- render.ClearStencilBufferRectangle( xmin:integer, ymin:integer, xmax:integer, ymax:integer, value:integer)
- New DoPostScreenSpaceEffects() callback, which is called when the game expects all screen effects to be drawn. Useful for custom glow
- DrawModel callback now resets color and alpha modulation along with depth range
- entity:GetMoveChild() - returns child entity attachment
- entity:GetMovePeer() - returns peer entity to the child
- materials.FindTexture()
- entity:ShouldDraw()
- Updated tf2 props page on Lua website
- dmc:IsDrawingBackTrack()
- dmc:IsDrawingAntiAim()
- dmc:IsDrawingGlow()
- http.Get(url)
- aimbot.GetAimbotTarget()
- gui.IsMenuOpen()
- engine.IsChatOpen()
- entity:DrawModel(flags) - trigger DrawModelExecute to draw a model right now
- Fixed typo in -  render.SetColorModulation(..)



