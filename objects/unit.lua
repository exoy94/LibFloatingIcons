LibFloatingIcons = LibFloatingIcons or {}

LibFloatingIcons.internal = LibFloatingIcons.internal or {}

local LFI = LibFloatingIcons.internal

local WM = GetWindowManager()


LibFloatingIcons.internal.unitObjects = {}
local UnitObjects = LibFloatingIcons.internal.unitObjects

function UnitObjects:CreateMasterControls() 
    local name = "LFI_UnitMasterCtrl_"

    local masterCtrls = { }

    local function _CreateControl( unit )
        local ctrl = WM:CreateControl( name..unit, LFI.window, CT_CONTROL) 
        ctrl:ClearAnchors() 
        ctrl:SetAnchor( BOTTOM, LFI.window, CENTER, 0, 0) 
        ctrl:SetHidden(true)              
        
        masterCtrls[unit] = ctrl
    end

    _CreateControl( "player" )
    _CreateControl( "companion" )

    for ii = 1,GROUP_SIZE_MAX do 
        local tag = "group"..tostring(ii) 
        _CreateControl( tag ) 
    end 

    for ii = 1,MAX_PET_UNIT_TAGS do 
        local tag = "playerpet"..tostring(ii) 
        _CreateControl( tag ) 
    end

    self.masterCtrls = masterCtrls
    self.renderList = masterCtrls
end

function UnitObjects:AddToRenderList( unit ) 

end

function UnitObjects:RemoveFromRenderList() 

end


