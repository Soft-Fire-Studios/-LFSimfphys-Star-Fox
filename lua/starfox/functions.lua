print("Loading [LFSimfphys] Star Fox Functions file...")

//https://wiki.facepunch.com/gmod/PhysObj:AddAngleVelocity

SF = SF or {}
SF.CachedSounds = SF.CachedSounds or {}
SF.AITurrets = SF.AITurrets or {}
SF.MissionData = SF.MissionData or {}
SF.ShipData = SF.ShipData or {}

local function GetPlyName(ply)
	return string.gsub(ply:SteamID(),":","_")
end

SF.DoVO = function(ent,snd,chance,stopAll)
	net.Start("SF_PlayVO")
		net.WriteEntity(ent)
		net.WriteString(VJ_PICK(snd))
		net.WriteFloat(chance or 30)
		net.WriteBool(stopAll or false)
	net.Broadcast()
end

SF.AddShipData = function(ship,name,mdl,health,shield,ammo1,ammo2,bio,unlockLevel)
	SF.ShipData[ship] = {
		ID = ship,
		Name = name,
		Model = mdl,
		Health = health or 1,
		Shield = shield or 0,
		PrimaryAmmo = ammo1 or -1,
		SecondaryAmmo = ammo2 or -1,
		Bio = bio or "[Missing Bio]",
		UnlockLevel = unlockLevel or 0,
		ReqParts = ReqParts or 1
	}
	-- print("Successfully registered " .. name .. "!")
end

SF.AddMissionData = function(id,name,desc,icon,isBad)
	SF.MissionData[#SF.MissionData +1] = {
		ID = id,
		Name = name,
		Description = desc,
		Icon = icon,
		IsBad = isBad,
	}
end

SF.GetReqXP = function(lvl)
	return ((lvl *5) *500) *1.25
end

SF.GetData = function(ply,ship)
	local name = GetPlyName(ply)
	local fileName = ship && "lfsimfphys_starfox/customization/" .. name .. "_" .. ship .. ".dat" or "lfsimfphys_starfox/player/" .. name .. ".dat"
	local data = SF_C.ReadData(fileName) or {}

	return data,fileName
end

SF.SetLockStatus = function(ply,ship,unlocked)
	local data,fileName = SF.GetData(ply,ship)

	data.Unlocked = unlocked
	if unlocked && GetConVar("lfs_sf_xpchat"):GetBool() == true then
		ply:ChatPrint("You've unlocked the " .. SF.ShipData[ship].Name .. "!")
	end
	SF_C.WriteData(fileName,data,true)
end

SF.SetParts = function(ply,parts,give,ship)
	local data,fileName = SF.GetData(ply,ship)

	data.Parts = give && (data.Parts or 0) +parts or parts
	if give && GetConVar("lfs_sf_xpchat"):GetBool() == true then
		ply:ChatPrint("You've obtained " .. parts .. " " .. SF.ShipData[ship].Name .. " parts!")
	end
	SF_C.WriteData(fileName,data,true)
end

SF.OnLevelUp = function(ply,data,isShip)
	if GetConVar("lfs_sf_xpchat"):GetBool() == true then
		ply:ChatPrint(!isShip && "You've successfully leveled up! You are now a Level " .. data.Level .. " Pilot!" or "Your " .. SF.ShipData[ply:GetInfo("lfs_sf_ship")].Name .. " is now Level " .. data.Level .. "!")
	end
end

SF.CalcXP = function(ent)
	if ent.GetGunnerSeat then
		return math.Round(ent.MaxHealth *math.Rand(0.95,2))
	elseif ent:IsPlayer() then
		local pXP = SF.GetData(ent).XP or 0
		local sXP = SF.GetData(ent,ent:GetInfo("lfs_sf_ship")).XP or 0
		return math.Round((pXP +sXP) *1.25)
	elseif ent:IsNPC() then
		return math.Round(ent:GetMaxHealth() *math.Rand(0.95,2))
	end
end

SF.SetXP = function(ply,xp,give,isShip)
	if isShip then
		local data,fileName = SF.GetXP(ply,true)

		data.XP = give && (data.XP or 0) +xp or xp
		local reqXP = SF.GetReqXP(data.Level or 1)
		if give && GetConVar("lfs_sf_xpchat"):GetBool() == true then
			ply:ChatPrint("Your ship has obtained " .. xp .. " XP!")
		end
		if data.XP >= reqXP then
			data.Level = (data.Level or 1) +(math.Clamp(math.floor(data.XP /reqXP),1,SF_MAX_LEVEL))
			SF.OnLevelUp(ply,data,isShip)
		end
		SF_C.WriteData(fileName,data,true)
		return
	end
	local data,fileName = SF.GetXP(ply)

	data.XP = give && (data.XP or 0) +xp or xp
	local reqXP = SF.GetReqXP(data.Level or 1)
	if give && GetConVar("lfs_sf_xpchat"):GetBool() == true then
		ply:ChatPrint("You have obtained " .. xp .. " XP!")
	end
	if data.XP >= reqXP then
		data.Level = (data.Level or 1) +(math.Clamp(math.floor(data.XP /reqXP),1,SF_MAX_LEVEL))
		SF.OnLevelUp(ply,data)
	end
	SF_C.WriteData(fileName,data,true)
end

SF.GetXP = function(ply,isShip)
	local name = GetPlyName(ply)
	if isShip then
		local ship = ply:GetInfo("lfs_sf_ship")
		local data,filename = SF.GetData(ply,ship)

		return data,filename
	end

	local data,filename = SF.GetData(ply,ship)
	return data,filename
end

SF.CalcThirdView = function(self,view,ply)
	local frameTime = FrameTime()
	local FT = frameTime *(GetConVar("lfs_sf_cameraspeed"):GetInt() or 4)

	if IsValid(SF_CAMERA_CURRENT) then
		local targetPos = SF_CAMERA_CURRENT:GetDriverSeat():GetPos()
		if SF_CAMERA_CURRENT.CameraPos && SF_CAMERA_CURRENT.SpawnCameraT == nil then
			SF_CAMERA_CURRENT.SpawnCameraT = CurTime() +(SF_CAMERA_CURRENT.CameraTime or 5)
			SF_CAMERA_CURRENT.viewLerpVec = SF_CAMERA_CURRENT:LocalToWorld(SF_CAMERA_CURRENT.CameraPos.Start)
			SF_CAMERA_CURRENT.viewLerpAng = (targetPos -SF_CAMERA_CURRENT.viewLerpVec):Angle()
			SF_CAMERA_CURRENT.viewIncrease = (GetConVar("lfs_sf_cameraspeed"):GetInt() or 4)
		end
		if SF_CAMERA_CURRENT.SpawnCameraT && CurTime() <= SF_CAMERA_CURRENT.SpawnCameraT then
			FT = frameTime *SF_CAMERA_CURRENT.viewIncrease
			SF_CAMERA_CURRENT.viewIncrease = math.Clamp(SF_CAMERA_CURRENT.viewIncrease +0.01,1,50)
			SF_CAMERA_CURRENT.viewLerpVec = LerpVector(FT,SF_CAMERA_CURRENT.viewLerpVec,SF_CAMERA_CURRENT:LocalToWorld(SF_CAMERA_CURRENT.CameraPos.End))
			SF_CAMERA_CURRENT.viewLerpAng = LerpAngle(FT,SF_CAMERA_CURRENT.viewLerpAng,(targetPos -SF_CAMERA_CURRENT.viewLerpVec):Angle())
			local newView = {}
			newView.origin = SF_CAMERA_CURRENT.viewLerpVec
			newView.angles = SF_CAMERA_CURRENT.viewLerpAng
			return newView
		end
	end
	local pos = view.origin
	local ang = view.angles

	if self.viewLerpVec == nil then
		self.viewLerpVec = self:GetPos() +Vector(0,0,self:OBBMaxs().z)
		self.viewLerpAng = ang
	end

	self.viewLerpVec = LerpVector(FT,self.viewLerpVec,pos)
	self.viewLerpAng = LerpAngle(FT,self.viewLerpAng,ang)

	view.origin = self.viewLerpVec
	view.angles = self.viewLerpAng
	return view
end

local cMat1 = Material("hud/starfox/HUD_Crosshair.png")
local cMat2 = Material("hud/starfox/HUD_Crosshair_Outer.png")
SF.PaintCrosshair = function(self,HitPlane,HitPilot)
	local x,y = HitPlane.x,HitPlane.y
	local x2,y2 = HitPilot.x,HitPilot.y
	local scale = 60
	local col = Color(0,255,63)

	local throttle = self:GetThrottlePercent() *0.01
	local rotor = self:GetRotorPos()
	local warnDist = 6000
	local tr = util.TraceLine({
		start = rotor,
		endpos = rotor +LocalPlayer():GetAngles():Forward() *math.Clamp(warnDist *throttle,1,warnDist *1.25),
		filter = self
	})
	-- LocalPlayer():ChatPrint((warnDist *throttle))
	if tr.HitSky then
		col = Color(255,0,0,math.abs(math.cos(CurTime() *(10 *throttle))) *255)
	end

	surface.SetMaterial(cMat1)
	surface.SetDrawColor(col.r,col.g,col.b,col.a)
	surface.DrawTexturedRectRotated(x,y,scale,scale,0)

	surface.SetMaterial(cMat2)	
	surface.SetDrawColor(col.r,col.g,col.b,col.a)
	surface.DrawTexturedRectRotated(x2 +1,y2 +1,scale,scale,0)
end

SF.PaintInfoLine = function(self,HitPlane,HitPilot,LFS_TIME_NOTIFY,Dir,Len,FREELOOK)
	surface.SetDrawColor(0,255,63,100)
	if Len > 34 then
		local FailStart = LFS_TIME_NOTIFY > CurTime()
		if FailStart then
			surface.SetDrawColor(255,0,0,math.abs(math.cos(CurTime() *10)) *255)
		end
		if not FREELOOK or FailStart then
			surface.DrawLine(HitPlane.x +Dir.x *10,HitPlane.y +Dir.y *10,HitPilot.x -Dir.x *34,HitPilot.y -Dir.y *34)
			surface.SetDrawColor(0,0,0,50)
			surface.DrawLine(HitPlane.x +Dir.x *10 +1,HitPlane.y +Dir.y *10 +1,HitPilot.x -Dir.x *34 +1,HitPilot.y -Dir.y *34 +1)
		end
	end
end

SF.GetLaser = function(ent,tr,repTr1,repTr2)
	if !IsValid(ent) then return end
	local time = ent:GetNW2Int("LaserUpgradeTime") or 0
	local upgrade = ent:GetNW2Int("LaserUpgrade") or 0
	if CurTime() > time then
		upgrade = 0
	end
	local tbl = {}
	tbl.DMG = upgrade == 2 && 2 or upgrade == 1 && 1.5 or 1
	tbl.Effect = upgrade == 2 && (repTr2 or (tr == "lfs_sf_laser_red" && "lfs_sf_laser_purple" or "lfs_sf_laser_red")) or upgrade == 1 && (repTr1 or "lfs_sf_laser_blue") or tr
	tbl.Level = upgrade
	tbl.Time = time -CurTime()

	return tbl
end

SF.SetSmartBombs = function(ent,i)
	if !IsValid(ent) then return end
	ent:SetNW2Int("SmartBombs",i)
end

SF.GetSmartBombs = function(ent)
	if !IsValid(ent) then return end
	local count = ent:GetNW2Int("SmartBombs") or 0
	return count
end

SF.HoverMode = function(self,minDist,str)
	if !IsValid(self) then return end
	if self:GetEngineActive() then /*self:GetPhysicsObject():EnableMotion(true)*/ return end

	local minDist = minDist or 80
	local str = str or 200

	local PhysObj = self:GetPhysicsObject()
	local Mass = PhysObj:GetMass()
	local vel = PhysObj:GetVelocity():Length()
	local tr = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos() +Vector(0,0,-minDist),
		filter = self,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})
	-- local tr = util.TraceLine({
	-- 	start = self:GetPos(),
	-- 	endpos = self:GetPos() +Vector(0,0,-minDist),
	-- 	filter = self
	-- })
	-- Entity(1):ChatPrint(tostring(tr.Hit))
	if tr.Hit then
		PhysObj:SetMass(2)
		PhysObj:ApplyForceCenter(self:GetUp() *(self:WorldToLocal(self:GetPos() +Vector(0,0,Mass *str))))
		-- PhysObj:ApplyForceCenter(self:GetUp() *(self:WorldToLocal(self:GetPos() +Vector(0,0,tr.HitPos:Distance(self:GetPos()) *str))) *Mass)
		-- PhysObj:EnableMotion(false)
	else
		PhysObj:SetMass(self.Mass)
		-- PhysObj:EnableMotion(true)
	end
end

SF.BoneData = function(ent,bone)
	local pos,ang = ent:GetBonePosition(bone)
	local tbl = {}
	tbl.Pos = pos
	tbl.Ang = ang

	return tbl
end

SF.GetVOLine = function(ent,VO)
	if !IsValid(ent) then return end
	local VO = VO or ent:GetNW2String("VO")
	return ent.VO_DeathSound == true && ent.LinesDeath[VO] or ent.Lines[VO]
end

SF.PlayVO = function(ply,snd,VO)
	local snd = VJ_PICK(snd)
	if !snd then return end
	local snddur = SoundDuration(snd) +1
	ply.SF_TalkTexture = Material("hud/starfox/vo_" .. (SF_AI_TRANSLATE_TEXTURE[VO] or VO) .. ".vtf")
	ply.SF_TalkT = CurTime() +snddur
	ply.SF_NextTalkT = ply.SF_TalkT +0.2
	ply.SF_CurrentSound = snd
	ply.SF_CurrentVO = VO

	ply:EmitSound("cpthazama/starfox/64/RadioTransmissionon.wav",110,100,1)
	ply:EmitSound(snd,110,100,1)
	timer.Simple(snddur -0.025,function()
		if IsValid(ply) && ply.SF_CurrentSound == snd then
			ply:EmitSound("cpthazama/starfox/64/RadioTransmissionOff.wav",110,100,1)
		end
	end)
	return snddur
end

SF.PlaySound = function(sndType,ent,snd,vol,pit,delay,cache)
	delay = delay or 0
	vol = vol or 75
	if cache then
		for _,v in pairs(SF.CachedSounds) do
			if v.Name == snd then
				snd = v.Sound
				vol = v.Level
				break
			end
		end
	end
	timer.Simple(delay,function()
		pit = (pit or 100) *VJ_GetVarInt("host_timescale")
		if sndType == 1 && IsValid(ent) then
			return VJ_CreateSound(ent,snd,vol,pit)
		elseif sndType == 2 && IsValid(ent) then
			return VJ_EmitSound(ent,snd,vol,pit)
		elseif sndType == 3 then
			sound.Play(VJ_PICK(snd),type(ent) == "Vector" && ent or (IsValid(ent) && ent:GetPos()) or VJ_Vec0,vol,pit,1)
		end
	end)
end

SF.AddSound = function(name,snd,lvl,chan)
	for _,v in pairs(SF.CachedSounds) do
		if v.Name == name then
			return
		end
	end

	sound.Add({
		name = name,
		channel = chan or CHAN_STATIC,
		volume = 1.0,
		level = lvl or 75,
		sound = snd
	})
	table.insert(SF.CachedSounds,{Name=name,Sound=snd,Level=lvl})
	print("Successfully added sound '" .. name .. "'!")
end

SF.AddSound("LFS_SF_ARWING_ENGINE","cpthazama/starfox/vehicles/arwing_eng_boost_loop.wav",125)
SF.AddSound("LFS_SF_ARWING_ENGINE_NEW","cpthazama/starfox/vehicles/arwing_eng_hd.wav",125)
SF.AddSound("LFS_SF_ARWING_ENGINE2","cpthazama/starfox/vehicles/arwing_eng.wav",90)
SF.AddSound("LFS_SF_ARWING_ENGINE_BOOST","cpthazama/starfox/vehicles/arwing_eng_boost_loop.wav",125)
SF.AddSound("LFS_SF_ARWING_BOOST","cpthazama/starfox/vehicles/arwing_eng_boost_short.wav",125)
SF.AddSound("LFS_SF_ARWING_PRIMARY","cpthazama/starfox/vehicles/arwing_laser_single_hit.wav",95,CHAN_WEAPON)
SF.AddSound("LFS_SF_ARWING_PRIMARY_CHARGED","cpthazama/starfox/vehicles/arwing_fire_charged.wav",95,CHAN_WEAPON)
SF.AddSound("LFS_SF_ARWING_PRIMARY_DOUBLE","cpthazama/starfox/vehicles/arwing_laser_double.wav",95,CHAN_WEAPON)

SF.AddSound("LFS_SF_WOLFEN_ENGINE","cpthazama/starfox/vehicles/arwing_loop_hover.wav",125)
SF.AddSound("LFS_SF_WOLFEN_ENGINE2","cpthazama/starfox/vehicles/wolfen_loop.wav",90)
SF.AddSound("LFS_SF_WOLFEN_BOOST","cpthazama/starfox/vehicles/wolfen_boost2_a.wav",125)
SF.AddSound("LFS_SF_WOLFEN_BOOST2","cpthazama/starfox/vehicles/wolfen_boost.wav",90)

SF.AddSound("LFS_SF_APAROID_MISSILE","cpthazama/starfox/vehicles/se_apa-0003_06.wav",90)

SF.AddSound("LFS_SF_GENERIC_ENGINE","cpthazama/starfox/vehicles/generic_loop.wav",125)
SF.AddSound("LFS_SF_GENERIC_EXPLOSION","cpthazama/starfox/vehicles/laser_hit.wav",125)
SF.AddSound("LFS_SF_GENERIC_EXPLOSION7","cpthazama/starfox/64/Explosion7.wav",125)

SF.AddSound("LFS_SF64_ARWING_ENGINE","cpthazama/starfox/64/vehicles/Engine.wav",125)
SF.AddSound("LFS_SF64_ARWING_BOOST","cpthazama/starfox/64/vehicles/Boost.wav",125)
SF.AddSound("LFS_SF64_ARWING_NITRO","cpthazama/starfox/64/vehicles/ArwingINtro.wav",125)

SF.AddSound("LFS_SF64_WOLFEN_ENGINE","cpthazama/starfox/64/vehicles/Wolfen2.wav",125)
SF.AddSound("LFS_SF64_WOLFEN_BOOST","cpthazama/starfox/64/vehicles/Boost2.wav",125)

SF.AddSound("LFS_SFEH_SHARPCLAW_FIRE","cpthazama/starfox/eh/w_sharpclawhyper1.wav",95,CHAN_WEAPON)
SF.AddSound("LFS_SFEH_SOUL_UP","cpthazama/starfox/eh/w_soulup1.wav",125)

SF.FireProjectile = function(self,ent,pos,lockOn,funcPre,funcPost)
	local startpos = self:GetRotorPos()
	local tr = util.TraceHull({
		start = startpos,
		endpos = (startpos +self:GetForward() *50000),
		mins = Vector(-40,-40,-40),
		maxs = Vector(40,40,40),
		filter = function(e)
			local collide = e != self
			return collide
		end
	})
	
	local ent = ents.Create(ent)
	if !IsValid(ent) then return end
	ent:SetPos(pos)
	ent:SetAngles(self:GetAngles())
	if funcPre then funcPre(ent) end
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker(self:GetDriver())
	ent:SetInflictor(self)
	ent:SetStartVelocity(self:GetVelocity():Length())
	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetVelocity(self:GetVelocity() +self:GetForward() *300)
	end
	if funcPost then funcPost(ent) end

	constraint.NoCollide(ent,self,0,0)

	if !lockOn then return end
	if self:GetAI() then
		local enemy = self:AIGetTarget() or SF.FindEnemy(self)
		if IsValid(enemy) then
			if enemy.GetDriverSeat then -- Must be a LFS or Simfphys entity
				ent:SetLockOn(enemy)
				ent:SetStartVelocity(0)
			end
		end
	else
		if tr.Hit then
			local Target = tr.Entity
			if IsValid(Target) then
				if Target.GetDriverSeat && Target != self then
					ent:SetLockOn(Target)
					ent:SetStartVelocity(0)
				end
			end
		end
	end
end

SF.ForceVOSound = function(ply,self,snd,VO)
	local function PlaySound(ply)
		local plyTeam = ply:lfsGetAITeam()
		local team = self:GetNW2Int("Team")
		local reqTeam = GetConVar("lfs_sf_voteams"):GetBool()
		if self:GetAI() && (reqTeam && team != plyTeam or true) then
			local snddur = SF.PlayVO(ply,snd,VO)
			if snddur == nil then return end
			ply.SF_CurrentVOEntity = self
			self.SF_NextTalkT = CurTime() +snddur +math.Rand(15,40)
		end
	end

	if ply then
		PlaySound(ply)
	else
		for _,ply in RandomPairs(player.GetAll()) do
			PlaySound(ply)
		end
	end
end

SF.OnDamage = function(self,dmginfo)
	-- if self.PilotCode && self:GetAI() then
	-- 	local VO = self:GetNW2String("VO")
	-- 	print(VO,self)
	-- 	if VO && self.LinesPain && self.LinesPain[VO] then
	-- 		SF.ForceVOSound(nil,self,self.LinesPain[VO],VO)
	-- 	end
	-- end
end

SF.Destroy = function(self)
	self.Destroyed = true
	
	local PObj = self:GetPhysicsObject()
	if IsValid(PObj) then
		PObj:SetDragCoefficient(-20)
	end

	local ai = self:GetAI()
	if !ai then return end

	local attacker = self.FinalAttacker or Entity(0)
	local inflictor = self.FinalInflictor or Entity(0)
	if attacker:IsPlayer() then attacker:AddFrags(1) end
	gamemode.Call("OnNPCKilled",self,attacker,inflictor)
end

SF.OnDestroyed = function(self,spawnChance)
	if !IsValid(self) then return end

	if math.random(1,spawnChance) == 1 then
		local p = VJ_PICK({
			"lfs_starfox_upgrade_blue",
			"lfs_starfox_upgrade_blue",
			"lfs_starfox_upgrade_red",
			"lfs_starfox_upgrade_smartbomb",
			"lfs_starfox_upgrade_smartbomb",
			"lfs_starfox_upgrade_smartbomb",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_silver",
			"lfs_starfox_upgrade_gold",
			"lfs_starfox_upgrade_gold",
			"lfs_starfox_upgrade_gold",
		})
		local item = ents.Create(p)
		if !IsValid(item) then return end
		item:SetPos(self:GetPos())
		item:Spawn()
		timer.Simple(30,function()
			SafeRemoveEntity(item)
		end)
	end
end

SF.OnTakeDamage = function(self,dmginfo)
	if self.GetInvincible && self:GetInvincible() then return end
	self:TakePhysicsDamage( dmginfo )

	self:StopMaintenance()

	local Damage = dmginfo:GetDamage()
	local CurHealth = self:GetHP()
	local NewHealth = math.Clamp( CurHealth - Damage , -self:GetMaxHP(), self:GetMaxHP() )
	local ShieldCanBlock = dmginfo:IsBulletDamage() or dmginfo:IsDamageType( DMG_AIRBOAT )

	if ShieldCanBlock then
		local dmgNormal = -dmginfo:GetDamageForce():GetNormalized() 
		local dmgPos = dmginfo:GetDamagePosition()

		self:SetNextShieldRecharge( 3 )

		if self:GetMaxShield() > 0 and self:GetShield() > 0 then
			dmginfo:SetDamagePosition( dmgPos + dmgNormal * 250 * self:GetShieldPercent() )

			local effectdata = EffectData()
				effectdata:SetOrigin( dmginfo:GetDamagePosition() )
				effectdata:SetEntity( self )
			util.Effect(self.ShieldEffect or "lfs_sf_shield_corneria", effectdata )

			self:TakeShieldDamage( Damage )
		else
			sound.Play( Sound( table.Random( {"physics/metal/metal_sheet_impact_bullet2.wav","physics/metal/metal_sheet_impact_hard2.wav","physics/metal/metal_sheet_impact_hard6.wav",} ) ), dmgPos, SNDLVL_70dB)
	
			local effectdata = EffectData()
				effectdata:SetOrigin( dmgPos )
				effectdata:SetNormal( dmgNormal )
			util.Effect( "MetalSpark", effectdata )
			
			self:SetHP( NewHealth )
		end
	else
		self:SetHP( NewHealth )
	end

	SF.OnDamage(self,dmginfo)
	
	if NewHealth <= 0 and not (self:GetShield() > Damage and ShieldCanBlock) then
		if not self:IsDestroyed() then
			self.FinalAttacker = dmginfo:GetAttacker() 
			self.FinalInflictor = dmginfo:GetInflictor()

			self:Destroy()
			
			self.MaxPerfVelocity = self.MaxPerfVelocity * 10
			local ExplodeTime = self:IsSpaceShip() and (math.Clamp((self:GetVelocity():Length() - 250) / 500,1.5,8) * math.Rand(0.2,1)) or (self:GetAI() and 30 or 9999)
			if self:IsGunship() then ExplodeTime = math.Rand(1,2) end

			local effectdata = EffectData()
				effectdata:SetOrigin( self:GetPos() )
			util.Effect( "lfs_explosion_nodebris", effectdata )

			local effectdata = EffectData()
				effectdata:SetOrigin( self:GetPos() )
				effectdata:SetStart( self:GetPhysicsObject():GetMassCenter() )
				effectdata:SetEntity( self )
				effectdata:SetScale( 1 )
				effectdata:SetMagnitude( ExplodeTime )
			util.Effect( "lfs_firetrail", effectdata )

			timer.Simple( ExplodeTime, function()
				if not IsValid( self ) then return end
				self:Explode()
			end)
		end
	end

	if NewHealth <= -self:GetMaxHP() then
		self:Explode()
	end
end

SF.FindEnemy = function(self)
	if !IsValid(self) then return NULL end

	self.NextAICheck = self.NextAICheck or 0
	
	if self.NextAICheck > CurTime() then return self.LastTarget end
	
	self.NextAICheck = CurTime() + 2
	
	local MyPos = self:GetPos()
	local MyTeam = self:GetAITEAM()

	if MyTeam == 0 then self.LastTarget = NULL return NULL end

	local players = player.GetAll()

	local ClosestTarget = NULL
	local TargetDistance = 60000

	if not simfphys.LFS.IgnorePlayers then
		for _,v in pairs(players) do
			if IsValid(v) then
				if v:Alive() then
					local Dist = (v:GetPos() - MyPos):Length()
					if Dist < TargetDistance then
						local Plane = v:lfsGetPlane()
						
						if IsValid(Plane) then
							-- if self:CanSee(Plane) and not Plane:IsDestroyed() and Plane != self then
							if self:Visible(Plane) and not Plane:IsDestroyed() and Plane != self then
								local HisTeam = Plane:GetAITEAM()
								if HisTeam != 0 && (HisTeam != MyTeam or HisTeam == 3) then
									ClosestTarget = v
									TargetDistance = Dist
								end
							end
						else
							local HisTeam = v:lfsGetAITeam()
							if v:IsLineOfSightClear(self) && HisTeam != 0 && (HisTeam != MyTeam or HisTeam == 3) then
								ClosestTarget = v
								TargetDistance = Dist
							end
						end
					end
				end
			end
		end
	end

	if not simfphys.LFS.IgnoreNPCs then
		for _,v in pairs(self:AIGetNPCTargets()) do
			if IsValid(v) then
				local HisTeam = self:AIGetNPCRelationship(v:GetClass())
				if HisTeam != "0" then
					if HisTeam != MyTeam or HisTeam == 3 then
						local Dist = (v:GetPos() - MyPos):Length()
						if Dist < TargetDistance then
							-- if self:CanSee(v) then
							if self:Visible(v) then
								ClosestTarget = v
								TargetDistance = Dist
							end
						end
					end
				end
			end
		end
	end

	self.FoundPlanes = simfphys.LFS:PlanesGetAll()
	
	for _,v in pairs(self.FoundPlanes) do
		if IsValid(v) and v != self and v.LFS then
			local Dist = (v:GetPos() - MyPos):Length()
			if Dist < TargetDistance /*and self:AITargetInfront(v,100)*/ then
				if not v:IsDestroyed() and v.GetAITEAM then
					local HisTeam = v:GetAITEAM()
					if HisTeam != 0 && (HisTeam != self:GetAITEAM() or HisTeam == 3) then
						-- if self:CanSee(v) then -- This function 9/10 times can never return true,if we use default Visible() function then they see enemies 10x better and its much more optimized than running hull traces
						if self:Visible(v) then
							-- print(tostring(self) .. " Found plane: " .. tostring(v))
							ClosestTarget = v
							TargetDistance = Dist
						end
					end
				end
			end
		end
	end

	self.LastTarget = ClosestTarget
	
	return ClosestTarget
end

SF.AddAI = function(name,ent,att)
	local index = #SF.AITurrets +1
	SF.AITurrets[index] = {}
	SF.AITurrets[index].Name = name
	SF.AITurrets[index].Ship = ent
	SF.AITurrets[index].Attachment = att
	SF.AITurrets[index].Enemy = NULL

	local hookName = "LFS_StarFox_TurretAI_" .. name .. "_" .. ent:EntIndex()
	hook.Add("Think",hookName,function()
		if !IsValid(ent) then
			hook.Remove("Think",hookName)
			return
		end

		-- local self = NULL
		-- for _,v in pairs(SF.AITurrets) do
		-- 	if v.Name == name then
		-- 		self = v
		-- 		print("FOUND " .. tostring(v))
		-- 		break
		-- 	end
		-- end
		local self = SF.AITurrets[index] && SF.AITurrets[index].Name == name && SF.AITurrets[index] or nil
		if self == nil then hook.Remove("Think",hookName) return end

		local hasAI = ent:GetAI()
		if !hasAI then return end -- Don't run the code if a player is driving the ship
		local pos = ent:GetAttachment(att).Pos
		local dist = GetConVar("lfs_bullet_max_range"):GetInt()
		local team = ent:GetAITEAM()

		if team == 0 then self.Enemy = NULL end

		local players = player.GetAll()
		local ClosestTarget = NULL
		local TargetDistance = 60000

		if not simfphys.LFS.IgnorePlayers then
			for _,v in pairs(players) do
				if IsValid(v) then
					if v:Alive() then
						local Dist = (v:GetPos() - pos):Length()
						if Dist < TargetDistance then
							local Plane = v:lfsGetPlane()
							
							if IsValid(Plane) then
								if ent:Visible(Plane) and not Plane:IsDestroyed() and Plane != ent then
									local HisTeam = Plane:GetAITEAM()
									if HisTeam != 0 then
										if HisTeam != team or HisTeam == 3 then
											ClosestTarget = v
											TargetDistance = Dist
										end
									end
								end
							else
								local HisTeam = v:lfsGetAITeam()
								if v:IsLineOfSightClear(ent) then
									if HisTeam != 0 then
										if HisTeam != team or HisTeam == 3 then
											ClosestTarget = v
											TargetDistance = Dist
										end
									end
								end
							end
						end
					end
				end
			end
		end

		ent.FoundPlanes = simfphys.LFS:PlanesGetAll()
		
		for _,v in pairs(ent.FoundPlanes) do
			if IsValid(v) and v != ent and v.LFS then
				local Dist = (v:GetPos() - pos):Length()
				
				if Dist < TargetDistance and ent:AITargetInfront(v,100) then
					if not v:IsDestroyed() and v.GetAITEAM then
						local HisTeam = v:GetAITEAM()
						if HisTeam != 0 then
							if HisTeam != team or HisTeam == 3 then
								if ent:Visible(v) then
									ClosestTarget = v
									TargetDistance = Dist
								end
							end
						end
					end
				end
			end
		end

		self.Enemy = ClosestTarget

		if ent.TurretAI then
			ent:TurretAI(self.Enemy,att,pos) -- (Enemy,Turret Index,Position)
		else -- Default AI
			if IsValid(self.Enemy) then
				ent:FireTurret(att,self.Enemy:GetPos() +self.Enemy:OBBCenter())
			end
		end
	end)
end

print("Successfully Loaded [LFSimfphys] Star Fox Functions file!")