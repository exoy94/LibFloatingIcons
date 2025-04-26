-- ExoY Addon Discord Server: 
-- https://discord.com/invite/MjfPKsJAS9


--[[ General idea of LFI ]]

-- The motivation of LibFloatingIcons is to move the widely used capabilities of OdySupportIcons in a standalone library. 
-- This way I can optimize for usage by multiple parties and seperate adding some new features to OSI and working on the 
-- performance of LFI. This will also bring the option for icons to console with u46. (Maybe there will also be a console version
-- of OSI at some point, but I dont know yet). 

--- Main focus of this library is: 
-- 1. easy to use api, if you just want to use the lib the same way you use OSI now 
-- 2. enable much more flexibility for individual tasks beyong the current capabilities of OSI (e.g. animations, moving icons)
-- 3. as now multiple addons can display icons above units, this library will be the common ground to enable a nice user experience 
-- 4. as soon as the api is established, i will focus of further increasing performance 


--[[ Version 0.2 - Position Icons ]]
-- The library is in its early stages. While I am still working on the part to display icons above units, the part to place icons 
-- at specific locations in the world is already progressed nicely. I am looking for feedback for: 
-- 1. is there functionality missing (what were you trying to do)? 
-- 2. how intuitive the api is to use 
-- 3. bug reports or unexpected behavior  


--[[ Example for LFI ]]

-- Start by Registering a handler, 
-- e.g.: 

local name = "lfi_example"
local lfiHandler = LibFloatingIcons:RegisterHandler( "lfi_example" )  

-- @param name has to be unique and should indicate by which library/addon the handler was created 

--- Why do I need a handler?  
-- The handler is how i decided to expose the api to create icons. 
-- It enables intuitive api to use individual templates/default settings 
-- It will play a crucial role for the icons above units to work properly. 
-- (That part of the library is still under development. I provide a few more information on my discord) 
-- It will allow to evaluate, which addon outs how much strain on a client, if they experience performance issues due to too many icons. 


--[[ PositionObject ]]
-- The positionObject is a more sophisticated way to place controls in the world with many functionality 
-- The provided object includes a "root"-control, that will be render at the speicified location as are the position icons by OSI 
-- The user can anchor more controls to this root to display whatever they want. 
-- Objects can be define in advance and then enabled/disabled when needed 
--- It is recommended to define icons in advance, especially if multiple objects have to be created simultaneously during a fight. 
-- Objects can be repurposed by changing the attributes. 


--[[ Simple Usecase ]]
-- The simple use case basically is how OSI is used atm. 
-- For that every obj already contains one texture control by default to display an icon. 
-- The Syntax to create a icon (ex: Icon in the entrance are of the "Haven of the five companions")

local objectName = "simpleIcon"
-- name that must be unique for all position objects by the same handler 
local zoneId = 1495
-- zone the icon is to be displayed in 
local objectSettings = {x = 56079, y=30974, z=71492, offset = 100, enabled = true} 
-- (optional) table to define coordinates and offset. "enabled = true" means it will be rendered when in the zone
local iconSettings = {texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", width = 50, height = 50, color = {1,1,1}} 
-- (optional) table to define the icon 

--- see: /objects/position.lua 
-- for all properties that can be put into the object and icon settings 

lfiHandler:AddPositionObject( objectName, zoneId, opjectSettings, iconSettings)

lfiHandler:AddPositionObject( "simpleIcon", 1495, {x = 56079, y=30974, z=71492, offset = 100, enabled = true}, {texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", width = 50, height = 50})


--[[ defaults and templates ]]

--- object settings
-- as stated above, this parameter is optional and also nilable and will be completed using the concept of inheritance

-- instead of defining the "objectSettings" each time, a default can be set using: 
lfiHandler:SetPositionObjectDefaults( defaults )

-- @param defaults has to be a table with objectSettings. 
-- important: this table does not have to be complete. There exist an internal default table within the library. 
-- Each object inherits from the handler defaults, and the hander inherites from the library defaults. 

-- This means: 
-- for a setting that was not provided, it will automatically take the setting defined in the handlers default. 
-- if the handler default does not provide anything, the library default will be used. 
--- Warning: in the current implementation, changing the handlers default should (in theory) impact all icons retrospectively, which are using the handlers default values. 

-- so, if i always want to have my object be rendered with an offset of 100 and being enabled i can use: 
lfiHandler:SetPositionObjectDefaults( {offset = 100, enabled = true}) 


--- icon settings 
-- a similar concept applies to the icon settings,for icons there can be templates defined. The general working principle is almost identifcal to the object defaults. 
-- The main difference is, that changes to a template will not effect already exsiting objects. This is due to how attributes are applied to the userdata of a control.  

-- so i can define myself a template  with the name "iconTemplate" so that my icon always has a specific widht and height 
lfiHandler:DefineIconTemplate( "exmplTemplate", {width = 50, height = 50})
-- again, every attribute not provided in a template will use the libraries default value 

--- now I can create the same objects just with: 
lfiHandler:AddPositionObject( "simpleIcon2", 1495, {x = 56079, y=30974, z=71492}, {texture = "/esoui/art/icons/achievement_u30_groupboss6.dds", template = "exmplTemplate"})
-- the syntax improvements may not seem like much, but depending on the usecase this can significantly simplify your code 


--[[ advanced use cases ]]

local exmplObj = lfiHandler:AddPositionObject( "advancedUse", 1495 )
-- instead of just using the default icon control, you can use the positionObj directly. 
-- with the object you can change all attributes at will
-- you can access the existing controls, e.g.  
exmplObj:GetControl("rootCtrl") 
--- or 
exmplObj:GetCOntrol("icon")

-- you can create new controls, which will be anchored to the root control 
local label = exmplObj:CreateControl("label", CT_LABEL)
--- or 
exmplObj:CreateControl("label", CT_LABEL)
local label = exmplObj:GetControl("label") 


--- other functions of the object are 
exmplObj:SetCtrlOffset( ctrlName, offsetX, offsetY ) 
exmplObj:Enable() 
exmplObj:Disable() 
-- and probably more to come. 
-- Note: The CreateControl and SetControlOffset are provided, so the controls are always anchored 
-- to the correct parent to be rendered properly. 
