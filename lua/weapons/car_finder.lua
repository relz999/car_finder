AddCSLuaFile()


if(SERVER) then
	util.AddNetworkString("carstuff")
	util.AddNetworkString("SetPos")
end

if(CLIENT) then
	SWEP.PrintName = "Car Finder"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	isPopupActive = false
end

SWEP.Author = "Relman"
SWEP.Instructions = "Click Left mouse to see table of cars, click a row to teleport"
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.AnimPrefix = "python"
SWEP.Sound = Sound("weapons/deagle/deagle-1.wav")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetWeaponHoldType(self.IdleStance)
end	

function SWEP:PrimaryAttack()
if (SERVER) then
	local entities = ents.GetAll()
	local i = 0
	CarTable = {}
	for k ,v in pairs(entities) do
		if v:IsVehicle(v) then
			CarTable[i] = v
			i = i + 1
		end
	end
	
	if istable(CarTable) then
		net.Start("carstuff")
		net.WriteTable(CarTable)
		net.Broadcast()
	end
end

if (CLIENT) then
	net.Receive("carstuff", function()
	carList = net.ReadTable()
end)

if isPopupActive == false then
local f = vgui.Create( "DFrame" )
f:SetSize( 500, 500 )
f:Center()
f:MakePopup()
isPopupActive = true

f.OnClose = function()
isPopupActive = false
end

local AppList = vgui.Create( "DListView", f )
AppList:Dock( FILL )
AppList:SetMultiSelect( false )
AppList:AddColumn( "Owner" )
AppList:AddColumn( "Car" )
AppList:AddColumn( "Distance" )

for k,v in pairs (carList) do
	Distance = math.Round(v:GetPos():Distance(LocalPlayer():GetPos()) / 100,2)
	AppList:AddLine( v:CPPIGetOwner():Nick(), v:GetVehicleClass() , Distance.." metres")
end

AppList.OnRowSelected = function( lst, index, pnl )
	
	net.Start("SetPos")
	net.WriteEntity(carList[index])
	net.SendToServer()
	-- Debug info on row selection.
	print( "Selected " .. pnl:GetColumnText( 1 ) .. " ( " .. pnl:GetColumnText( 2 ) .. " ) at index " .. index )
end
end
end
end

function SWEP:SecondaryAttack()
	print("Second")
	isPopupActive = false
end
function SWEP:Reload()
	return true
end
function SWEP:Think()
end

net.Receive( "SetPos", function( len, pl )
if (SERVER) then
	CarPos = net.ReadEntity():GetPos()
 pl:SetPos(CarPos)
end
end)
