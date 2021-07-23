--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:Initialize()
	
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	
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
	
	local emitter = ParticleEmitter( self:GetPos(), false )
	if emitter then
		local isCharging = self:GetChargeT() > CurTime()
		local vNormal = self:GetForward()
		if isCharging then
			local particle = emitter:Add(mat, self:GetAttachment(3).Pos)
			if not particle then return end

			particle:SetVelocity(-self:GetVelocity())
			particle:SetLifeTime(0)
			particle:SetDieTime(0.025)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(220)
			particle:SetStartSize(math.random(80,100))
			particle:SetEndSize(math.random(120,130))
			particle:SetAngles(vNormal:Angle())
			particle:SetColor(math.random(240,255),math.random(10,20),math.random(10,20))
		end
	end

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
	if self.ENG then
		self.ENG:ChangePitch(  math.Clamp(math.Clamp(  50 + Pitch * 50, 50,255) + Doppler,0,255) )
		self.ENG:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	end
	-- if self.ENG2 then
		-- self.ENG2:ChangePitch(  math.Clamp(math.Clamp(  50 + Pitch * 50, 50,255) + Doppler,0,255) )
		-- self.ENG2:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0.5,1) )
	-- end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "LFS_SF_ARWING_ENGINE" )
		self.ENG:PlayEx(0,0)
		self.ENG2 = CreateSound( self, "LFS_SF_ARWING_ENGINE2" )
		self.ENG2:PlayEx(0,0)
	else
		self:SoundStop()
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