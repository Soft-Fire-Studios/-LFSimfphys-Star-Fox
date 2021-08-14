--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

ENT.Lines["Wolf"] = {
	"cpthazama/starfox/vo/wolf/Wolfgoing down.mp3",
	"cpthazama/starfox/vo/wolf/WolfPlaytimes over.mp3",
	"cpthazama/starfox/vo/wolf/Wolfis that all.mp3",
	"cpthazama/starfox/vo/wolf/Wolfwhat the heck.mp3",
	"cpthazama/starfox/vo/wolf/Wolfyoull be seeing your dad.mp3",
	"cpthazama/starfox/vo/wolf/Wolfyoure not so tough.mp3",
	"cpthazama/starfox/vo/wolf/WollfCant let you do that.mp3",
	"cpthazama/starfox/vo/wolf/WollfDont get too cocky.mp3",
	"cpthazama/starfox/vo/wolf/WolfPlaytimes over.mp3",
	"cpthazama/starfox/vo/wolf/Wolfyoure good im better.mp3",
}
ENT.Lines["Andrew"] = {
	"cpthazama/starfox/vo/andrew/Andrew Andross enemy.mp3",
	"cpthazama/starfox/vo/andrew/AndrewIm not afraid.mp3",
	"cpthazama/starfox/vo/andrew/Andrewbow before the great andross.mp3",
	"cpthazama/starfox/vo/andrew/Andrewgive it up.mp3",
	"cpthazama/starfox/vo/andrew/Andrewscore one for andross.mp3",
	"cpthazama/starfox/vo/andrew/Andrewstick to the pond.mp3",
	"cpthazama/starfox/vo/andrew/Andrewwell make sure.mp3",
	"cpthazama/starfox/vo/andrew/Andrewyoull be sorry.mp3",
	"cpthazama/starfox/vo/andrew/Andrewyoure not welcome.mp3",
}
ENT.Lines["Leon"] = {
	"cpthazama/starfox/vo/leon/LeonI think Ill torture you.mp3",
	"cpthazama/starfox/vo/leon/LeonIll take care of you.mp3",
	"cpthazama/starfox/vo/leon/Leonandross ordered us.mp3",
	"cpthazama/starfox/vo/leon/Leonannoying bird.mp3",
	"cpthazama/starfox/vo/leon/Leonclose but no cigar.mp3",
	"cpthazama/starfox/vo/leon/Leonnew ships.mp3",
	"cpthazama/starfox/vo/leon/Leonnot as bad as I thought.mp3",
	"cpthazama/starfox/vo/leon/Leonnot yet.mp3",
	"cpthazama/starfox/vo/leon/Leonshoot me down.mp3",
}
ENT.Lines["Pigma"] = {
	"cpthazama/starfox/vo/pigma/PigmaIll do you fast.mp3",
	"cpthazama/starfox/vo/pigma/PigmaIm gonna bust you up.mp3",
	"cpthazama/starfox/vo/pigma/Pigmacome on little man.mp3",
	"cpthazama/starfox/vo/pigma/Pigmadaddy screamed.mp3",
	"cpthazama/starfox/vo/pigma/Pigmapeppy long time.mp3",
	"cpthazama/starfox/vo/pigma/Pigmathat reward.mp3",
	"cpthazama/starfox/vo/pigma/Pigmatoo bad dads not here.mp3",
	"cpthazama/starfox/vo/pigma/Pigmatwo words.mp3",
	"cpthazama/starfox/vo/pigma/Pigmawere getting paid.mp3",
	"cpthazama/starfox/vo/pigma/Pigmayou cant beat me.mp3",
}
ENT.LinesDeath["Wolf"] = {
	"cpthazama/starfox/vo/wolf/Wolfno way.mp3",
	"cpthazama/starfox/vo/wolf/WollfI cant lose.mp3"
}
ENT.LinesDeath["Andrew"] = {
	"cpthazama/starfox/vo/andrew/Andrew aah.mp3",
	"cpthazama/starfox/vo/andrew/Andrewuncle andross.mp3",
}
ENT.LinesDeath["Leon"] = {
	"cpthazama/starfox/vo/leon/Leonthis cant be happening.mp3",
	"cpthazama/starfox/vo/leon/Leontoo strong.mp3",
}
ENT.LinesDeath["Pigma"] = {
	"cpthazama/starfox/vo/pigma/Pigmabeautiful reward.mp3",
	"cpthazama/starfox/vo/pigma/Pigmathis cant be happening.mp3",
}

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

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()

	local isCharging = self:GetChargeT() > CurTime()
	if isCharging then
		render.SetMaterial(mat)
		render.DrawSprite(self:GetAttachment(3).Pos,700,700,Color(math.random(240,255),math.random(10,20),math.random(10,20),255))
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
	
	self.BoostAdd = self.BoostAdd and (self.BoostAdd - self.BoostAdd * FrameTime()) or 0
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.01
		
		local emitter = ParticleEmitter( self:GetPos(), false )
		
		if emitter then
			local top = BoneData(self,6)
			local right = BoneData(self,5)
			local left = BoneData(self,4)

			local vOffset = self:LocalToWorld(Vector(-80,0,180))
			local vNormal = -self:GetForward()

			vOffset = vOffset + vNormal * 5

				-- Side Engines --
			for i = 1,3 do
				local bone = (i == 1 && top or i == 2 && left or right)
				local Sub = (i < 2 && 1.25 or -0.2)
				local pitchSub = (i < 2 && 1 or -0.65)
				local sideSub = (i < 2 && 1 or -1)
				local Side = (i == 2 && 1 or i == 3 && -1 or 0)
				vOffset = bone.Pos +vNormal *40 + Vector(-25 *Side,0,0)

				local particle = emitter:Add(mat, vOffset )
				if not particle then return end
				local fracMain =  (self.fracMain /15 or 1)
				local vUp = self:GetUp()
				local vRight = self:GetRight()
				local vForward = -self:GetForward()
				local vDir = vForward +(vUp *Sub)
				local pitchChange = (vUp *(500 *fracMain)) *-pitchSub
				
				local size = 70 +(self.BoostAdd *0.4)
				local misc = self:GetVelocity() +(i > 1 && vRight *(-600 *Side) or Vector(0,0,0))
				particle:SetVelocity(vDir *(i > 1 && 1300 or 800) +pitchChange +misc)
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
	-- local Pitch = self:GetRotPitch()
	-- local Yaw = self:GetRotYaw()
	-- local Roll = -self:GetRotRoll()
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()

	local top = 6
	local right = 5
	local left = 4

	local wingLeft = 7
	local wingRight = 8

	-- self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	-- self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	-- self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0

	self.fracMain = (RPM /MaxRPM) *15
	
	local wingMovement = self.fracMain *0.5
	self:ManipulateBoneAngles(wingLeft,Angle(-wingMovement,0,0))
	self:ManipulateBoneAngles(wingRight,Angle(wingMovement,0,0))

	self:ManipulateBoneAngles(top,Angle(0,0,-20 -self.fracMain))
	local bottom = self.fracMain *0.5
	self:ManipulateBoneAngles(left,Angle(-self.fracMain *1.25,bottom,self.fracMain *0.1))
	self:ManipulateBoneAngles(right,Angle(self.fracMain *1.25,-bottom,self.fracMain *0.1))
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	
	-- self:ManipulateBoneAngles(2,Angle(0,0,0))
	self:ManipulateBoneAngles(2,Angle(0,0,self.SMcOpen *-90))
end

function ENT:AnimLandingGear()
end