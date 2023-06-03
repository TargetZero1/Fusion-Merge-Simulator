--!strict
--Services
--Packages
local Package = script
local Packages = Package.Parent
local _GeometryUtil = require(Packages:WaitForChild("GeometryUtil"))
--Modules
--Types
--Constants
--Class
local Util = {}

function Util.setOrientation(cf: CFrame, orientation: CFrame)
	return CFrame.fromMatrix(
		cf.Position,
		orientation.XVector,
		orientation.YVector,
		orientation.ZVector
	)
end

function Util.setPosition(cf: CFrame, position: Vector3): CFrame
	return CFrame.fromMatrix(
		position,
		cf.XVector,
		cf.YVector,
		cf.ZVector
	)
end

function Util.setScale(cf: CFrame, scale: number): CFrame
	return CFrame.fromMatrix(
		cf.Position * scale,
		cf.XVector,
		cf.YVector,
		cf.ZVector
	)
end

function Util.fromVectors(position: Vector3, right: Vector3, up: Vector3, look: Vector3): CFrame
	look = look.Unit
	right = right.Unit
	up = up.Unit
	local r20, r21, r22 = -look.X, -look.Y, -look.Z
	local r00, r01, r02 = right.X, right.Y, right.Z
	local r10, r11, r12 = up.X, up.Y, up.Z
	local x,y,z = position.X, position.Y, position.Z
	return CFrame.new(x,y,z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
end

return Util

