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
	//lfsGetInput( "PRI_ATTACK" )
end

local mat = Material( "sprites/light_glow02_add" )
local mat2 = Material("particles/starfox/charge")
function ENT:Draw()
	self:DrawModel()

	local isCharging = self:GetChargeT() > CurTime()
	if isCharging then
		render.SetMaterial(mat2)
		render.DrawSprite(self:GetAttachment(5).Pos,300,300,Color(math.random(240,255),math.random(10,20),math.random(10,20),255))
	end
	
	if not self:GetEngineActive() then return end
	
	local Boost = self.BoostAdd or 0
	
	local Size = 80 + (self:GetRPM() / self:GetLimitRPM()) * 300 + Boost
	local Mirror = false

	local pos = self:LocalToWorld(Vector(-80,0,180))
	render.SetMaterial(mat)
	render.DrawSprite(pos,Size,Size,Color(0,127,255,255))

	Size = 80 + (self:GetRPM() / self:GetLimitRPM()) * 120 + Boost
	for i = 0,1 do
		local Sub = Mirror and 1 or -1
		pos = self:LocalToWorld(Vector(-70,101 *Sub,225))
		render.SetMaterial(mat)
		render.DrawSprite(pos,Size,Size,Color(0,255,0,255))
		Mirror = true
	end
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
	local active = self:GetEngineActive()
	local vtol = self:GetNW2Bool("VTOL")

	if !active or vtol then
		local emitter = ParticleEmitter(self:GetPos(),false)
		if emitter then
			local particle = emitter:Add("particles/fire_glow_sf",self:LocalToWorld(Vector(-25,0,150)))
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

		local throttle = self:GetThrottlePercent() *0.01
		
		if IsValid(Driver) && !vtol then
			local rollLeft = Driver:lfsGetInput("-ROLL")
			local rollRight = Driver:lfsGetInput("+ROLL")				
			if rollLeft or rollRight then
				if (rollLeft && rollRight) then return end
				local emitter = ParticleEmitter(self:GetPos(),false)
				if emitter then
					local particle = emitter:Add("particles/fire_glow_sf",self:LocalToWorld(Vector(-25,0,150)))
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
					particle:SetColor(168,255,190)
					for i = 1,2 do
						local start = SF.BoneData(self,i == 1 && 4 or 7)
						local particle = emitter:Add("particles/fire_glow_sf",start.Pos)
						if not particle then return end
						local size = math.random(200,300)
						particle:SetVelocity((self:GetVelocity() +VectorRand() *50))
						particle:SetGravity(Vector(0,0,1))
						particle:SetLifeTime(0)
						particle:SetDieTime(1)
						particle:SetStartAlpha(25)
						particle:SetEndAlpha(0)
						particle:SetStartSize(size)
						particle:SetEndSize(size *0.35)
						particle:SetAngles(AngleRand() *360)
						particle:SetColor(0,255,63)
					end
					emitter:Finish()
				end
			end
		end
		
		local emitter = ParticleEmitter(self:GetPos(),false)
		
		if emitter then
			local leftTop = BoneData(self,4)
			local leftMiddle = BoneData(self,5)
			local leftBottom = BoneData(self,6)
			local rightTop = BoneData(self,9)
			local rightMiddle = BoneData(self,8)
			local rightBottom = BoneData(self,7)

			local vOffset = self:LocalToWorld(Vector(-80,0,180))
			local vNormal = -self:GetForward()

			vOffset = vOffset + vNormal * 5

				-- Side Engines --
			for a = 1,2 do
				for i = 1,2 do
					local bone = (a == 1 && (i == 1 && leftTop or leftBottom) or (i == 1 && rightTop or rightBottom))
					local Sub = (i == 1 && 1 or -1)
					local Side = (a == 1 && 1 or -1)
					-- vOffset = self:LocalToWorld(Vector(-70,101 *Sub,225))
					-- vOffset = self:LocalToWorld(Vector(-70,101 *Side,225 +(Sub && 0 or 20)))
					vOffset = bone.Pos +vNormal *40

					local particle = emitter:Add(Material("particles/fire_glow_sf"), vOffset )
					if not particle then return end
					local fracMain =  (self.fracMain /15 or 1)
					local vUp = self:GetUp()
					local vRight = self:GetRight()
					local vForward = -self:GetForward()
					local vDir = vForward +(vUp *Sub)
					local pitchChange = (vUp *(500 *fracMain)) *-Sub
					
					local size = 70 +(self.BoostAdd *0.4)
					local misc = self:GetVelocity() +(i == 2 && vRight *-350 *Side or Vector(0,0,0))
					particle:SetVelocity(vDir *1000 +pitchChange +misc)
					particle:SetGravity(Vector(0,0,0))
					particle:SetAirResistance(5)
					particle:SetLifeTime( 0 )
					particle:SetDieTime( 0.15 )
					particle:SetStartAlpha(math.Clamp(255 *throttle,0,255))
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( size )
					particle:SetEndSize( size )
					particle:SetAngles( vDir:Angle() *fracMain )
					particle:SetColor(0,255,0)
				end
			end
		
			emitter:Finish()
		end
	end
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
	throttleLast = throttle
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound(self,"LFS_SF_ARWING_ENGINE_NEW")
		self.ENG:PlayEx(0,0)
		self.ENG2 = CreateSound(self,"LFS_SF_ARWING_ENGINE")
		self.ENG2:PlayEx(0,0)
	else
		if self.ENG then
			self.ENG:Stop()
		end
		if self.ENG2 then
			self.ENG2:Stop()
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

	local leftTop = 4
	local leftMiddle = 5
	local leftBottom = 6
	local rightTop = 9
	local rightMiddle = 8
	local rightBottom = 7

	-- self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	-- self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	-- self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0

	self.fracMain = (RPM /MaxRPM) *15
	
	self:ManipulateBoneAngles( leftMiddle, Angle((self.fracMain *1) -25,0,0 ) )
	self:ManipulateBoneAngles( rightMiddle, Angle((-self.fracMain *1) +25,0,0 ) )
	
	self:ManipulateBoneAngles( leftTop, Angle( 0,0,-self.fracMain) )
	self:ManipulateBoneAngles( leftBottom, Angle( 0,0,self.fracMain) )
	
	self:ManipulateBoneAngles( rightTop, Angle( 0,0,-self.fracMain) )
	self:ManipulateBoneAngles( rightBottom, Angle( 0,0,self.fracMain) )
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()
	local bOn = self:GetActive()
	
	local TVal = bOn && 0 or 1
	
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen && self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	
	self:ManipulateBoneAngles(3,Angle(0,0,self.SMcOpen *-90))
end

function ENT:AnimLandingGear()
end