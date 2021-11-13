--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:LFSCalcViewThirdPerson(view,ply)
	return SF.CalcThirdView(self,view,ply)
end

function ENT:LFSHudPaintCrosshair(HitPlane,HitPilot)
	SF.PaintCrosshair(self,HitPlane,HitPilot)
end

function ENT:LFSHudPaintInfoLine(HitPlane,HitPilot,LFS_TIME_NOTIFY,Dir,Len,FREELOOK)
	SF.PaintInfoLine(self,HitPlane,HitPilot,LFS_TIME_NOTIFY,Dir,Len,FREELOOK)
end

function ENT:Think()
	self:AnimCabin()
	self:AnimLandingGear()
	self:AnimRotor()
	self:AnimFins()
	
	self:CheckEngineState()
	
	self:ExhaustFX()
	self:DamageFX()
end

function ENT:GetLightColor()
	local col = self:GetNW2Vector("LightColor",Color(255,255,255,255))
	return Color(col.x,col.y,col.z)
end

local mat = Material( "sprites/light_glow02_add" )
local mat2 = Material("particles/starfox/charge")
function ENT:Draw()
	self:DrawModel()

	local isCharging = self:GetChargeT() > CurTime()
	if isCharging then
		render.SetMaterial(mat2)
		render.DrawSprite(self:GetAttachment(1).Pos,300,300,Color(math.random(60,75),math.random(240,255),math.random(60,75),255))
	end
	
	if not self:GetEngineActive() then return end
	
	local Boost = self.BoostAdd or 0
	
	local Size = 400 + (self:GetRPM() / self:GetLimitRPM()) * 300 + Boost
	local Mirror = false
	local throttle = self:GetThrottlePercent()

	local pos = self:GetAttachment(5).Pos +self:GetForward() *-10
	render.SetMaterial(mat)
	render.DrawSprite(pos,Size,Size,self:GetLightColor())

	-- for i = 1,2 do
	-- 	local Sub = Mirror && 5 or 4
	-- 	pos = self:GetAttachment(Sub).Pos +self:GetForward() *-35
	-- 	render.SetMaterial(mat)
	-- 	render.DrawSprite(pos,Size,Size,Color(78,210,250))
	-- 	Mirror = true
	-- end
end

function ENT:ExhaustFX()
	self.nextEFX = self.nextEFX or 0

	if not self:GetEngineActive() then return end
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	local Driver = self:GetDriver()
	if IsValid( Driver ) then
		local W = Driver:lfsGetInput( "+THROTTLE" )
		if W ~= self.oldW then
			self.oldW = W
			if W then
				self.BoostAdd = 100
			end
		end
	end
	
	self.BoostAdd = self.BoostAdd && (self.BoostAdd - self.BoostAdd * FrameTime()) or 0
end

local throttleLast = 0
function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local minPitch = 75
	local pitch = math.Clamp(math.Clamp(minPitch + Pitch * 50, minPitch,255) + Doppler,0,255)
	local throttle = self:GetThrottlePercent()
	if self.ENG then
		self.ENG:ChangePitch(pitch)
		self.ENG:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	end
	if self.ENG2 then
		self.ENG2:ChangePitch(pitch)
		if throttle > throttleLast then
			self.ENG2:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
		else
			self.ENG2:ChangeVolume(0)
		end
	end

	local ply = self:GetDriver()
	if !ply:IsPlayer() then return end
	local seat = ply:GetVehicle()
	if !self.INT then return end
	if IsValid(seat) && !seat:GetThirdPersonMode() then
		self.INT:ChangePitch(self.ENG:GetPitch())
		self.INT:ChangeVolume(self.ENG:GetVolume())
		self.ENG:ChangeVolume(0)
	else
		self.INT:ChangePitch(0)
		self.INT:ChangeVolume(0)
	end
	throttleLast = throttle
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound(self,"LFS_SF_ARWING_ENGINE_NEW")
		self.ENG:PlayEx(0,0)
		self.ENG2 = CreateSound(self,"LFS_SF_ARWING_ENGINE")
		self.ENG2:PlayEx(0,0)
		self.INT = CreateSound(self,"LFS_SF_ARWING_ENGINE_INTERIOR")
		self.INT:PlayEx(0,0)
	else
		if self.ENG then
			self.ENG:Stop()
		end
		if self.ENG2 then
			self.ENG2:Stop()
		end
		if self.INT then
			self.INT:Stop()
		end
	end
end

function ENT:OnRemove()
	if self.INT then
		self.INT:Stop()
	end
	if self.ENG2 then
		self.ENG2:Stop()
	end
	if self.ENG then
		self.ENG:Stop()
	end
end

function ENT:AnimFins()
	local FT = FrameTime() * 10
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()

	local rFlap = 5
	local lFlap = 9

	self.fracMain = (RPM /MaxRPM) *15

	local Pitch = self:GetRotPitch()
	self.smPitch = self.smPitch && self.smPitch +(Pitch -self.smPitch) *FT or 0

	self:ManipulateBoneAngles(lFlap,LerpAngle(FT,self:GetManipulateBoneAngles(lFlap),Angle(15,-10,-6 -self.smPitch)))
	self:ManipulateBoneAngles(rFlap,LerpAngle(FT,self:GetManipulateBoneAngles(rFlap),Angle(-15,10,-6 -self.smPitch)))
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()
	local bOn = self:GetActive()
	
	local TVal = bOn && 0 or 1
	
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen && self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	
	-- self:ManipulateBoneAngles(2,Angle(0,0,0))
	self:ManipulateBoneAngles(14,Angle(0,0,self.SMcOpen *-90))
end

function ENT:AnimLandingGear()
end