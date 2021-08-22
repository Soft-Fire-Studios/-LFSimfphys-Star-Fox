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
end

function ENT:ExhaustFX()

end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local minPitch = 15
	local maxPitch = 40
	local pitch = math.Clamp(math.Clamp(minPitch + Pitch * 50, minPitch,maxPitch) + Doppler,0,maxPitch)
	if self.ENG then
		self.ENG:ChangePitch(pitch)
		self.ENG:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound(self,"LFS_SF_CRUISER_ENGINE")
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

end

function ENT:AnimLandingGear()
end