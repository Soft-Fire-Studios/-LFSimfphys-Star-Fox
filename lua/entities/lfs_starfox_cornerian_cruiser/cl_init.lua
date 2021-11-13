--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:LFSCalcViewThirdPerson(view,ply)
	view.origin = view.origin +self:GetForward() *-6000 +self:GetUp() *1000
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

local mat = Material("effects/energy_flare_03_nocolor")
function ENT:Draw()
	self:DrawModel()
	
	if not self:GetEngineActive() then return end
	
	local Boost = self.BoostAdd or 0
	local Size = 3000 + (self:GetRPM() / self:GetLimitRPM()) * 1250 + Boost

	for i = 1,2 do
		local Mirror = i == 2 && -1 or 1
		render.SetMaterial(mat)
		render.DrawSprite(self:LocalToWorld(Vector(-1200,1200 *Mirror,1200)),Size,Size,Color(168,255,190,255))
		
		render.SetMaterial(mat)
		render.DrawSprite(self:LocalToWorld(Vector(-1200,1200 *Mirror,-1200)),Size,Size,Color(168,255,190,255))
	end
	
	Size = Size *2
	render.SetMaterial(mat)
	render.DrawSprite(self:LocalToWorld(Vector(-1200,0,0)),Size,Size,Color(192,153,255,255))
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
	
	self.BoostAdd = self.BoostAdd and (self.BoostAdd - self.BoostAdd * FrameTime()) or 0
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.01

		local throttle = self:GetThrottlePercent() *0.01
		local emitter = ParticleEmitter(self:GetPos(),false)
		if emitter then
			local pos = {
				Vector(-1600,1000,300),
				Vector(-1600,1000,-300),
				Vector(-1600,-1000,300),
				Vector(-1600,-1000,-300)
			}
			for i = 1,4 do
				local startPos = self:LocalToWorld(pos[i])
				local particle = emitter:Add(Material("particles/fire_glow_sf"),startPos)
				if not particle then return end
				local Sub = ((i == 1 or i == 3) && 1 or -1)
				local Side = ((i == 1 or i == 2) && 1 or -1)
				local isOther = !(i == 1 or i == 2)
				local vUp = self:GetUp()
				local vRight = self:GetRight()
				local vForward = -self:GetForward()
				local vDir = vForward +(vUp *(Sub *0.25))
				local size = 1200 +(self.BoostAdd *0.6)
				local misc = self:GetVelocity() +(vRight *-350 *Side)

				particle:SetVelocity(vDir *15000 +misc)
				particle:SetGravity(Vector(0,0,0))
				particle:SetAirResistance(5)
				particle:SetLifeTime(0)
				particle:SetDieTime(0.15)
				particle:SetStartAlpha(math.Clamp(255 *throttle,0,255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(size)
				particle:SetEndSize(size)
				particle:SetAngles(vDir:Angle())
				particle:SetColor(192,153,255)
			end
		
			emitter:Finish()
		end
	end
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local minPitch = 50
	local maxPitch = 80
	local pitch = math.Clamp(math.Clamp(minPitch + Pitch * 50, minPitch,maxPitch) + Doppler,0,maxPitch)
	if self.ENG then
		self.ENG:ChangePitch(pitch)
		self.ENG:ChangeVolume(1)
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound(self,"LFS_SF_BIGSHIP_ENGINE")
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