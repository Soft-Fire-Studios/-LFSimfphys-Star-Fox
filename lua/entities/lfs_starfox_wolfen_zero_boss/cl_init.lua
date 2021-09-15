include("shared.lua")

ENT.Lines = {}
ENT.LinesDeath = {}
ENT.Lines["Wolf (Zero)"] = {
	"cpthazama/starfox/vo/wolf_zero/come_on.wav",
	"cpthazama/starfox/vo/wolf_zero/even_trying.wav",
	"cpthazama/starfox/vo/wolf_zero/father_put_up_more_fight.wav",
	"cpthazama/starfox/vo/wolf_zero/grown_tired.wav",
	"cpthazama/starfox/vo/wolf_zero/hunt_you_down.wav",
	"cpthazama/starfox/vo/wolf_zero/i_have_you_in_my_sights.wav",
	"cpthazama/starfox/vo/wolf_zero/im_coming_for_you.wav",
	"cpthazama/starfox/vo/wolf_zero/im_impressed.wav",
	"cpthazama/starfox/vo/wolf_zero/laugh.wav",
	"cpthazama/starfox/vo/wolf_zero/not_good_enough.wav",
	"cpthazama/starfox/vo/wolf_zero/not_so_tough.wav",
	"cpthazama/starfox/vo/wolf_zero/pathetic.wav",
	"cpthazama/starfox/vo/wolf_zero/playtime_is_over.wav",
	"cpthazama/starfox/vo/wolf_zero/so_clever.wav",
	"cpthazama/starfox/vo/wolf_zero/thats_as_far_as_you_go.wav",
	"cpthazama/starfox/vo/wolf_zero/the_best_you_can_do.wav",
	"cpthazama/starfox/vo/wolf_zero/too_easy.wav",
	"cpthazama/starfox/vo/wolf_zero/too_slow.wav",
	"cpthazama/starfox/vo/wolf_zero/whats_wrong.wav",
	"cpthazama/starfox/vo/wolf_zero/youll_see_father_soon.wav",
}
ENT.LinesDeath["Wolf (Zero)"] = {
	"cpthazama/starfox/vo/wolf_zero/bested_by_a_fox.wav",
	"cpthazama/starfox/vo/wolf_zero/i_cant_lose.wav",
	"cpthazama/starfox/vo/wolf_zero/what.wav",
}

function ENT:Initialize()
	SF_CAMERA_CURRENT = self
	timer.Simple(self.CameraTime,function() if IsValid(self) && SF_CAMERA_CURRENT == self then SF_CAMERA_CURRENT = NULL end end)

	SF_CreateTrack("cpthazama/starfox/music/star_wolf.mp3",LocalPlayer(),"Star Wolf")
end

function ENT:OnRemove()
	if self.ENG2 then
		self.ENG2:Stop()
	end
	
	if self.ENG then
		self.ENG:Stop()
	end

	SF_StopTrack("Star Wolf",true)
end

local mat = Material( "sprites/light_glow02_add" )

ENT.EffectTime = 0
ENT.ShadowEffect = false
function ENT:Draw()
	self:DrawModel()

	if self:GetShadowEdge() then
		if !self.ShadowEffect then
			self:SetMaterial("effects/starfox/render_cloak")
			self.ShadowEffect = true
		end
		return
	else
		if self.ShadowEffect then
			self:SetMaterial(" ")
			self.ShadowEffect = false
		end
	end

	if (self:GetLightningBlaster() or self:GetLightningTornado() or self:GetOrbitalWolf()) && CurTime() > self.EffectTime then
		local time = self:GetLightningBlaster() && 5 or self:GetLightningTornado() && 10 or self:GetOrbitalWolf() && 3 or 1

		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetAttachment(time)
		util.Effect("lfs_sf_render_wolfen",effectdata)

		self.EffectTime = CurTime() +time +0.01
	end
	
	if not self:GetEngineActive() then return end
	
	local Boost = self.BoostAdd or 0
	
	local Size = 200 + (self:GetRPM() / self:GetLimitRPM()) * 300 + Boost
	local Mirror = false

	for i = 1,2 do
		local Sub = Mirror && 5 or 4
		pos = self:GetAttachment(Sub).Pos +self:GetForward() *-35
		render.SetMaterial(mat)
		render.DrawSprite(pos,Size,Size,Color(50,200,50,255))
		Mirror = true
	end
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

	if self:GetLightningTornado() then
		local emitter = ParticleEmitter(self:GetPos(),false)
		if emitter then
			local particle = emitter:Add("particles/fire_glow_sf",self:LocalToWorld(Vector(0,0,0)))
			local size = math.random(45,60)
			particle:SetVelocity(self:GetVelocity() +self:GetUp() *70 +VectorRand() *400)
			particle:SetGravity(Vector(0,0,0))
			particle:SetLifeTime(0)
			particle:SetDieTime(1)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(size)
			particle:SetEndSize(size *0.35)
			particle:SetAngles(AngleRand() *360)
			particle:SetColor(209,63,63)
			for i = 1,2 do
				local start = self:GetDriverSeat():GetPos() +self:GetDriverSeat():GetForward() *(i == 1 && 50 or -50)
				local particle = emitter:Add("particles/fire_glow_sf",start)
				if not particle then return end
				local size = math.random(300,400)
				particle:SetVelocity((self:GetVelocity() +VectorRand() *50))
				particle:SetGravity(Vector(0,0,1))
				particle:SetLifeTime(0)
				particle:SetDieTime(1)
				particle:SetStartAlpha(25)
				particle:SetEndAlpha(0)
				particle:SetStartSize(size)
				particle:SetEndSize(size *0.35)
				particle:SetAngles(AngleRand() *360)
				particle:SetColor(255,24,24)
			end
			emitter:Finish()
		end
	end
end