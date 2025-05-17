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
    ["handler"] = "handler list or specific handler data"
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
      if LFI.interfaceVault[ param[1] ] then 
        d( zo_strformat("[<<1>>] handler <<2>> overview:", CStr("LibFloatingIcons", "cyan"), CStr(param[1], "orange") ) ) 
        -- objDefaults (position, unit) 
        -- iconTemplates  
        -- list of objects 
        Divider()
      else 
        d( zo_strformat("[<<1>>] handler <<2>> does not exist", CStr("LibFloatingIcons", "cyan"), CStr(param[1], "orange") ) ) 
      end
    end
  end
end

