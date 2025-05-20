LibFloatingIcons = LibFloatingIcons or {}
LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal
LFI.util = LFI.util or {}
local Util = LFI.util


local function PrintBool( var, colorCoded, negatory) 
  local str = var and "true" or "false" 
  if colorCoded then 
    if negatory then
      return Util.ColorString(str, var and "red" or "green") --negatory = true --> true is red, false is green
    else 
      return Util.ColorString(str, var and "green" or "red") --negatory = false --> true is green, false is red
    end
  else 
    return str
  end
end

local function Divider() 
  d( Util.ColorString("--------------------------------------------------", "gray") )
end


--[[ ------------------- ]]
--[[ -- Chat Command  -- ]]
--[[ ------------------- ]]

local cmdList = {
    ["pool"] = "objectPool data summary",
    ["handler"] = "handler list or specific handler data",
    ["render"] = "prints information about the currently rendered (and buffered) objects",
    ["position"] = "prints position of specified unitTag (default = player)",
  }
  
SLASH_COMMANDS["/lfi"] = function( input ) 
  local LFI = LibFloatingIcons.internal
  local Util = LFI.util
  local CStr = LFI.util.ColorString

  ---deserializ input 
  --input = string.lower(input) 
  local param = {}
  for str in string.gmatch(input, "%S+") do
    table.insert(param, str)
  end

  local cmd = string.lower( table.remove(param, 1) )
  
  if not cmd or cmd == ""  then 
    d( zo_strformat("[<<1>>] <<2>>", CStr("LibFloatingIcons", "cyan"), "command overview") ) 
    for cmdName, cmdInfo in pairs( cmdList ) do 
      d( zo_strformat("<<1>> - <<2>>", CStr(cmdName, "cyan"), cmdInfo) )
    end
    Divider()
  elseif cmd == "pool" then 
    d( zo_strformat("[<<1>>] <<2>>", CStr("LibFloatingIcons", "cyan"), "objectPool data") ) 
    d( zo_strformat("<<1>> counter: <<2>>; stored: <<3>>", CStr("PositionObjects", "orange"), CStr(tostring(LFI.objectPool["position"].objCounter ), "white"), CStr(tostring(#LFI.objectPool["position"].objects ), "white") ) )
    d( zo_strformat("<<1>> counter: <<2>>; stored: <<3>>", CStr("UnitObjects", "orange"), CStr(tostring(LFI.objectPool["unit"].objCounter ), "white"), CStr(tostring(#LFI.objectPool["unit"].objects ), "white") ) )
    Divider()
  elseif cmd == "handler" then 
    if not param[1] then 
      -- list of all existing handler and their current obj amounts 
      d( zo_strformat("[<<1>>] <<2>>", CStr("LibFloatingIcons", "cyan"), "handler list") ) 
      for name, Interface in pairs(LFI.interfaceVault) do 
        local numPosObj = 0 
        for _,_ in pairs(Interface.objectVault.position) do 
          numPosObj = numPosObj+1
        end
        local numUnitObj = 0 
        for _,_ in pairs(Interface.objectVault.unit) do 
          numUnitObj = numUnitObj+1
        end
        d( zo_strformat("<<1>>: positionObj: <<2>>; unitObj: <<3>>", CStr(name, "orange"), CStr(tostring(numPosObj), "white"), CStr(tostring(numUnitObj), "white") ) )
      end
    else  

      --- debug for a specific handler (interface) 
      if LFI.interfaceVault[ param[1] ] then 
        d( zo_strformat("[<<1>>] handler <<2>> overview:", CStr("LibFloatingIcons", "cyan"), CStr(param[1], "orange") ) ) 
        local Interface = LFI.interfaceVault[ param[1] ]
        
        --- detailed debug for specific aspects of the handler
        if param[2] then 
          --- list of all icon templates
          if param[2] == "templates" then
            d( zo_strformat("[<<1>>] handler <<2>> - <<3>>", CStr("LFI", "cyan"), CStr(param[1], "orange"), CStr("icon templates", "white") ) ) 
            for name, template in pairs(Interface.iconTemplates) do 
              d( zo_strformat("-- (Template) <<1>> --", CStr(name, "orange") ) )
              local meta = getmetatable(template) 
              for key, _ in pairs(meta) do 
                d( zo_strformat("<<1>>: <<2>>", CStr(key, "white"), template[key] ) )
              end
            end
          --- information about the position objects
          elseif param[2] == "position"  then 
            -- default settings 
            d("position vault")
            local vault = Interface.objectVault.position 
            d(vault)
            
          elseif param[2] == "unit" then 
            d("unit vault")
            local vault = Interface.objectVault.unit 
            d(vault)

          end
        
        --- general information about the handler
        else 

        end
      else 
        d( zo_strformat("[<<1>>] handler <<2>> does not exist", CStr("LibFloatingIcons", "cyan"), CStr(param[1], "orange") ) ) 
      end
    end

  --- prints information about the currently rendered (and buffered) objects
  elseif cmd == "render" then
    d( zo_strformat("[<<1>>] <<2>>", CStr("LibFloatingIcons", "cyan"), "render overview") ) 
    
    -- renderlist of position objects
    d( zo_strformat("-- <<1>> --", CStr("Renderlist (Position)", "orange") ) )
    for _, obj in pairs( LFI.positionHandler.render ) do 
      d( zo_strformat("<<1>>: {x,y,z} = {<<2>>, <<3>>, <<4>>}; hidden: <<5>>", CStr(obj.name, "orange"), CStr(obj.data.x, "white"), CStr(obj.data.y, "white"), CStr(obj.data.z, "white"), PrintBool( obj.rootCtrl:IsHidden(), true, true) ) )
    end

    -- bufferlist of position objects
    d( zo_strformat("-- <<1>> --", CStr("Bufferlist (Position)", "orange") ) )
    for _, obj in pairs( LFI.positionHandler.buffer ) do 
      d( zo_strformat("<<1>>: {x,y,z} = {<<2>>, <<3>>, <<4>>}; hidden: <<5>>", CStr(obj.name, "orange"), CStr(obj.data.x, "white"), CStr(obj.data.y, "white"), CStr(obj.data.z, "white"), PrintBool( obj.rootCtrl:IsHidden(), true, true) ) )
    end

    -- of unit master objects 
    d( zo_strformat("-- <<1>> --", CStr("Renderlist (Unit - MasterCtrl)", "orange") ) )
    local str = ""
    for unit,_ in pairs( LFI.unitHandler.render ) do 
      str = zo_strformat("<<1>>, <<2>>", str, unit )
    end

  
  --- prints position of specified unitTag (default = player)
  elseif cmd == "position" then
    local unit = param[1] or "player"
    if not DoesUnitExist(unit) then 
      d( zo_strformat("[<<1>>] position print: invalid unit (<<2>>)", CStr("LFI", "cyan"), CStr(unit,"white")) )
    else 
      local zone, wX, wY, wZ = GetUnitRawWorldPosition( unit )
      local str = zo_strformat("[<<1>>] Position of <<2>> (<<3>>) in <<4>> (<<5>>)", CStr("LFI", "cyan"), CStr(GetUnitName(unit), "orange"), CStr(unit, "white"), CStr(GetZoneNameById(LFI.zone),"orange"), CStr(LFI.zone, "white") )
      d( zo_strformat("<<1>> at {x,y,z} = {<<2>>, <<3>>, <<4>>}", str, CStr(tostring(wX), "white"), CStr(tostring(wY), "white"), CStr(tostring(wZ), "white")) )
    end
  end
end

