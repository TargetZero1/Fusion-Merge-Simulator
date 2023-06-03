--!strict

-- local dogToCatRigTranslations = {
-- 	["HumainoidRootPart"] = "Jnt_Humainoid_Root_Bone",
-- 	["Hips"] = "Jnt_Hips",
-- 	["LeftLowerLeg"] = "Jnt_Left_Lower_Leg",
-- 	["RightLowerLeg"] = "Jnt_Right_Lower_Leg",
-- 	["LowerBack"] = "Jnt_Lower_Back",
-- 	["Tail_B"] = "Jnt_Upper_Tail",
-- 	["MidBack"] = "Jnt_Mid_Back",
-- 	["UpperBack"] = "Jnt_UpperBack",
-- 	["Head_B"] = "Jnt_Head",
-- 	["LeftUpperLeg"] = "Jnt_Left_Upper_Leg",
-- 	["RightUpperLeg"] = "Jnt_Right_Upper_Leg",
-- 	["LeftLowerEar"] = "Jnt_Left_Lower_Ear",
-- 	["RightLowerEar"] = "Jnt_Right_Lower_Ear",
-- 	["LeftUpperEar"] = "Jnt_Left_Mid_Ear",
-- 	["RightUpperEar"] = "Jnt_Right_Mid_Ear",
-- }
-- function convertRig(model: Model)
-- 	for i, v in ipairs(model:GetDescendants()) do
-- 		if v:IsA("Bone") then
-- 			if dogToCatRigTranslations[v.Name] then
-- 				v.Name = dogToCatRigTranslations[v.Name]
-- 			end
-- 		end
-- 	end
-- 	return nil
-- end
-- function formatDogRigs()
-- 	for i, model in ipairs(workspace.Rigs.Dog:GetChildren()) do
-- 		convertRig(model)
-- 	end
-- end

-- formatDogRigs()

local blockLevelProfitList: { [number]: number } = {}
for i = 1, 48 do
	blockLevelProfitList[i] = 2 ^ i
end

local miscLists = {
	AssetIdLists = {
		AnimationIds = {
			Kick = "http://www.roblox.com/asset/?id=12659697520",
			Pet = "http://www.roblox.com/asset/?id=12954192056",
		},
		ImageIds = {
			EggImage = "rbxassetid://7106672194",
			LightFlash = "rbxassetid://7928096707",
			MouseCursor = "rbxassetid://284663799",
			CashImage = "rbxassetid://11317293769",
			--perks
			CashPerk = "",
			GemsPerk = "",
			PetEquip = "",

			--Menu Options
			IndexIcon = "rbxassetid://13393642617",
			PetInventoryIcon = "rbxassetid://13393642409",
			SettingsIcon = "rbxassetid://13393642154",
			ShopIcon = "rbxassetid://13393641961",
		},
		SoundIds = {
			ExplosionSound = "rbxassetid://6290067239",
			ClickSound = "rbxassetid://6652808984",
			KickSound = "rbxassetid://621571142",

			Success = "rbxassetid://3997124966",
			Fail = "rbxassetid://2390695935",
		},
		TextureIds = {
			BlockLevel1 = "rbxassetid://13182313805",
			BlockLevel2 = "rbxassetid://13182395647",
			BlockLevel3 = "rbxassetid://13182395427",
			BlockLevel4 = "rbxassetid://13182394767",
			BlockLevel5 = "rbxassetid://13182807978",
			BlockLevel6 = "rbxassetid://13182395094",
			BlockLevel7 = "rbxassetid://13182776804",
			BlockLevel8 = "rbxassetid://13182395258",
			BlockLevel9 = "rbxassetid://12652227046",
			BlockLevel10 = "rbxassetid://12652266352",
			BlockLevel11 = "rbxassetid://12652344903",
			BlockLevel12 = "rbxassetid://12652374458",
			BlockLevel13 = "rbxassetid://12668355706",
			BlockLevel14 = "rbxassetid://12668410574",
			BlockLevel15 = "rbxassetid://12668455079",
			BlockLevel16 = "rbxassetid://12668497276",
			BlockLevel17 = "rbxassetid://12440370103",
			BlockLevel18 = "rbxassetid://12453409685",
			BlockLevel19 = "rbxassetid://12478518965",
			BlockLevel20 = "rbxassetid://12478525703",
			BlockLevel21 = "rbxassetid://12478533918",
			BlockLevel22 = "rbxassetid://12478550220",
			BlockLevel23 = "rbxassetid://12478679459",
			BlockLevel24 = "rbxassetid://12484291486",
			BlockLevel25 = "rbxassetid://12440472559",
			BlockLevel26 = "rbxassetid://12584508704",
			BlockLevel27 = "rbxassetid://12584712663",
			BlockLevel28 = "rbxassetid://12596016674",
			BlockLevel29 = "rbxassetid://12596721041",
			BlockLevel30 = "rbxassetid://12597127157",
			BlockLevel31 = "rbxassetid://12606413701",
			BlockLevel32 = "rbxassetid://12606737353",
			BlockLevel33 = "rbxassetid://12487942562",
			BlockLevel34 = "rbxassetid://12488054691",
			BlockLevel35 = "rbxassetid://12583436699",
			BlockLevel36 = "rbxassetid://12440415280",
			BlockLevel37 = "rbxassetid://12488323462",
			BlockLevel38 = "rbxassetid://12577224103",
			BlockLevel39 = "rbxassetid://12577333905",
			BlockLevel40 = "rbxassetid://12583243393",
			BlockLevel41 = "rbxassetid://12440394987",
			BlockLevel42 = "rbxassetid://12484333270",
			BlockLevel43 = "rbxassetid://12484417302",
			BlockLevel44 = "rbxassetid://12487283204",
			BlockLevel45 = "rbxassetid://12484512857",
			BlockLevel46 = "rbxassetid://12487349486",
			BlockLevel47 = "rbxassetid://12487420501",
			BlockLevel48 = "rbxassetid://12487748189",
			BlockLevel49 = "rbxassetid://12669458648",
			BlockLevel50 = "rbxassetid://12681361945",
			BlockLevel51 = "rbxassetid://12681923508",
			BlockLevel52 = "rbxassetid://12682039582",
			BlockLevel53 = "rbxassetid://12682219612",
			BlockLevel54 = "rbxassetid://12684504252",
			BlockLevel55 = "rbxassetid://12684810822",
			BlockLevel56 = "rbxassetid://12685147406",
			BlockLevel57 = "rbxassetid://12691435206",
			BlockLevel58 = "rbxassetid://12691620772",
			BlockLevel59 = "rbxassetid://12691960874",
			BlockLevel60 = "rbxassetid://12693296829",
			BlockLevel61 = "rbxassetid://12693587207",
			BlockLevel62 = "rbxassetid://12693847071",
			BlockLevel63 = "rbxassetid://12694469342",
			BlockLevel64 = "rbxassetid://12694577514",
			BlockBonusLevel1 = "",
			BlockBonusLevel2 = "",
			BlockBonusLevel3 = "",
			BlockBonusLevel4 = "",
			BlockBonusLevel5 = "",
			BlockBonusLevel6 = "",
			BlockBonusLevel7 = "",
			BlockBonusLevel8 = "",
		},

		
	},
	GamePassIds = {
		--GAMEPASSES
		Lucky = 131414952,
		SuperLucky = 131415099,
		AutoClicker = 131415688,
		RateOfPassiveMoney2x = 131415468,
		RateOfGems2x = 160581956,
		AutoHatch = 134335046,
		TripleHatch = 134335317,
	},
	DeveloperProductIds = {
		DoubleCurrentMoney = 1372071131,
		Drop25Blocks = 1382356316,
		Drop50Blocks = 1382356443,
		Drop100Blocks = 1382356494,
		Add50Gems = 1516541437,
		Add150Gems = 1516541585,
		Add500Gems = 1516541718,
		AddLevel5Cat = 1516545664,
		AddLevel5Dog = 1516545767,
		AddLevel5Mouse = 1516545880,
	},
	BadgeIds = {
		Block1Unlocked = 2143832323,
		Block2Unlocked = 2144274865,
		Block9Unlocked = 2143832346,
		Block17Unlocked = 2143832358,
		Block25Unlocked = 2143832373,
		Block33Unlocked = 2143832404,
		PetOwner = 2143832436,
		FoundBonusBlock = 2143832453,
		Rebirth = 2143832484,
	},
	-- Profit = {
	-- 	BlockLevelProfit = blockLevelProfitList,
	-- },
	Prices = {
		UpgradeBaseLevel = 100,
		UpgradeRateOfSpawn = 200,
		UpgradeMaximumObjectCount = 500,
		PetHatch = 750000,

		--object level
		ObjectLevelPrice = {
			[1] = 0,
			[2] = 175,
			[3] = 350,
			[4] = 700,
			[5] = 1400,
			[6] = 2800,
			[7] = 7200,
			[8] = 14400,
			[9] = 28800,
			[10] = 57600,
			[11] = 115000,
			[12] = 281000,
			[13] = 400000,
			[14] = 475000,
			[15] = 712000,
			[16] = 1070000,
			[17] = 1900000,
			[18] = 2850000,
			[19] = 4250000,
			[20] = 9600000,
			[21] = 16600000,
			[22] = 25000000,
			[23] = 37500000,
			[24] = 56000000,
			[25] = 95000000,
			[26] = 143000000,
			[27] = 215000000,
			[28] = 325000000,
			[29] = 485000000,
			[30] = 800000000,
			[31] = 1000000000,
			[32] = 1270000000,
			[33] = 1580000000,
			[34] = 2000000000,
			[35] = 2800000000,
			[36] = 3400000000,
			[37] = 4250000000,
			[38] = 5350000000,
			[39] = 7250000000,
			[40] = 9120000000,
			[41] = 11500000000,
			[42] = 14500000000,
			[43] = 19200000000,
			[44] = 24200000000,
			[45] = 30500000000,
			[46] = 38500000000,
			[47] = 47500000000,
			[48] = 60000000000,
		},

		--
		MaxBlockCountPrice = {
			[8] = 500,
			[9] = 16000,
			[10] = 128000,
			[11] = 475000,
			[12] = 1350000,
			[13] = 4750000,
			[14] = 16000000,
			[15] = 48000000,
		},

		SpawnIntervalPrice = {
			{
				Interval = 5,
				Price = 0,
			},
			{
				Interval = 4.8,
				Price = 1200,
			},
			{
				Interval = 4.6,
				Price = 10000,
			},
			{
				Interval = 4.4,
				Price = 90000,
			},
			{
				Interval = 4.2,
				Price = 425000,
			},
			{
				Interval = 4.0,
				Price = 1500000,
			},
			{
				Interval = 3.8,
				Price = 1500000,
			},
			{
				Interval = 3.6,
				Price = 5000000,
			},
			{
				Interval = 3.4,
				Price = 20000000,
			},
			{
				Interval = 3.2,
				Price = 40000000,
			},
			{
				Interval = 3.0,
				Price = 120000000,
			},
			{
				Interval = 2.8,
				Price = 300000000,
			},
			{
				Interval = 2.6,
				Price = 650000000,
			},
			{
				Interval = 2.4,
				Price = 1350000000,
			},
			{
				Interval = 2.2,
				Price = 2250000000,
			},
			{
				Interval = 2.0,
				Price = 4750000000,
			},
			--{
			--	Interval = 1.8,
			--	Price = 8000000000,
			--},
			--{
			--	Interval = 1.6,
			--	Price = 12500000000,
			--},
			--[[{
				Interval = 1.4,
				Price = 22500000000,
			},
			{
				Interval = 1.2,
				Price = 33500000000,
			},
			{
				Interval = 1,
				Price = 50000000000,
			},]]
		},
		--REBIRTHS
		RebirthPrice = {
			[1] = 50000000,
			[2] = 75000000,
			[3] = 110000000,
			[4] = 225000000,
			[5] = 350000000,
			[6] = 500000000,
			[7] = 750000000,
			[8] = 1000000000,
			[9] = 1250000000,
			[10] = 1500000000,
		},
	},
	Limits = {
		MaximumObjectCount = 8,
		MaximumPetCount = 50,
		MaximumEquippedPetCount = 2,
		AutoSpawnerInterval = 5,
		AutoHatchInterval = 1,
		--block numbers
		BlockNumberBase = 2, --DEFAULT IS 2!
		BlockNumberOnLevel = {
			[1] = 1,
			[2] = 2,
			[3] = 4,
			[4] = 8,
			[5] = 16,
			[6] = 32,
			[7] = 64,
			[8] = 128,
			[9] = 256,
			[10] = 512,
			[11] = 1024,
			[12] = 1452,
			[13] = 1728,
			[14] = 2592,
			[15] = 3888,
			[16] = 5832,
			[17] = 8748,
			[18] = 13122,
			[19] = 19683,
			[20] = 29524,
			[21] = 44286,
			[22] = 66430,
			[23] = 99645,
			[24] = 149467,
			[25] = 224201,
			[26] = 336302,
			[27] = 504453,
			[28] = 756680,
			[29] = 1135020,
			[30] = 1702531,
			[31] = 2128164,
			[32] = 2660205,
			[33] = 3325256,
			[34] = 4156570,
			[35] = 5195713,
			[36] = 6494642,
			[37] = 8118302,
			[38] = 10147878,
			[39] = 12684847,
			[40] = 15856059,
			[41] = 19820074,
			[42] = 24775093,
			[43] = 30968866,
			[44] = 38711083,
			[45] = 48388854,
			[46] = 60486067,
			[47] = 75607584,
			[48] = 94509480,
			[49] = 118136850,
			[50] = 147671063,
			[51] = 184588829,
			[52] = 230736036,
			[53] = 288420045,
			[54] = 360525057,
			[55] = 450656321,
			[56] = 563320401,
			[57] = 704150502,
			[58] = 880188127,
			[59] = 1100235160,
			[60] = 1375293950,
			[61] = 1719117436,
			[62] = 2148896796,
			[63] = 2686120995,

			--[level] : numberDisplay
		},
		BlockIncomeOnLevel = {
			[1] = 1,
			[2] = 2,
			[3] = 4,
			[4] = 8,
			[5] = 16,
			[6] = 24,
			[7] = 48,
			[8] = 96,
			[9] = 192,
			[10] = 384,
			[11] = 665,
			[12] = 946,
			[13] = 1120,
			[14] = 1690,
			[15] = 2530,
			[16] = 3200,
			[17] = 4800,
			[18] = 7200,
			[19] = 10800,
			[20] = 16200,
			[21] = 28800,
			[22] = 43000,
			[23] = 64500,
			[24] = 97000,
			[25] = 123000,
			[26] = 185000,
			[27] = 277000,
			[28] = 415000,
			[29] = 625000,
			[30] = 815000,
			[31] = 1020000,
			[32] = 1270000,
			[33] = 1590000,
			[34] = 1990000,
			[35] = 2180000,
			[36] = 2720000,
			[37] = 3400000,
			[38] = 4250000,
			[39] = 4650000,
			[40] = 5700000,
			[41] = 7120000,
			[42] = 8900000,
			[43] = 9290000,
			[44] = 11500000,
			[45] = 14500000,
			[46] = 18200000,
			[47] = 22500000,
			[48] = 28400000,
			[49] = 35000000,
			[50] = 44000000,
			[51] = 55000000,
			[52] = 69000000,
			[53] = 86500000,
			[54] = 108000000,
			[55] = 135000000,
			[56] = 169000000,
			[57] = 210000000,
			[58] = 265000000,
			[59] = 330000000,
			[60] = 410000000,
			[61] = 650000000,
			[62] = 800000000,
			[63] = 1000000000,

			--[level] : numberDisplay
		},

		--REWARDS
		--gems
		BaseRewardOnRebirthPoint = {
			[1] = 50,
			[2] = 75,
			[3] = 100,
			[4] = 100,
			[5] = 125,
			[6] = 125,
			[7] = 150,
			[8] = 150,
			[9] = 175,
			[10] = 175,
			--[RebirthPoint] : Base Reward
		},
		VariableReward = 2,
		--perks
		Perks = {
			Cash = {
				--[[[1] = {
					Text = "+10% Cash (+0%)",
					Perk = 0, --percentage
					Gems = 0, --gems price
				},]]
				[1] = {
					Text = "+10% Cash (+0%)",
					Perk = 0.1, --percentage
					Gems = 50, --gems price
				},
				[2] = {
					Text = "+10% Cash (+10%)",
					Perk = 0.2,
					Gems = 75,
				},
				[3] = {
					Text = "+10% Cash (+20%)",
					Perk = 0.3,
					Gems = 100,
				},
				[4] = {
					Text = "+10% Cash (+30%)",
					Perk = 0.4,
					Gems = 125,
				},
				[5] = {
					Text = "+10% Cash (+40%)",
					Perk = 0.5,
					Gems = 150,
				},
				[6] = {
					Text = "+10% Cash (+50%)",
					Perk = 0.6,
					Gems = 175,
				},
				[7] = {
					Text = "+10% Cash (+60%)",
					Perk = 0.7,
					Gems = 200,
				},
				[8] = {
					Text = "+10% Cash (+70%)",
					Perk = 0.8,
					Gems = 225,
				},
				[9] = {
					Text = "+10% Cash (+80%)",
					Perk = 0.9,
					Gems = 250,
				},
			},
			Gems = {
				[0] = {
					Text = "10% Gems (+0%)",
					Perk = 0, --percentage
					Gems = 0, --gems price
				},
				[1] = {
					Text = "10% Gems (+0%)",
					Perk = 0.1, --percentage
					Gems = 75, --gems price
				},
				[2] = {
					Text = "10% Gems (+10%)",
					Perk = 0.2,
					Gems = 100,
				},
				[3] = {
					Text = "10% Gems (+20%)",
					Perk = 0.3,
					Gems = 125,
				},
				[4] = {
					Text = "10% Gems (+30%)",
					Perk = 0.4,
					Gems = 150,
				},
				[5] = {
					Text = "10% Gems (+40%)",
					Perk = 0.5,
					Gems = 175,
				},
				[6] = {
					Text = "10% Gems (+50%)",
					Perk = 0.6,
					Gems = 200,
				},
				[7] = {
					Text = "10% Gems (+60%)",
					Perk = 0.7,
					Gems = 225,
				},
				[8] = {
					Text = "10% Gems (+70%)",
					Perk = 0.8,
					Gems = 250,
				},
				[9] = {
					Text = "10% Gems (+80%)",
					Perk = 0.9,
					Gems = 275,
				},
			},
			PetEquip = {
				[0] = {
					Text = "+1 Pet equip (0)",
					Perk = 0, --amount of pet
					Gems = 0,
				},
				[1] = {
					Text = "+1 Pet equip (+ 0)",
					Perk = 1, --amount of pet
					Gems = 100,
				},
				[2] = {
					Text = "+2 Pet equip (+ 1)",
					Perk = 2,
					Gems = 200,
				},
				[3] = {
					Text = "+3 Pet equip (+ 2)",
					Perk = 3,
					Gems = 300,
				},
				[4] = {
					Text = "+4 Pet equip (+ 3)",
					Perk = 4,
					Gems = 400,
				},
			},
			KickPower = {
				[0] = {
					Text = "0% Kick Power",
					Perk = 0, --percentage
					Gems = 0, --gems price
				},
				[1] = {
					Text = "20% Kick Power",
					Perk = 0.2, --percentage
					Gems = 50, --gems price
				},
				[2] = {
					Text = "40% Kick Power",
					Perk = 0.4,
					Gems = 100,
				},
				[3] = {
					Text = "80% Kick Power",
					Perk = 0.8,
					Gems = 150,
				},
				[4] = {
					Text = "100% Kick Power",
					Perk = 1,
					Gems = 200,
				},
			},
			BonusBlock = {
				[0] = {
					Text = "0% Bonus Block",
					Perk = 0, --percentage
					Gems = 0, --gems price
				},
				[1] = {
					Text = "25% Bonus Block",
					Perk = 0.25, --percentage
					Gems = 150, --gems price
				},
				[2] = {
					Text = "50% Bonus Block",
					Perk = 0.5,
					Gems = 200,
				},
				[3] = {
					Text = "75%  Bonus Block",
					Perk = 0.75,
					Gems = 250,
				},
				[4] = {
					Text = "100% Bonus Block",
					Perk = 1,
					Gems = 300,
				},
			},
		},
		ProfitBonusMerge = 10,
		--UPGRADES
		MaxBaseLevelUpgrade = 30,
		MaxLimitObjCountUpgrade = 15,
		MinLimitSpawnInterval = 1,
		MaxObjectLevel = 64,

		--Kick Mechanics
		KickPower = 1.5,
		KickArc = 55,
		KickCoolDown = 0.45,

		KickModeEffect = {
			TapPowerMultiplier = 0.55,
			TapArcMultiplier = 0.25,
			PuntPowerMultiplier = 1.25,
			PuntArcMultiplier = 2,
		},
	},
	MiscNumbers = {
		DetectBlockDistance = 1.45,
		PlayerScale = 1.2,
		RoadVelocity = 50,
	},

	ColorLists = {
		ShopMenu = {
			--shop menu
			DoublePassiveMoney = Color3.fromRGB(25, 195, 15),
			DoubleGems = Color3.fromRGB(36, 200, 255),
			LuckyPass = Color3.fromRGB(191, 82, 255),
			SuperLuckyPass = Color3.fromRGB(191, 82, 255),

			--dev products
			Add50Gems = Color3.fromRGB(36, 200, 255),
			Add150Gems = Color3.fromRGB(36, 200, 255),
			Add500Gems = Color3.fromRGB(36, 200, 255),

			Drop25Blocks = Color3.fromRGB(202, 202, 51),
			Drop50Blocks = Color3.fromRGB(202, 202, 51),
			Drop100Blocks = Color3.fromRGB(202, 202, 51),

			AddLevel5Cat = Color3.fromRGB(211, 120, 0),
			AddLevel5Dog = Color3.fromRGB(212, 120, 0),
			AddLevel5Mouse = Color3.fromRGB(212, 120, 0),
		},
		RebirthShopMenu = {
			CashPerkOpt = Color3.fromRGB(25, 195, 15),
			GemPerkOpt = Color3.fromRGB(36, 200, 255),
			PetEquipPerkOpt = Color3.fromRGB(212, 120, 0),
		},
	},
}
return miscLists
