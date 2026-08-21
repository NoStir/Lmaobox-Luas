--=============================================================
-- crit_hud.lua 
-- crit / warp status panel
--
-- # Discord
-- @ purrspire
--
-- # GitHub
-- @ NoStir
--
--
-- With the lmaobox menu open: drag the panel to move it, drag the
-- bottom-right grip to scale it.
--=============================================================

                  local CONFIG={x=24,y=220--
             ,scale=1.4,scaleMin=0.6,scaleMax=4.0
          ,bucketCap=1000,warpTicks=23,showWarp=true
        ,savePersist=true,showCritDetail=true,--[[##]]
      debugBucket=false,}local REF={minWidth=250,cardGap
     =4,pad=10,padY=6,rowGap=4,barHeight=4,stripeW=4,gap=
    14,fontLabel=14,fontValue=22,fontSub=13,gripSize=14,--
    }local COL={bg={14,15,19,225},bgInner={26,28,34,255}--
   ,track={48,52,62,255},label={156,163,178,255},value={236
   ,239,245,255},good={118,226,138,255},warn={246,190,92,--
   255},idle={108,116,132,255},warp={96,168,250,255},edit={
   250,210,100,255},}local function clamp(v,lo,hi)if v<lo--
   then--[[]]            return--[[]]            lo end--##
   if--[[#]]              v>hi--[[]]              then--###
   return hi              end return              v end--##
   --[[####]]            local--[[#]]            function--
    clamp01(v)return clamp(v,0,1)end local function--[[#]]
    setColor(c)draw.Color(c[      1],c[2],c[3],c[4])end--#
     local function--[[##]]        n0(v)return string.--#
      format("%.0f",v or 0)end local function S(v)--[[]]
       local r=math.floor(v*CONFIG.scale+0.5)if r<1--##
          --[[###]]  --[[###]]  --[[###]]  then r=--
          1--[[##]]  end--[[]]  --[[###]]  return--#
          r--[[##]]  end local  --[[###]]  --[[###]]
            function convarNumber(name,fallback)if
               client==nil or client.--[[####]]

                  GetConVar==nil then return
             fallback end local ok,raw=pcall(--##
          client.GetConVar,name)if not ok then--[[]]
        return fallback end local v=tonumber(raw)if--#
      v==nil or v<=0 then return fallback end return v--
     end local function convarInt(name,fallback)if client
    ==nil or client.GetConVar==nil then return fallback--#
    end local ok,raw=pcall(client.GetConVar,name)if not ok
   then return fallback end local v=tonumber(raw)if v==--##
   nil then return fallback end return v end local--[[###]]
   fontCache={}local function getFont(px,weight)px=math.--#
   floor(px+0.5)if px<8 then px=8 end local key=px.."_"..--
   --[[####]]            weight local            f=--[[##]]
   fontCache              [key--[[]]              ]if not f
   --[[###]]              then--[[]]              f=draw.--
   --[[####]]            --[[######]]            --[[####]]
    CreateFont("Verdana",px,weight)fontCache[key]=f end--#
    return f end local--[[]]      function fonts()return--
     getFont(S(REF.--[[##]]        fontLabel),900),--[[]]
      getFont(S(REF.fontValue),900),getFont(S(REF.--[[]]
       fontSub),700)end local function textW(font,s)--#
          if s==nil  or--[[#]]  s==""then  return--#
          0--[[##]]  end draw.  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            SetFont(font)local w=draw.GetTextSize(
               s)return w or 0 end local--[[#]]

                  function metrics()local--#
             labelH=S(REF.fontLabel)local valueH=
          S(REF.fontValue)local subH=S(REF.fontSub--
        )local padY=S(REF.padY)local rowGap=S(REF.--##
      rowGap)local barH=S(REF.barHeight)local topH=math.
     max(labelH,valueH)return{padY=padY,barH=barH,topH=--
    topH,labelY=padY+math.floor((topH-labelH)/2),valueY=--
    padY,subY=padY+topH+rowGap,height=padY+topH+rowGap+--#
   subH+padY+barH,}end local function layoutPath()if--[[#]]
   type(io)~="table"or type(io.open)~="function"then return
   nil end local dir=engine.GetGameDir()if dir==nil or--###
   dir==""then return nil end return dir..--[[###########]]
   --[[####]]            --[[######]]            --[[####]]
   --[[###]]              --[[####]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    "/crit_hud_layout.txt"end local function saveLayout(--
    )if not CONFIG.--[[###]]      savePersist then--[[##]]
     return end local--[[]]        p=layoutPath()if not p
      then return end local f=io.open(p,"w")if not f--##
       then return end f:write(string.format(--[[####]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            "x=%.0f\ny=%.0f\nscale=%.4f\n",CONFIG.
               x,CONFIG.y,CONFIG.scale))f:--###

                  close()end local--[[####]]
             function loadLayout()local p=--[[#]]
          layoutPath()if not p then return end local
        f=io.open(p,"r")if not f then return end for--
      line in f:lines()do local k,v=line:match(--[[###]]
     "^(%w+)=(-?[%d%.]+)$")if k=="x"then CONFIG.x=--[[#]]
    tonumber(v)or CONFIG.x elseif k=="y"then CONFIG.y=--##
    tonumber(v)or CONFIG.y elseif k=="scale"then CONFIG.--
   scale=clamp(tonumber(v)or 1.0,CONFIG.scaleMin,CONFIG.--#
   scaleMax)end end f:close()end local function--[[######]]
   clampToScreen(w,h)local sw,sh=draw.GetScreenSize()if not
   sw or not sh or sw<=0 or sh<=0 then return end CONFIG.x=
   --[[####]]            clamp(CONFIG            .x,0,math.
   max(0,sw-              w))CONFIG.              y=--[[#]]
   --[[###]]              --[[####]]              clamp(--#
   CONFIG.y,0            ,math.max(0,            sh-h))--##
    end local CRITMULT_MAX=4.0 local function--[[#######]]
    isMeleeWeapon(wpn)if wpn      .IsMeleeWeapon~=nil then
     local ok,v=--[[#####]]        pcall(wpn.--[[######]]
      IsMeleeWeapon,wpn)if ok and v~=nil then return v==
       true end end if wpn.GetLoadoutSlot~=nil then--##
          local ok,  --[[###]]  --[[###]]  slot=--##
          pcall(wpn  .--[[##]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            GetLoadoutSlot,wpn)if ok and slot~=nil
               then return slot==2 end end--###

                  return false end local--##
             function isCritBoosted(player)if--##
          player.IsCritBoosted==nil then return--###
        false end local ok,v=pcall(player.--[[######]]
      IsCritBoosted,player)return ok and v==true end--##
     local function CritChance(player)if not player:--###
    IsValid()or not player:IsAlive()then return end--[[#]]
    local weapon=player:GetPropEntity("m_hActiveWeapon")if
   not weapon or not weapon:IsValid()then return end return
   weapon:GetCritChance()end local function--[[##########]]
   randomCritsEnabled(melee)local global=convarInt(--[[##]]
   "tf_weapon_criticals",1)~=0 if not melee then return--##
   global end            local--[[#]]            m=--[[##]]
   --[[###]]              convarInt(              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    "tf_weapon_criticals_melee",1)if m==0 then return--###
    false end if m>=2--[[#]]      then return true end--##
     return global--[[###]]        end local function--##
      ceilEps(v)local r=math.ceil(v-1e-6)if r<0 then--##
       return 0 end return r end local SIM_MAX=99 local
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            function simulateCrits(bucket,--[[##]]
               netCostFn)local b,n=bucket,0--##

                  while n<SIM_MAX do local--
             net=netCostFn(b,n)if not net or--###
          net<=0 or b<net then return n,b,net end b=
        b-net n=n+1 end return n,b,nil end local--[[]]
      depositSeen={}local function observeDeposit(wpn,--
     bucket,cap)local idx=wpn:GetIndex()local def=wpn:--#
    GetPropInt("m_iItemDefinitionIndex")or-1 local d=--###
    depositSeen[idx]if d==nil or d.def~=def then--[[####]]
   depositSeen[idx]={def=def,last=bucket,size=nil}return--#
   nil end local delta=bucket-d.last d.last=bucket if delta
   >0 and bucket<cap then d.size=delta end return d.size--#
   end local function critInfo(player,wpn)local melee=--###
   --[[####]]            --[[######]]            --[[####]]
   --[[###]]              --[[####]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    isMeleeWeapon(wpn)if melee and wpn:GetClass()==--[[#]]
    "CTFKnife"then--[[####]]      return{backstab=true}end
     if not wpn:--[[#####]]        CanRandomCrit()then--#
      return nil end if not randomCritsEnabled(melee)--#
       then return{disabled=true,melee=melee}end if--##
          --[[###]]  --[[###]]  --[[###]]  melee--##
          --[[###]]  --[[###]]  --[[###]]  then--###
          --[[###]]  --[[###]]  --[[###]]  local--##
            nextCrit=player:GetPropInt("m_Shared",
               "m_iNextMeleeCrit")if nextCrit==

                  2 then return{melee=true--
             ,guaranteed=true}end end local--[[]]
          bucket=wpn:GetCritTokenBucket()local base=
        wpn:GetWeaponBaseDamage()if not(bucket and--##
      base)or base<=0 then if melee then return{melee=--
     true,chanceOnly=true,chance=CritChance(player)}end--
    return nil end local bucketCap=convarNumber(--[[####]]
    "tf_weapon_criticals_bucket_cap",CONFIG.bucketCap)--##
   local measured=observeDeposit(wpn,bucket,bucketCap)local
   deposit=measured or base local req=wpn:--[[###########]]
   GetCritSeedRequestCount()or 0 local chk=wpn:--[[######]]
   GetCritCheckCount()or 0 if melee then local gross=--[[]]
   deposit*3*            0.5 if gross            <=0 then--
   --[[###]]              return nil              end local
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            function--
    netCost(b,k)local ok,c=pcall(wpn.GetCritCost,wpn,b,req
    +k,chk+k)if ok and c and      c>0 then return c end--#
     return gross-math.min(        deposit,math.max(0,--#
      bucketCap-b))end local have,stopBal,stopCost=--###
       simulateCrits(bucket,netCost)local maxHave=math.
          max(have,  (--[[##]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            simulateCrits(bucketCap,netCost)))--##
               local progress=(stopCost and--##

                  stopCost>0)and clamp01(--#
             stopBal/stopCost)or 1 local blocked,
          reason,swingsToRefill=false,nil,nil if--##
        have==0 then blocked,reason=true,--[[#######]]
      "BUCKET LOW"swingsToRefill=ceilEps((netCost(bucket
     ,0)-bucket)/deposit)end return{melee=true,have=have,
    max=maxHave,chance=CritChance(player),swingsToRefill--
    =swingsToRefill,progress=progress,blocked=blocked,--##
   reason=reason,bucket=bucket,cost=netCost(bucket,0),--###
   deposit=deposit,measured=measured~=nil,}end local chance
   =wpn:GetCritChance()local observed=wpn:--[[###########]]
   CalcObservedCritChance()if not(chance and observed)--###
   then--[[]]            return--[[]]            nil end--#
   --[[###]]              local cost              =wpn:--##
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            GetCritCost(            bucket,req
    ,chk)if not cost or cost<=0 then return nil end--[[#]]
    local cap=chance+--[[#]]      0.1 local function--[[]]
     netCost(b,k)local ok,c        =pcall(wpn.GetCritCost
      ,wpn,b,req+k,chk+k)if ok and c and c>0 then return
       c end return cost end local bucketCrits,stopBal,
          stopCost=  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            simulateCrits(bucket,netCost)local--##
               bucketMax=math.max(bucketCrits,(

                  simulateCrits(bucketCap,--
             netCost)))local overBudget=--[[###]]
          observed>=cap local have=overBudget and--#
        0 or bucketCrits local maxHave=math.max(have--
      ,bucketMax)local extraFrac=nil if overBudget and--
     observed>0 then extraFrac=(observed*(1+2*cap))/(cap*
    (1+2*observed))-1 if extraFrac<0 then extraFrac=0--###
    end end local shotsToRefill=nil if bucketCrits==0 then
   shotsToRefill=ceilEps((cost-bucket)/deposit)end local--#
   blocked,reason=false,nil if overBudget then blocked,--##
   reason=true,"OVER BUDGET"elseif bucketCrits==0 then--###
   blocked,reason=true,"BUCKET LOW"end local progress=(--##
   --[[####]]            stopCost and            stopCost>0
   )--[[##]]              and--[[#]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            clamp01(--
    stopBal/stopCost)or 1 return{have=have,max=maxHave,--#
    shotsToRefill=--[[####]]      shotsToRefill,capUsed=--
     clamp01(observed/cap),        extraFrac=extraFrac,--
      progress=progress,blocked=blocked,reason=reason,--
       bucket=bucket,cost=cost,deposit=deposit,measured
          =measured  ~=--[[#]]  nil--[[]]  ,}end--##
          --[[###]]  --[[###]]  --[[###]]  local--##
          --[[###]]  --[[###]]  --[[###]]  warpMax--
            =CONFIG.warpTicks local function--[[]]
               warpAvailable()if warp==nil then

                  return false end local ok,
             fn=pcall(function()return warp.--###
          GetChargedTicks end)return ok and fn~=--##
        nil end local function safeCall(fn,...)if fn==
      nil then return nil end local ok,res=pcall(fn,...)
     if ok then return res end return nil end local--[[]]
    function warpTicks()local ticks=safeCall(warp.--[[##]]
    GetChargedTicks)or 0 if ticks>warpMax then warpMax=--#
   ticks end local frac=(warpMax>0)and clamp01(ticks/--[[]]
   warpMax)or 0 return ticks,warpMax,frac end local--[[##]]
   lastPressTick,lastReleaseTick=nil,nil local wasDown=--##
   false local function pollMouse()local mp=input.--[[###]]
   --[[####]]            GetMousePos(            )local mx=
   --[[###]]              math--[[]]              .floor(mp
   [1]--[[]]              or 0)local              my=math--
   .floor(mp[            2]or 0)local            down=input
    .IsButtonDown(MOUSE_LEFT)and true or false local--[[]]
    pressed,ptick=--[[####]]      input.IsButtonPressed(--
     MOUSE_LEFT)local--[[]]        justPressed if ptick~=
      nil then justPressed=(pressed and ptick~=--[[###]]
       lastPressTick)and true or false if justPressed--
          --[[###]]  --[[###]]  --[[###]]  then--###
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            lastPressTick=ptick end else--[[####]]
               justPressed=down and not wasDown

                  end local released,rtick--
             =input.IsButtonReleased(MOUSE_LEFT--
          )local justReleased if rtick~=nil then--##
        justReleased=(released and rtick~=--[[######]]
      lastReleaseTick)and true or false if--[[########]]
     justReleased then lastReleaseTick=rtick end else--##
    justReleased=wasDown and not down end wasDown=down--##
    return mx,my,down,justPressed,justReleased end local--
   function critSub(ci)if ci.melee then if ci.blocked and--
   ci.swingsToRefill then local s=(ci.swingsToRefill==1)and
   " SWING"or" SWINGS"return"BUCKET LOW   "..n0(ci.--[[##]]
   swingsToRefill)..s end if ci.chance then return string--
   .--[[###]]            --[[######]]            format(--#
   --[[###]]              --[[####]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    "%.0f%% PER SWING",ci.chance*100)end return--[[#####]]
    "BUCKET GATE ONLY"end if      ci.blocked and ci.reason
     =="BUCKET LOW"--[[##]]        and ci.shotsToRefill--
      then local s=(ci.shotsToRefill==1)and" SHOT"or--##
       " SHOTS"return"BUCKET LOW   "..n0(ci.--[[#####]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            shotsToRefill)..s end if ci.blocked--#
               and ci.reason=="OVER BUDGET"then

                  return ci.extraFrac and--#
             string.format(--[[################]]
          "OVER BUDGET   +%.0f%% DMG",ci.extraFrac--
        *100)or"OVER BUDGET"end return"CRIT READY"--##
      end local function buildCards(player,wpn)local--##
     cards={}local ci=critInfo(player,wpn)if ci and ci.--
    backstab then cards[#cards+1]={label="CRITS",value=--#
    "STAB",sub="BACKSTAB ONLY",prog=0,accent=COL.idle,--##
   valCol=COL.value,}elseif isCritBoosted(player)then cards
   [#cards+1]={label="CRITS",value="BOOST",sub=--[[######]]
   "ALL GATES BYPASSED",prog=1,accent=COL.good,valCol=COL--
   .good,}elseif ci and ci.disabled then cards[#cards+1]=--
   {--[[###]]            label=--[[]]            "CRITS",--
   --[[###]]              --[[####]]              value=--#
   "OFF",sub              =ci.--[[]]              melee and
   --[[####]]            --[[######]]            --[[####]]
    "MELEE CRITS OFF (SERVER)"or--[[####################]]
    --[[##################]]      --[[##################]]
     --[[################]]        --[[################]]
      "RANDOM CRITS OFF (SERVER)",prog=0,accent=COL.idle
       ,valCol=COL.idle,}elseif ci and ci.guaranteed--#
          --[[###]]  --[[###]]  --[[###]]  then--###
          --[[###]]  --[[###]]  --[[###]]  cards[#--
          cards+1]=  {--[[##]]  --[[###]]  label=--#
            "CRITS",value="NEXT",sub=--[[#######]]
               "CHARGE CRIT   BYPASSES BUCKET",

                  prog=1,accent=COL.good,--#
             valCol=COL.good,}elseif ci and ci.--
          chanceOnly then cards[#cards+1]={label=--#
        "CRITS",value=ci.chance and string.format(--##
      "%.0f%%",ci.chance*100)or"--",sub=--[[##########]]
     "PER SWING   NO BUCKET DATA",prog=ci.chance and--###
    clamp01((ci.chance-0.15)/0.45)or 0,accent=COL.warp,--#
    valCol=COL.value,}elseif ci then local accent=COL.idle
   if ci.blocked then accent=COL.warn elseif ci.have>0 then
   accent=COL.good end cards[#cards+1]={label="CRITS",value
   =n0(ci.have).." / "..n0(ci.max),sub=CONFIG.--[[#######]]
   showCritDetail and critSub(ci)or"",prog=ci.progress,--##
   --[[####]]            accent--[[]]            =accent,--
   --[[###]]              valCol=(ci              .have>0--
   )and COL.              good--[[]]              or COL.--
   --[[####]]            value,--[[]]            }else--###
    cards[#cards+1]={label="CRITS",value="--",sub=--[[##]]
    "NO RANDOM CRITS",prog=0      ,accent=COL.idle,valCol=
     COL.idle,}end if--[[]]        CONFIG.debugBucket and
      ci and ci.bucket then cards[#cards+1]={label=--###
       "BUCKET",value=n0(ci.bucket).." / "..n0(ci.cost)
          ,--[[##]]  sub--[[]]  =--[[##]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            "DEPOSIT "..n0(ci.deposit)..(ci.--[[]]
               measured and" (MEASURED)"or--###

                  " (ASSUMED)"),prog=--[[#]]
             clamp01(ci.bucket/math.max(ci.cost,1
          )),accent=ci.measured and COL.warp or COL.
        idle,valCol=COL.value,}end if CONFIG.--[[###]]
      showWarp and warpAvailable()then local ticks,--###
     maxTicks,frac=warpTicks()local canWarp=safeCall(warp
    .CanWarp)==true cards[#cards+1]={label="WARP",value=--
    canWarp and"READY"or n0(ticks),sub=n0(ticks).." / "--#
   ..n0(maxTicks).." TICKS",prog=frac,accent=canWarp and--#
   COL.good or COL.warp,valCol=canWarp and COL.good or COL.
   value,}local canDT=safeCall(warp.CanDoubleTap,wpn)==true
   cards[#cards+1]={label="DOUBLE TAP",value=canDT and--###
   --[[####]]            --[[######]]            "READY"--#
   or--[[#]]              "NO"--[[]]              ,sub=--##
   canDT and              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    "CAN DOUBLE TAP"or"WAITING ON CHARGE",prog=canDT and 1
    or 0,accent=canDT--[[#]]      and COL.good or COL.idle
     ,valCol=canDT and COL.        good or COL.idle,}--##
      end return cards end local function--[[#########]]
       measureWidth(cards,fLabel,fValue,fSub)local pad,
          --[[###]]  --[[###]]  --[[###]]  stripe,--
          gap=S(REF  .--[[##]]  pad--[[]]  ),S(REF--
          .stripeW)  ,S(--[[]]  REF--[[]]  .gap)--##
            local need=S(REF.minWidth)for _,c in--
               ipairs(cards)do local topRow=--#

                  textW(fLabel,c.label)+gap+
             textW(fValue,c.value)local subRow=--
          textW(fSub,c.sub)local w=stripe+pad+math--
        .max(topRow,subRow)+pad if w>need then need=--
      w end end return need end local function drawCard(
     x,y,w,m,c,fLabel,fValue,fSub)local stripe,pad=S(REF.
    stripeW),S(REF.pad)local innerX=x+stripe local h=m.--#
    height setColor(COL.bg)draw.FilledRect(x,y,x+w,y+h)--#
   setColor(COL.bgInner)draw.FilledRect(innerX,y+1,x+w-1,y+
   h-1)setColor(c.accent)draw.FilledRect(x,y,innerX,y+h)--#
   draw.SetFont(fLabel)setColor(COL.label)draw.--[[######]]
   TextShadow(innerX+pad,y+m.labelY,c.label)if c.value then
   --[[####]]            local--[[#]]            tw=--[[#]]
   --[[###]]              --[[####]]              textW(--#
   fValue,c.              value)draw              .SetFont(
   --[[####]]            fValue--[[]]            )setColor(
    c.valCol or COL.value)draw.TextShadow(math.floor(x+w--
    -pad-tw),y+m.--[[#####]]      valueY,c.value)end if c.
     sub and c.sub~=--[[#]]        ""then draw.SetFont(--
      fSub)setColor(c.accent)draw.TextShadow(innerX+pad,
       y+m.subY,c.sub)end local by=y+h-m.barH-1--[[##]]
          setColor(  COL.track  )--[[##]]  draw.--##
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            FilledRect(innerX,by,x+w-1,by+m.barH--
               )if c.prog and c.prog>0 then--##

                  local span=(x+w-1)- --[[]]
             innerX local fill=math.floor(span*--
          clamp01(c.prog))setColor(c.accent)draw.--#
        FilledRect(innerX,by,innerX+fill,by+m.barH)end
      end local drag=nil local function handleEdit(px,py
     ,pw,ph)local mx,my,down,justPressed,justReleased=--#
    pollMouse()local grip=S(REF.gripSize)local gx1,gy1=px+
    pw-grip,py+ph-grip local overGrip=mx>=gx1 and mx<=px--
   +pw and my>=gy1 and my<=py+ph local overBody=mx>=px--###
   and mx<=px+pw and my>=py and my<=py+ph if drag then if--
   down then if drag.mode=="move"then local sw,sh=draw.--##
   GetScreenSize()CONFIG.x=clamp(mx-drag.ox,0,math.max(0,--
   (sw or pw)            -pw))CONFIG.            y=clamp(my
   -drag.oy,              0,--[[##]]              math.max(
   0,(--[[]]              sh or ph)-              ph))--###
   else local            newW=--[[#]]            math.--###
    max(20,mx-px)CONFIG.scale=clamp(drag.startScale*(newW/
    drag.startW),--[[#####]]      CONFIG.scaleMin,CONFIG--
     .scaleMax)end--[[###]]        end if justReleased or
      not down then drag=nil saveLayout()end elseif--###
       justPressed then if overGrip then drag={mode=--#
          --[[###]]  --[[###]]  --[[###]]  "scale"--
          ,--[[##]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            startScale=CONFIG.scale,startW=pw}--##
               elseif overBody then drag={mode=

                  "move",ox=mx-px,oy=my-py--
             }end end local hot=(drag~=nil)or--##
          overBody setColor(hot and COL.edit or COL.
        idle)draw.OutlinedRect(px-1,py-1,px+pw+1,py+ph
      +1)local gripHot=(drag~=nil and drag.mode=="scale"
     )or overGrip setColor(gripHot and COL.edit or COL.--
    idle)draw.FilledRect(gx1,gy1,px+pw,py+ph)local--[[##]]
    hintFont=getFont(S(REF.fontSub),700)draw.SetFont(--###
   hintFont)setColor(COL.edit)draw.TextShadow(px,py-S(REF--
   .fontSub)-6,string.format(--[[########################]]
   "DRAG TO MOVE  -  CORNER TO SCALE  -  %.2fx",CONFIG.--##
   scale))end local function onDraw()if engine.--[[######]]
   --[[####]]            --[[######]]            --[[####]]
   --[[###]]              --[[####]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    Con_IsVisible()then return end local editing=gui.--###
    IsMenuOpen()if--[[####]]      engine.IsGameUIVisible()
     and not editing--[[#]]        then return end--[[#]]
      local player=entities.GetLocalPlayer()if not--[[]]
       player or not player:IsAlive()then return end--#
          local wpn  =--[[##]]  --[[###]]  player:--
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            GetPropEntity("m_hActiveWeapon")if not
               wpn or not wpn:IsWeapon()then--#

                  return end local fLabel,--
             fValue,fSub=fonts()local cards=--###
          buildCards(player,wpn)if#cards==0 then--##
        return end local m=metrics()local w=--[[####]]
      measureWidth(cards,fLabel,fValue,fSub)local gap=S(
     REF.cardGap)local totalH=#cards*m.height+(#cards-1)*
    gap clampToScreen(w,totalH)local x,y=math.floor(CONFIG
    .x),math.floor(CONFIG.y)for i,c in ipairs(cards)do--##
   drawCard(x,y+(i-1)*(m.height+gap),w,m,c,fLabel,fValue,--
   fSub)end if editing then handleEdit(x,y,w,totalH)end end
   loadLayout()callbacks.Register("Draw","crit_hud_draw",--
   onDraw)--[[###########################################]]
   --[[####]]            --[[######]]            --[[####]]
   --[[###]]              --[[####]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    --[[################################################]]
    --[[##################]]      --[[##################]]
     --[[################]]        --[[################]]
      --[[############################################]]
       --[[##########################################]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            --[[################################]]
               --[[##########################]]
