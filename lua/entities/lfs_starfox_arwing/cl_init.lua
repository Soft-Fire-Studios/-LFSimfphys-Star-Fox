--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:Initialize()
	
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()

	local isCharging = self:GetChargeT() > CurTime()
	if isCharging then
		render.SetMaterial(mat)
		render.DrawSprite(self:GetAttachment(5).Pos,700,700,Color(math.random(240,255),math.random(10,20),math.random(10,20),255))
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
		
		local emitter = ParticleEmitter( self:GetPos(), false )
		
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

				-- Main Engine --
			-- local particle = emitter:Add(mat, vOffset)
			-- if not particle then return end

			-- particle:SetVelocity( vNormal * 5 + self:GetVelocity() *-5 )
			-- particle:SetLifeTime( 0 )
			-- particle:SetDieTime( 0.5 )
			-- particle:SetStartAlpha( 255 )
			-- particle:SetEndAlpha( 0 )
			-- particle:SetStartSize( 220 +self.BoostAdd )
			-- particle:SetEndSize( 0 )
			-- particle:SetAngles( vNormal:Angle() )
			-- particle:SetColor(130,194,255)

			-- local particle = emitter:Add(mat, vOffset)
			-- if not particle then return end

			-- particle:SetVelocity( vNormal * 5 + self:GetVelocity() *-5 )
			-- particle:SetLifeTime( 0 )
			-- particle:SetDieTime( 0.5 )
			-- particle:SetStartAlpha( 255 )
			-- particle:SetEndAlpha( 0 )
			-- particle:SetStartSize( 220 +self.BoostAdd )
			-- particle:SetEndSize( 0 )
			-- particle:SetAngles( vNormal:Angle() )
			-- particle:SetColor(230,166,255)

				-- Side Engines --
			for a = 1,2 do
				for i = 1,2 do
					local bone = (a == 1 && (i == 1 && leftTop or leftBottom) or (i == 1 && rightTop or rightBottom))
					local Sub = (i == 1 && 1 or -1)
					local Side = (a == 1 && 1 or -1)
					-- vOffset = self:LocalToWorld(Vector(-70,101 *Sub,225))
					-- vOffset = self:LocalToWorld(Vector(-70,101 *Side,225 +(Sub && 0 or 20)))
					vOffset = bone.Pos +vNormal *40

					local particle = emitter:Add(mat, vOffset )
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
					particle:SetStartAlpha( 255 )
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

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local minPitch = 75
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
		-- self.ENG2 = CreateSound(self,"LFS_SF_ARWING_ENGINE2")
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
	
	self:ManipulateBoneAngles( leftMiddle, Angle(self.fracMain *0.5,0,0 ) )
	self:ManipulateBoneAngles( rightMiddle, Angle(-self.fracMain *0.5,0,0 ) )
	
	self:ManipulateBoneAngles( leftTop, Angle( 0,0,-self.fracMain) )
	self:ManipulateBoneAngles( leftBottom, Angle( 0,0,self.fracMain) )
	
	self:ManipulateBoneAngles( rightTop, Angle( 0,0,-self.fracMain) )
	self:ManipulateBoneAngles( rightBottom, Angle( 0,0,self.fracMain) )
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	
	self:ManipulateBoneAngles(3,Angle(0,0,self.SMcOpen *-90))
end

function ENT:AnimLandingGear()
end