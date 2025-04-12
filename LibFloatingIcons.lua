LibFloatingIcons = LibFloatingIcons or {}

local LFI = LibFloatingIcons

local EM = GetEventManager() 
local WM = GetWindowManager()
 











--[[ ---------------- ]]
--[[ -- Initialize -- ]] 
--[[ ---------------- ]]

local function Initialize() 
    
end

local function OnAddonLoaded(_, addonName) 
    if addonName == idLFI then 
        Initialize()
        EM:UnregisterForEvent(idLFI, EVENT_ADD_ON_LOADED)
    end
end

EM:RegisterForEvent(idLFI, EVENT_ADD_ON_LOADED, OnAddonLoaded)

