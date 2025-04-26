LibFloatingIcons = LibFloatingIcons or {}
LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal
LFI.util = LFI.util or {}
local Util = LFI.util


local function PrintBool( var, colorCoded) 
  local str = var and "true" or "false" 
  if colorCoded then 
    return Util.ColorString(str, var and "green" or "red") 
  else 
    return str
  end
end


--[[ ------------------- ]]
--[[ -- Chat Command  -- ]]
--[[ ------------------- ]]

local cmdList = {
    ["registry"] = "list of the equipped set-pieces for each equipment slot",
    ["renderlist"] = "prints overview of render-list"

  }
  
 
  
SLASH_COMMANDS["/lfi"] = function( input ) 
    local LFI = LibFloatingIcons.internal
    local Util = LFI.util

    ---deserializ input 
    input = string.lower(input) 
    local param = {}
    for str in string.gmatch(input, "%S+") do
      table.insert(param, str)
    end
  
    local cmd = table.remove(param, 1) 
    
    if not cmd or cmd == ""  then 
      d( zo_strformat("[<<1>>] <<2>>", Util.ColorString("LibFloatingIcons", "cyan"), "command overview") ) 
      for cmdName, cmdInfo in pairs( cmdList ) do 
        d( zo_strformat("<<1>> - <<2>>", Util.ColorString(cmdName, "cyan"), cmdInfo) )
      end
      d("--------------------")
    elseif cmd == "renderlist" then 
      local renderList = {}
      if param[1] == "position" then 
        renderList = LFI.positionIcon.renderList 
      end
      local num = 0 
      for _,_ in pairs(renderList) do 
        num = num + 1 
      end
      LFI.debugMsg("Dev", zo_strformat("RenderList for <<1>> with <<2>> objects:", 
        Util.ColorString(param[1].."Icons", "orange"),
        Util.ColorString(num, "white") ) )
      for _,obj in pairs(renderList) do 
          d( zo_strformat("<<1>> (sn=<<2>>) from <<3>>", obj.name, obj.sn, obj.handlerName)  )
      end
      d( Util.ColorString("--------------------------------------------------", "gray") )

    elseif cmd == "registry" then 
      local registry = {}
      if param[1] == "position" then 
        registry = LFI.positionIcon.registry 
      end  
      LFI.debugMsg("Dev", zo_strformat("Registry for <<1>>:", Util.ColorString(param[1].."Icons", "orange")))
      for zone, subRegistry in pairs(registry) do 
        local num = 0 
        for _,_ in pairs(subRegistry) do 
          num = num + 1 
        end
        d( zo_strformat("SubRegistry for <<1>> (id=<<2>>) with <<3>> objects", 
        Util.ColorString(GetZoneNameById(zone), "orange"), zone, Util.ColorString(num, "white") ) )
        for _,obj in pairs(subRegistry) do 
          d( zo_strformat(".     <<1>> (sn=<<2>>) from <<3>> (enabled=<<4>>,  hidden=<<5>>) ", 
          Util.ColorString(obj.name, "orange"), obj.sn, Util.ColorString(obj.handlerName, "white"), 
          PrintBool(obj.enabled, true), PrintBool( obj.rootCtrl:IsHidden(), true)  ) )
        end
      end
      d( Util.ColorString("--------------------------------------------------", "gray") )
    end
  end