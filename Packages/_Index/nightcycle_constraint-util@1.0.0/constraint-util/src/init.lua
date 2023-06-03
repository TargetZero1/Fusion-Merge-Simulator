--!strict
--Services
--Packages
local Package = script
local Packages = Package.Parent
local Maid = require(Packages:WaitForChild("Maid"))

--Modules
--Types
type Maid = Maid.Maid
--Constants
--Class
local Util = {}

function Util.getAttachment(part: BasePart, maid: Maid?): Attachment
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	attachment.WorldCFrame = part:GetPivot()
	attachment.Name = "Attachment"

	if maid then
		maid:GiveTask(attachment)
	end

	return attachment
end

function Util.getAttachments(part0: BasePart, part1: BasePart, maid: Maid?): (Attachment, Attachment)
	local attachment0 = Util.getAttachment(part0, maid)
	attachment0.Name ..= "0"

	local attachment1 = Util.getAttachment(part1, maid)
	attachment1.Name ..= "1"

	return attachment0, attachment1
end

function Util.getWeld(part0: BasePart, part1: BasePart, maid: Maid?): WeldConstraint

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part0
	weldConstraint.Part1 = part1
	weldConstraint.Parent = part0

	if maid then
		maid:GiveTask(weldConstraint)
	end

	return weldConstraint
end

function Util.getBodyGyro(
	part: BasePart, 
	damping: number, 
	power: number, 
	maxTorque: Vector3, 
	initialCF: CFrame, 
	maid: Maid?
): BodyGyro
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.CFrame = initialCF
	bodyGyro.D = damping
	bodyGyro.P = power
	bodyGyro.MaxTorque = maxTorque
	bodyGyro.Parent = part

	if maid then
		maid:GiveTask(bodyGyro)
	end

	return bodyGyro
end

function Util.getBodyPosition(
	part: BasePart, 
	damping: number, 
	power: number, 
	maxForce: Vector3, 
	initialPosition: Vector3, 
	maid: Maid?
): BodyPosition
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Position = initialPosition
	bodyPosition.D = damping
	bodyPosition.P = power
	bodyPosition.MaxForce = maxForce
	bodyPosition.Parent = part

	if maid then
		maid:GiveTask(bodyPosition)
	end

	return bodyPosition
end


return Util

