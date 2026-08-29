--===============================================================
--
-- Projectile Aim Loader / Auto-Updater
-- Beta 2
-- 8/23/2026 17:27
--
-- # Discord
-- @ purrspire
--
-- # GitHub
-- @ NoStir
--
-- # Lbox forums
-- @ TimLeary
--===============================================================

                  local NAME=--[[#########]]
             "Projectile-Aim"local URL=--[[####]]
          --[[####################################]]
        --[[########################################]]
      --[[############################################]]
     --[[##############################################]]
    --[[################################################]]
    --[[################################################]]
   --[[##################################################]]
   --[[##################################################]]
   --[[##################################################]]
   --[[##################################################]]
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

"https://gist.githubusercontent.com/NoStir/0360c5e1bd5ea49e3ed59c4a9e7516ab/raw/Lua-Aim.lua"
                  local CACHE=--[[########]]
             "Projectile-Aim.cache.lua"local--###
          MIN_BYTES=100000 local ATTEMPTS=3 local--#
        load=load or loadstring local function log(fmt
      ,...)print(("[%s] "..fmt):format(NAME,...))end--##
     local SELF=GetScriptName()local function--[[######]]
    transportError(s)if not s or#s==0 then return--[[###]]
    "empty response"end if s:match("^ERROR_%w+:")then--###
   return s:sub(1,120)end if s:match("^%d%d%d: ")then--[[]]
   return s:sub(1,120)end if s:find("^%s*<")then return--##
   "HTML error page"end if#s<MIN_BYTES then return(--[[##]]
   "only %d bytes"):format(#s)end return nil end local--###
   --[[####]]            --[[######]]            PAYLOAD=--
   nil local              --[[####]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            function--
    run(src,origin)local chunk,err=load(src,"@"..NAME)if--
    not chunk then--[[####]]      log(--[[##############]]
     --[[################]]        --[[################]]
      "compile error from %s: %s",origin,err)return--###
       false end local ok,ret=pcall(chunk)if not ok--##
          then log(  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            "runtime error from %s: %s",origin,ret
               )return false end PAYLOAD=(type(

                  ret)=="table")and ret or--
             nil log(--[[######################]]
          "loaded from %s (%d bytes)%s",origin,#src,
        (PAYLOAD and type(PAYLOAD.Unload)=="function")
      and""or"  [WARN: no M.Unload - rebuild dist]")--##
     return true end local function teardown(why)if--[[]]
    PAYLOAD and type(PAYLOAD.Unload)=="function"then local
    ok,err=pcall(PAYLOAD.Unload)if ok then log(--[[#####]]
   "payload torn down (%s)",why)else log(--[[############]]
   "payload teardown FAILED (%s): %s",why,tostring(err))end
   else log(--[[#########################################]]
   --[[##################################################]]
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

"no payload teardown available (%s) - callbacks may survive"
                  ,why)end PAYLOAD=nil end--
             local function loadCached()local f--
          =io.open(CACHE,"rb")if not f then log(--##
        --[[########################################]]
      "no cached copy at %s - nothing to fall back to"--
     ,CACHE)return false end local src=f:read("*a");f:--#
    close()return run(src,"cache")end local function--[[]]
    fetch()for i=1,ATTEMPTS do local ok,src=pcall(http.Get
   ,URL)if ok then local bad=transportError(src)if not--###
   bad then return src end log("attempt %d/%d failed: %s",i
   ,ATTEMPTS,bad)else log("attempt %d/%d threw: %s",i,--###
   ATTEMPTS,tostring(src))end end return nil end log(--[[]]
   --[[####]]            --[[######]]            --[[####]]
   --[[###]]              --[[####]]              --[[###]]
   --[[###]]              --[[####]]              --[[###]]
   --[[####]]            --[[######]]            --[[####]]
    "script file is %s  (UnloadScript target)",tostring(--
    SELF))local src=--[[##]]      fetch()if not src then--
     log(--[[############]]        --[[################]]
      "all fetch attempts failed, trying cache")--[[##]]
       loadCached()return end if not run(src,"remote"--
          )--[[##]]  then log(  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
          --[[###]]  --[[###]]  --[[###]]  --[[###]]
            --[[################################]]
               --[[##########################]]

                  --[[####################]]
             --[[##############################]]
          "remote copy did not run, trying cache")--
        loadCached()return end local f=io.open(CACHE--
      ,"wb")if f then f:write(src);f:close()else log(--#
     "warning: could not write cache to %s",CACHE)end--##
    callbacks.Register("Unload","LuaAim_loader_teardown"--
    ,function()teardown("script unload")end)--[[########]]
   --[[##################################################]]
   --[[##################################################]]
   --[[##################################################]]
   --[[##################################################]]
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

