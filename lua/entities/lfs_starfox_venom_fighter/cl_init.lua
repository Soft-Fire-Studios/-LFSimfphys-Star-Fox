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
	local Size = 1000 + (self:GetRPM() / self:GetLimitRPM()) * 300 + Boost

	render.SetMaterial(mat)
	render.DrawSprite(self:LocalToWorld(Vector(-175,0,0)),Size,Size,Color(240,38,31,255))
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
				self.BoostAdd = 600
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
		self.ENG = CreateSound(self,"LFS_SF_WOLFEN_ENGINE")
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
	local FT = FrameTime() *15
	local RPM = self:GetRPM()
	local MaxRPM = self:GetMaxRPM()
	local active = self:GetEngineActive()

	local wing1 = 5
	local wing2 = 6
	local wingS1 = 8
	local wingS2 = 7
	local flap1 = 1
	local flap2 = 2

	-- if self.LandingGear then return end
	self.fracMain = self.fracMain or 0
	self.fracMain = active && (RPM /MaxRPM) *15 or self.fracMain

	local top = Angle(0,0,-self.fracMain)
	local bottom = Angle(0,0,self.fracMain)
	self:ManipulateBoneAngles(wing1,top)
	self:ManipulateBoneAngles(wingS1,top)
	self:ManipulateBoneAngles(flap1,top)
	self:ManipulateBoneAngles(wing2,bottom)
	self:ManipulateBoneAngles(wingS2,bottom)
	self:ManipulateBoneAngles(flap2,bottom)
end

function ENT:AnimRotor()
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
	local FT = FrameTime() *15
	self.fracMain = self.fracMain or 0
	self.fracMain = self.fracMain +math.Clamp(25 -self.fracMain,-FT,FT)

	-- local startpos = self:GetPos()
	-- local TracePlane = util.TraceHull( {
	-- 	start = startpos,
	-- 	endpos = (startpos -Vector(0,0,400)),
	-- 	mins = Vector( -10, -10, -10 ),
	-- 	maxs = Vector( 10, 10, 10 ),
	-- 	filter = function( ent ) 
	-- 		if IsValid( ent ) then
	-- 			if ent == self then 
	-- 				return false
	-- 			end
	-- 		end
	-- 		return true
	-- 	end
	-- })
	-- self.LandingGear = TracePlane.Hit
	-- if !self.LandingGear then return end

	local wing1 = 5
	local wing2 = 6
	local wingS1 = 8
	local wingS2 = 7
	local flap1 = 1
	local flap2 = 2

	local top = Angle(0,0,-self.fracMain)
	local bottom = Angle(0,0,self.fracMain)
	self:ManipulateBoneAngles(wing1,top)
	self:ManipulateBoneAngles(wingS1,top)
	self:ManipulateBoneAngles(flap1,top)
	self:ManipulateBoneAngles(wing2,bottom)
	self:ManipulateBoneAngles(wingS2,bottom)
	self:ManipulateBoneAngles(flap2,bottom)
end