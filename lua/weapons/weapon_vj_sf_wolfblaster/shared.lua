if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Base 						= "weapon_vj_base"
SWEP.PrintName					= "Wolf's Blaster"
SWEP.Author 					= "Cpt. Hazama"
SWEP.Contact					= "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose					= "This weapon is made for Players and NPCs"
SWEP.Instructions				= "Controls are like a regular weapon."
SWEP.Category					= "Star Fox"

	-- Client Settings ---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
SWEP.Slot						= 1 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6) 
SWEP.SlotPos					= 3 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.UseHands					= true
SWEP.ViewModelFOV = 44
end
	-- NPC Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_NextPrimaryFire 		= 0.3 -- Next time it can use primary fire
SWEP.NPC_ReloadSound			= {"vj_weapons/blaster/blaster_reload.wav"} -- Sounds it plays when the base detects the SNPC playing a reload animation
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModel					= "models/cpthazama/starfox/weapons/c_blaster_wolf.mdl"
SWEP.WorldModel					= "models/cpthazama/starfox/weapons/w_blaster_wolf.mdl"
SWEP.HoldType 					= "pistol"
SWEP.Spawnable					= true
SWEP.AdminSpawnable				= false
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Damage				= 18 -- Damage
SWEP.Primary.Force				= 15 -- Force applied on the object the bullet hits
SWEP.Primary.ClipSize			= 22 -- Max amount of bullets per clip
SWEP.Primary.Recoil				= 3 -- How much recoil does the player get?
SWEP.Primary.Delay				= 0.15 -- Time until it can shoot again
SWEP.Primary.TracerType			= "lfs_sf_laser_purple" -- Tracer type (Examples: AR2, laster, 9mm)
SWEP.Primary.Automatic			= false -- Is it automatic?
SWEP.Primary.Ammo				= "AR2" -- Ammo type
SWEP.Primary.Sound				= {"cpthazama/starfox/ssbu/se_wolf_special_L01.wav"} -- npc/roller/mine/rmine_explode_shock1.wav
SWEP.Primary.DistantSound		= {"cpthazama/starfox/ssbu/se_wolf_special_N01.wav"} -- npc/roller/mine/rmine_explode_shock1.wav
SWEP.Primary.HasDistantSound	= true -- Does it have a distant sound when the gun is shot?
SWEP.PrimaryEffects_MuzzleParticles = {"vj_rifle_smoke"}
SWEP.PrimaryEffects_MuzzleParticlesAsOne = true -- If set to true, the base will spawn all the given particles instead of picking one
SWEP.PrimaryEffects_MuzzleAttachment = "muzzle"
SWEP.PrimaryEffects_SpawnShells = false
SWEP.PrimaryEffects_DynamicLightColor = Color(212, 0, 255)
	-- Deployment Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.DelayOnDeploy 				= 0.7 -- Time until it can shoot again after deploying the weapon
	-- Reload Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasReloadSound				= true -- Does it have a reload sound? Remember even if this is set to false, the animation sound will still play!
SWEP.ReloadSound				= {"vj_weapons/blaster/blaster_reload.wav"}
SWEP.Reload_TimeUntilAmmoIsSet	= 2.1 -- Time until ammo is set to the weapon
SWEP.Reload_TimeUntilFinished	= false -- How much time until the player can play idle animation, shoot, etc.
	-- Idle Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasIdleAnimation			= true -- Does it have a idle animation?
SWEP.AnimTbl_Idle				= {ACT_VM_IDLE}
SWEP.NextIdle_Deploy			= 0.7 -- How much time until it plays the idle animation after the weapon gets deployed
SWEP.AnimTbl_PrimaryFire = {ACT_VM_RECOIL1}
SWEP.NextIdle_PrimaryAttack		= 0.15 -- How much time until it plays the idle animation after attacking(Primary)
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.ChargeT = 0
SWEP.Inspecting = false
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_AfterShoot()
	self.ChargeT = CurTime() +3
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnThink()
	if CLIENT then return end
	local owner = self:GetOwner()
	if IsValid(owner) && owner:IsPlayer() then
		local clip1 = self:Clip1()
		if CurTime() > self.ChargeT && clip1 > 0 && clip1 < self.Primary.ClipSize && !self.Reloading then
			self:SetClip1(clip1 +1)
			self.ChargeT = CurTime() +0.25
		end

		local vm = owner:GetViewModel()
		if owner:KeyDown(IN_RELOAD) && !self.Reloading && clip1 >= self.Primary.ClipSize && !self.Inspecting then
			local anim = VJ_PICK({VJ_SequenceToActivity(vm, "inspect1"),VJ_SequenceToActivity(vm, "inspect2")})
			self:SendWeaponAnim(anim)
			self.Inspecting = true
			timer.Simple((VJ_GetSequenceDuration(vm, anim)),function()
				if IsValid(self) && !self.Reloading && self.Inspecting then
					self.Inspecting = false
					self:DoIdleAnimation()
				end
			end)
		end

		self.IdleType = (owner:GetVelocity():Length() > (owner:KeyDown(IN_WALK) && 0 or 50) && ((owner:KeyDown(IN_WALK) && 1) or 2)) or 0
		if self.IdleType != self.LastIdleType && !self.Reloading then
			self.Inspecting = false
			self.LastIdleType = self.IdleType
			local anim = (self.IdleType == 0 && ACT_VM_IDLE) or (self.IdleType == 1 && VJ_SequenceToActivity(vm, "walk") or VJ_SequenceToActivity(vm, "sprint"))
			self.AnimTbl_Idle = {anim}
			self:DoIdleAnimation()
		end
	end
end