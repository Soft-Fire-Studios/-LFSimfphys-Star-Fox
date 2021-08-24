if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Base 						= "weapon_vj_base"
SWEP.PrintName					= "Gatling Gun"
SWEP.Author 					= "Cpt. Hazama"
SWEP.Contact					= "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose					= "This weapon is made for Players and NPCs"
SWEP.Instructions				= "Controls are like a regular weapon."
SWEP.Category					= "Star Fox"

	-- Client Settings ---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
SWEP.Slot						= 3 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6) 
SWEP.SlotPos					= 3 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.UseHands					= true
SWEP.ViewModelFOV = 85
end
	-- NPC Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_NextPrimaryFire 		= 0.3 -- Next time it can use primary fire
SWEP.NPC_ReloadSound			= {"vj_weapons/blaster/blaster_reload.wav"} -- Sounds it plays when the base detects the SNPC playing a reload animation
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModel					= "models/cpthazama/starfox/weapons/c_gatlinggun.mdl"
SWEP.WorldModel					= "models/cpthazama/starfox/weapons/w_gatlinggun.mdl"
SWEP.HoldType 					= "passive"
SWEP.Spawnable					= true
SWEP.AdminSpawnable				= false
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Damage				= 9 -- Damage
SWEP.Primary.Force				= 15 -- Force applied on the object the bullet hits
SWEP.Primary.ClipSize			= 500 -- Max amount of bullets per clip
SWEP.Primary.Recoil				= 0.5 -- How much recoil does the player get?
SWEP.Primary.Delay				= 0.05 -- Time until it can shoot again
SWEP.Primary.TracerType			= "lfs_sf_laser_blue" -- Tracer type (Examples: AR2, laster, 9mm)
SWEP.Primary.Automatic			= true -- Is it automatic?
SWEP.Primary.Ammo				= "AR2" -- Ammo type
SWEP.Primary.Sound				= {"cpthazama/starfox/vehicles/arwing_laser_single_hit.wav"} -- npc/roller/mine/rmine_explode_shock1.wav
SWEP.Primary.DistantSound		= {"cpthazama/starfox/ssbu/se_wolf_special_N01.wav"} -- npc/roller/mine/rmine_explode_shock1.wav
SWEP.Primary.HasDistantSound	= true -- Does it have a distant sound when the gun is shot?
SWEP.PrimaryEffects_MuzzleParticles = {"vj_rifle_smoke"}
SWEP.PrimaryEffects_MuzzleParticlesAsOne = true -- If set to true, the base will spawn all the given particles instead of picking one
SWEP.PrimaryEffects_MuzzleAttachment = "muzzle"
SWEP.PrimaryEffects_SpawnShells = false
SWEP.PrimaryEffects_DynamicLightColor = Color(0, 132, 255)
SWEP.Primary.DisableBulletCode = true
	-- Deployment Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.DelayOnDeploy 				= 1 -- Time until it can shoot again after deploying the weapon
	-- Reload Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasReloadSound				= true -- Does it have a reload sound? Remember even if this is set to false, the animation sound will still play!
SWEP.ReloadSound				= {"vj_weapons/blaster/blaster_reload.wav"}
SWEP.Reload_TimeUntilAmmoIsSet	= 3.2 -- Time until ammo is set to the weapon
SWEP.Reload_TimeUntilFinished	= false -- How much time until the player can play idle animation, shoot, etc.
	-- Idle Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasIdleAnimation			= true -- Does it have a idle animation?
SWEP.AnimTbl_Idle				= {ACT_VM_IDLE}
SWEP.NextIdle_Deploy			= 0.7 -- How much time until it plays the idle animation after the weapon gets deployed
SWEP.AnimTbl_PrimaryFire = {ACT_VM_RECOIL1}
SWEP.NextIdle_PrimaryAttack		= 0.15 -- How much time until it plays the idle animation after attacking(Primary)
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Aiming = false
SWEP.AnimT = 0

SWEP.WorldModel_UseCustomPosition = true -- Should the gun use custom position? This can be used to fix guns that are in the crotch
SWEP.WorldModel_CustomPositionAngle = Vector(-10,0,180)
SWEP.WorldModel_CustomPositionOrigin = Vector(5,32,0)
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	local def = Vector(0,0,0)
	local def2 = Angle(0,0,0)
	local lerpAng = def
	local lerpVec = def
	local lerpRot = def2
	function SWEP:CustomOnDrawWorldModel()
		local ply = self:GetOwner()
		local FT = FrameTime() *8
		local fireTime = self:GetNW2Int("Fire")
		self.CurTurn = self.CurTurn or 0

		if self:GetNW2Bool("Aiming") == false then
			lerpVec = LerpVector(FT,lerpVec,Vector(2,20,-5))
			lerpAng = LerpVector(FT,lerpAng,Vector(-120,30,100))
		else
			lerpVec = LerpVector(FT,lerpVec,Vector(5,32,0))
			lerpAng = LerpVector(FT,lerpAng,Vector(-10,0,180))
		end

		local cur = lerpRot
		if CurTime() < fireTime then
			self.CurTurn = self.CurTurn +1
			if self.CurTurn >= 360 then
				self.CurTurn = 0
			end
			lerpRot = LerpAngle(FT,lerpRot,Angle(self.CurTurn,0,0))
		-- else
			-- lerpRot = LerpAngle(FT,lerpRot,Angle(cur *0.95,0,0))
		end

		self:ManipulateBoneAngles(1,lerpRot)

		self.WorldModel_CustomPositionAngle = lerpAng
		self.WorldModel_CustomPositionOrigin = lerpVec
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnInitialize()
	self:SetNW2Bool("Aiming",false)
	self:SetNW2Int("Fire",0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_AfterShoot()
	local owner = self:GetOwner()
	local isNPC = owner:IsNPC()
	local bullet = {}
		bullet.Num = self.Primary.NumberOfShots
		bullet.Tracer = self.Primary.Tracer
		bullet.TracerName = self.Primary.TracerType
		bullet.Force = self.Primary.Force
		local aimVec = owner:GetAimVector()
		bullet.Dir = aimVec +Vector(0,0,aimVec.z *0.1)
		bullet.AmmoType = self.Primary.Ammo
		bullet.Src = isNPC && self:GetNW2Vector("VJ_CurBulletPos") or owner:GetShootPos() -- Spawn Position
		
		if !isNPC then
			bullet.Spread = Vector((self.Primary.Cone / 60) / 4, (self.Primary.Cone / 60) / 4, 0)
			if self.Primary.PlayerDamage == "Same" then
				bullet.Damage = self.Primary.Damage
			elseif self.Primary.PlayerDamage == "Double" then
				bullet.Damage = self.Primary.Damage * 2
			elseif isnumber(self.Primary.PlayerDamage) then
				bullet.Damage = self.Primary.PlayerDamage
			end
		else
			if owner.IsVJBaseSNPC == true then
				bullet.Damage = owner:VJ_GetDifficultyValue(self.Primary.Damage)
			else
				bullet.Damage = self.Primary.Damage
			end
		end
	owner:FireBullets(bullet)

	self.AnimT = CurTime() +0.75
	self:SetNW2Int("Fire",CurTime() +2.5)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnReload()
	self.AnimT = CurTime() +3.2
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CanSecondaryAttack()
	if CurTime() < self.AnimT then return false end
	self.Aiming = !self.Aiming
	self:SendWeaponAnim(self.Aiming && ACT_VM_THROW or ACT_VM_PULLBACK)
	self.AnimT = CurTime() +1.25
	self:SetNW2Bool("Aiming",self.Aiming)
	self:SetHoldType(self.Aiming && "crossbow" or self.HoldType)
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnThink()
	if CLIENT then return end
	local owner = self:GetOwner()
	if IsValid(owner) && owner:IsPlayer() then
		local vm = owner:GetViewModel()

		self.IdleType = self.Aiming && ACT_VM_RECOIL2 or ACT_VM_IDLE
		if self.IdleType != self.LastIdleType && !self.Reloading && CurTime() > self.AnimT then
			self.LastIdleType = self.IdleType
			self.AnimTbl_Idle = {self.IdleType}
			self:DoIdleAnimation()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_BeforeShoot()
	if !self.Aiming then return true end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnHolster(newWep)
	self:SetNW2Bool("Aiming",false)
	return true
end -- Return false to disallow the weapon from switching
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnRemove()
	self:SetNW2Bool("Aiming",false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Reload()
	if !IsValid(self) then return end
	local owner = self:GetOwner()
	if !IsValid(owner) or !owner:IsPlayer() or !owner:Alive() or owner:GetAmmoCount(self.Primary.Ammo) == 0 or !owner:KeyDown(IN_RELOAD) or self.Reloading == true then return end
	if self.Aiming then return end
	if self:Clip1() < self.Primary.ClipSize then
		self.Reloading = true
		self:CustomOnReload()
		if SERVER && self.HasReloadSound == true then owner:EmitSound(VJ_PICK(self.ReloadSound), 50, math.random(90, 100)) end
		-- Handle clip
		timer.Simple(self.Reload_TimeUntilAmmoIsSet, function()
			if IsValid(self) then
				local ammoUsed = math.Clamp(self.Primary.ClipSize - self:Clip1(), 0, owner:GetAmmoCount(self:GetPrimaryAmmoType())) -- Amount of ammo that it will use (Take from the reserve)
				owner:RemoveAmmo(ammoUsed, self.Primary.Ammo)
				self:SetClip1(ammoUsed + self:Clip1())
			end
		end)
		-- Handle animation
		local anim = VJ_PICK(self.AnimTbl_Reload)
		self:SendWeaponAnim(anim)
		owner:SetAnimation(PLAYER_RELOAD)
		timer.Simple((self.Reload_TimeUntilFinished == false && VJ_GetSequenceDuration(owner:GetViewModel(), anim)) or self.Reload_TimeUntilFinished, function()
			if IsValid(self) then
				self.Reloading = false
				self:DoIdleAnimation()
			end
		end)
		return true
	end
end