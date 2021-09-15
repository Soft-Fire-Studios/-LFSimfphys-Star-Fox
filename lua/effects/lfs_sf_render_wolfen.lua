local Mat = "effects/starfox/render_wolfen"
local MatColor = Color(255,255,255)

function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	self.LifeTime = data:GetAttachment() or 1
	
	self.DieTime = CurTime() +self.LifeTime
	
	if IsValid(self.Ent) then
		self.Model = ClientsideModel(self.Ent:GetModel(),RENDERMODE_TRANSCOLOR)
		self.Model:SetMaterial(Mat or "models/alyx/emptool_glow")
		self.Model:SetColor(MatColor)
		self.Model:SetParent(self.Ent,0)
		self.Model:SetMoveType(MOVETYPE_NONE)
		self.Model:SetLocalPos(Vector(0,0,0))
		self.Model:SetLocalAngles(Angle(0,0,0))
		self.Model:AddEffects(EF_BONEMERGE)
	end
end

function EFFECT:Think()
	if IsValid(self.Model) then
		self.Model:SetColor(Color(MatColor.r,MatColor.g,MatColor.b,(self.DieTime /CurTime()) *255))
	end
	if not IsValid(self.Ent) then
		if IsValid(self.Model) then
			self.Model:Remove()
		end
	end

	if self.DieTime < CurTime() then 
		if IsValid(self.Model) then
			self.Model:Remove()
		end

		return false
	end
	
	return true
end

function EFFECT:Render()

end