LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}
local LFI = LibFloatingIcons.internal


LFI.interface = {}
local Interface = LFT.interface 



--[[ Icon Templates ]] 

local libraryIconTemplateDefault = {
    texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", 
    width = 0, 
    height = 0, 
    hidden = true,
    color = {1,1,1}, 
    offsetX = 0,
    offsetY = 0,
}

function Interface:DefineIconTemplate( name, opt )
    opt = opt or {}
    self.iconTemplates[name] = opt 
    setmetatable(self.iconTemplates[name], {__index = libraryIconTemplateDefault } ) 
end


function Interface:GetIconTemplate( name ) 
    return self.iconTemplates[name] or libraryIconTemplateDefault
end
 


--[[ Exposed Functions ]]


function Interface:AddPositionObject( name, objData, iconSettings ) 

    local objType = "position"

    local obj = LFI.objectPool:RetrieveObject( objType )
    obj:Initialize( self, name, objData, iconSettings ) --- apply icon template, apply defaults settings
    

end






function LibFloatingIcons:RegisterHandler( handlerName ) 

    --- early outs 
    if not LFI.initialized then -- library not properly initialized 
        LFI.debugMsg({"Error", "red"}, zo_strformat("Handler Registration: <<1>> attempted before LFI initialize", LFI.util.ColorString(handlerName, "orange") ) )
        return 
    end 

    if LFI.interfaceVault[handlerName] then -- duplicate handlerName
        LFI.debugMsg({"Error", "red"}, zo_strformat("Duplicate Handler Registration: <<1>>", LFI.util.ColorString(handlerName, "orange") ) )
        return 
    end

    local Handler = {}
    setmetatable( Handler, {__index = Interface } )
    Handler.name = handerName 

    Handler.iconTemplates = {}

end 








--- RegisterForZoneActivation() 
--- UnregisterForZoneActivation() 
