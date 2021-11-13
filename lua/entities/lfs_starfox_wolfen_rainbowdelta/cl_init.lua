--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

ENT.Lines["Wolf_Assault"] = {
	"cpthazama/starfox/vo/wolf_assault/aint_your_father.wav",
	"cpthazama/starfox/vo/wolf_assault/amaetures.wav",
	"cpthazama/starfox/vo/wolf_assault/dance_partner.wav",
	"cpthazama/starfox/vo/wolf_assault/done_already.wav",
	"cpthazama/starfox/vo/wolf_assault/dropped_in_unannounced.wav",
	"cpthazama/starfox/vo/wolf_assault/fools.wav",
	"cpthazama/starfox/vo/wolf_assault/go_down.wav",
	"cpthazama/starfox/vo/wolf_assault/got_questions.wav",
	"cpthazama/starfox/vo/wolf_assault/gotten_soft.wav",
	"cpthazama/starfox/vo/wolf_assault/idiots_up_to.wav",
	"cpthazama/starfox/vo/wolf_assault/lets_do_this.wav",
	"cpthazama/starfox/vo/wolf_assault/my_turf.wav",
	"cpthazama/starfox/vo/wolf_assault/not_done_yet.wav",
	"cpthazama/starfox/vo/wolf_assault/pay_attention.wav",
	"cpthazama/starfox/vo/wolf_assault/pigma_apology.wav",
	"cpthazama/starfox/vo/wolf_assault/pitiful_sight.wav",
	"cpthazama/starfox/vo/wolf_assault/settle_this.wav",
	"cpthazama/starfox/vo/wolf_assault/star_wolf_will_take_you_down.wav",
	"cpthazama/starfox/vo/wolf_assault/stupid_look.wav",
	"cpthazama/starfox/vo/wolf_assault/talk_too_much.wav",
}
ENT.Lines["Panther_Assault"] = {
	"cpthazama/starfox/vo/panther_assault/favorite_cafe.wav",
	"cpthazama/starfox/vo/panther_assault/first_class_meal.wav",
	"cpthazama/starfox/vo/panther_assault/good_as_i_heard.wav",
	"cpthazama/starfox/vo/panther_assault/grand_finale.wav",
	"cpthazama/starfox/vo/panther_assault/introduction.wav",
	"cpthazama/starfox/vo/panther_assault/make_me_mad.wav",
	"cpthazama/starfox/vo/panther_assault/no_time_for_pleas.wav",
	"cpthazama/starfox/vo/panther_assault/where_you_looking.wav",
	"cpthazama/starfox/vo/panther_assault/you_looking_to_die.wav",
	"cpthazama/starfox/vo/panther_assault/youre_doing_okay.wav",
	"cpthazama/starfox/vo/panther_assault/youre_looking_good.wav",
}
ENT.Lines["Leon_Assault"] = {
	"cpthazama/starfox/vo/leon_assault/all_you_got.wav",
	"cpthazama/starfox/vo/leon_assault/cocky_as_ever.wav",
	"cpthazama/starfox/vo/leon_assault/cook_torment.wav",
	"cpthazama/starfox/vo/leon_assault/day_to_fight_you.wav",
	"cpthazama/starfox/vo/leon_assault/end_up_as_target.wav",
	"cpthazama/starfox/vo/leon_assault/not_showing_weakness.wav",
	"cpthazama/starfox/vo/leon_assault/say_the_wor.wav",
	"cpthazama/starfox/vo/leon_assault/so_easy.wav",
	"cpthazama/starfox/vo/leon_assault/surprised_you_got_far.wav",
	"cpthazama/starfox/vo/leon_assault/think_i_am.wav",
	"cpthazama/starfox/vo/leon_assault/too_weak.wav",
	"cpthazama/starfox/vo/leon_assault/wise_guy.wav",
	"cpthazama/starfox/vo/leon_assault/youre_in_the_way.wav",
}

ENT.LinesPain = {}
ENT.LinesPain["Leon_Assault"] = {
	"cpthazama/starfox/vo/leon_assault/pain1.wav"
}

ENT.LinesDeath["Wolf_Assault"] = {
	"cpthazama/starfox/vo/wolf_assault/cant_believe_beat.wav",
	"cpthazama/starfox/vo/wolf_assault/death1.wav",
	"cpthazama/starfox/vo/wolf_assault/death2.wav",
	"cpthazama/starfox/vo/wolf_assault/thats_enough.wav",
	"cpthazama/starfox/vo/wolf_assault/thats_the_end.wav",
}
ENT.LinesDeath["Panther_Assault"] = {
	"cpthazama/starfox/vo/panther_assault/death1.wav",
}
ENT.LinesDeath["Leon_Assault"] = {
	"cpthazama/starfox/vo/leon_assault/death1.wav",
}

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

	if self.PilotThink then self:PilotThink() end
end

local mat = Material("sprites/light_glow02_add")
local mat2 = Material("particles/starfox/charge")
function ENT:Draw()
	self:DrawModel()

	local isCharging = self:GetChargeT() > CurTime()
	if isCharging then
		render.SetMaterial(mat2)
		render.DrawSprite(self:GetAttachment(7).Pos,300,300,Color(math.random(240,255),math.random(10,20),math.random(10,20),255))
	end
	
	-- if not self:GetEngineActive() then return end
	
	-- local Boost = self.BoostAdd or 0
	
	-- local Size = 80 + (self:GetRPM() / self:GetLimitRPM()) * 300 + Boost
	-- local Mirror = false

	-- local pos = self:LocalToWorld(Vector(-80,0,180))
	-- render.SetMaterial(mat)
	-- render.DrawSprite(pos,Size,Size,Color(0,127,255,255))

	-- Size = 80 + (self:GetRPM() / self:GetLimitRPM()) * 120 + Boost
	-- for i = 0,1 do
	-- 	local Sub = Mirror and 1 or -1
	-- 	pos = self:LocalToWorld(Vector(-70,101 *Sub,225))
	-- 	render.SetMaterial(mat)
	-- 	render.DrawSprite(pos,Size,Size,Color(0,255,0,255))
	-- 	Mirror = true
	-- end
end

function ENT:ExhaustFX()
	self.nextEFX = self.nextEFX or 0
	local active = self:GetEngineActive()
	local vtol = self:GetNW2Bool("VTOL")

	if !active or vtol then
		local emitter = ParticleEmitter(self:GetPos(),false)
		if emitter then
			local particle = emitter:Add("particles/fire_glow_sf",self:LocalToWorld(Vector(5,0,-50)))
			if not particle then return end
			local size = math.random(45,60)
			particle:SetVelocity(self:GetUp() *-70 +VectorRand() *70)
			particle:SetGravity(Vector(0,0,-5))
			particle:SetLifeTime(0)
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(size)
			particle:SetEndSize(size *0.35)
			particle:SetAngles(AngleRand() *360)
			if math.random(1,2) == 1 then
				particle:SetColor(0,255,63)
			else
				particle:SetColor(150,0,255)
			end
			emitter:Finish()
		end
	end

	if not active then return end
	
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
		
		local emitter = ParticleEmitter( self:GetPos(), false )
		
		if emitter then
			local wingLeft = 3
			local wingRight = 4
			local right = SF.BoneData(self,wingRight)
			local left = SF.BoneData(self,wingLeft)

			local vOffset = self:LocalToWorld(Vector(-80,0,180))
			local vNormal = -self:GetForward()

			vOffset = vOffset + vNormal * 5

				-- Side Engines --
			for i = 1,2 do
				local bone = (i == 2 && left or right)
				local Sub = (-0.2)
				local pitchSub = (-0.65)
				local sideSub = (-1)
				local Side = (i == 2 && 1 or i == 1 && -1)
				local fracMain =  (self.fracMain /15 or 1)
				vOffset = bone.Pos +vNormal *90 +self:GetRight() *(-110 *Side) +self:GetUp() *-30 +self:GetUp() *(20 *fracMain)

				local particle = emitter:Add(mat, vOffset )
				if not particle then return end
				local vUp = self:GetUp()
				local vRight = self:GetRight()
				local vForward = -self:GetForward()
				local vDir = vForward +(vUp *Sub)
				local pitchChange = (vUp *(500 *fracMain)) *-pitchSub
				
				local size = 70 +(self.BoostAdd *0.4)
				local misc = self:GetVelocity() +(vRight *(-900 *Side) or Vector(0,0,0))
				particle:SetVelocity(vDir *(1200) +pitchChange +misc +vUp *-200 +vRight *(600 *fracMain *Side))
				particle:SetGravity(Vector(0,0,0))
				particle:SetAirResistance(5)
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.15 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( size )
				particle:SetEndSize( size )
				particle:SetAngles( vDir:Angle() *fracMain )
				particle:SetColor(0,255,0)
			end
		
			emitter:Finish()
		end
	end
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local minPitch = 45
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
		self.ENG = CreateSound( self, "LFS_SF_WOLFEN_ENGINE" )
		self.ENG:PlayEx(0,0)
		-- self.ENG2 = CreateSound( self, "LFS_SF_ARWING_ENGINE2" )
		-- self.ENG2:PlayEx(0,0)
	else
		if self.ENG then
			self.ENG:Stop()
		end
	end
end

function ENT:OnRemove()
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

	local wingLeft = 3
	local wingRight = 4

	self.fracMain = (RPM /MaxRPM) *15
	
	local wingMovement = self.fracMain
	self:ManipulateBoneAngles(wingLeft,Angle(-wingMovement,-wingMovement,0))
	self:ManipulateBoneAngles(wingRight,Angle(wingMovement,wingMovement,0))
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	self.SMcOpen = 0
	
	-- self:ManipulateBoneAngles(2,Angle(0,0,0))
	self:ManipulateBoneAngles(7,Angle(0,0,self.SMcOpen *90))
	self:ManipulateBoneAngles(5,Angle(0,0,self.SMcOpen *90))
end

function ENT:AnimLandingGear()
end