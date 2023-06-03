--!strict
--Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Packages
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

--Modules
local Pet = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Pet"))
local Cat = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Cat"))
local Dog = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Dog"))
local Mouse = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Pets"):WaitForChild("Mouse"))

--Types
type Maid = Maid.Maid
export type Pet = Pet.Pet
export type PetData = Pet.PetData

return {
	Cat = Cat :: Cat.Cat,
	Dog = Dog :: Dog.Dog,
	Mouse = Mouse :: Mouse.Mouse,
	init = function(maid: Maid)
		Pet.init(maid)
		Cat.init(maid)
		Dog.init(maid)
		Mouse.init(maid)
	end,
	get = Pet.get,
	hatch = Pet.hatch,
	getPets = Pet.getPets,
	getById = Pet.getById,
	clear = Pet.clear,
}
