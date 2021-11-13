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

function ENT:Initialize()
	
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	
	if not self:GetEngineActive() then return end

	local Boost = self.BoostAdd or 0
	local Size = 350 + (self:GetRPM() /self:GetLimitRPM()) *400 + Boost

	render.SetMaterial(Material("sprites/glow04_noz_gmod"))
	render.DrawSprite(self:GetAttachment(2).Pos +self:GetForward() *-20,Size,Size,Color(192,153,255))
end

local function BoneData(self,bone)
	local pos,ang = self:GetBonePosition(bone)
	local tbl = {}
	tbl.Pos = pos
	tbl.Ang = ang

	return tbl
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
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local minPitch = 85
	local pitch = math.Clamp(math.Clamp(minPitch + Pitch * 50, minPitch,255) + Doppler,0,255)
	-- Entity(1):ChatPrint(pitch)
	if self.ENG then
		self.ENG:ChangePitch(pitch)
		self.ENG:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	end
	-- if self.ENG2 then
		-- self.ENG2:ChangePitch(  math.Clamp(math.Clamp(  50 + Pitch * 50, 50,255) + Doppler,0,255) )
		-- self.ENG2:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	-- end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound(self,"LFS_SF_ARWING_ENGINE")
		self.ENG:PlayEx(0,0)
	else
		if self.ENG then
			self.ENG:Stop()
		end
	end
end

function ENT:OnRemove()
	if self.ENG then
		self.ENG:Stop()
	end
end

function ENT:AnimFins()
end

function ENT:AnimRotor()
end

function ENT:AnimCabin()
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	
	self:ManipulateBoneAngles(2,Angle(0,0,self.SMcOpen *-90))
end

function ENT:AnimLandingGear()
end