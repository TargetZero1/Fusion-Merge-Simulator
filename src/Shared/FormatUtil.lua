--!strict
-- Service
-- Packages
local Maid = require(game:GetService("ReplicatedStorage").Packages.Maid)
local Signal = require(game:GetService("ReplicatedStorage").Packages.Signal)

-- Modules
type Maid = Maid.Maid
type Signal = Signal.Signal

local Util = {}

function Util.time(timeInSeconds: number, goMaxLength: boolean?): string
	local days = math.floor(timeInSeconds / 86400)
	local hours = math.floor((timeInSeconds % 86400) / 3600)
	local minutes = math.floor((timeInSeconds % 3600) / 60)
	local seconds = math.floor(timeInSeconds % 60)
	if days > 0 or goMaxLength then
		if seconds == 0 then
			return string.format("%dd %02dh %02dm", days, hours, minutes)
		else
			return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, seconds)
		end
	elseif hours > 0 then
		if seconds == 0 then
			return string.format("%2dh %02dm", hours, minutes)
		else
			return string.format("%2dh %02dm %02ds", hours, minutes, seconds)
		end
	else
		return string.format("%2dm %02ds", minutes, seconds)
	end
end

function Util.getIdFromString(str: string): number
	local val = 0
	for i = 1, string.len(str) do
		val += string.byte(str, i, i)
	end
	return val
end

function Util.insertCommas(amount: number): string
	if amount < 10 then
		amount = math.round(amount * 100) / 100
	elseif amount < 100 then
		amount = math.round(amount * 10) / 10
	else
		amount = math.round(amount)
	end
	local formatted = tostring(amount)
	while true do
		local i: number
		formatted, i = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if i == 0 then
			break
		end
	end
	return formatted
end

function Util.formatNumber(num: number)
	if num < 1000 then
		return tostring(num)
	end
	local suffixes = { "", "K", "M", "B", "T", "Q", "E", "Z", "Y", "?" }
	local idx = 1
	while num >= 1000 and idx < #suffixes do
		num = num / 1000
		idx = idx + 1
	end
	local formatted
	if num >= 100 then
		formatted = string.format("%d", num)
	elseif num >= 10 then
		formatted = string.format("%.1f", num)
	-- elseif num >= 1 then
	-- 	formatted = string.format("%.2f", num)
	else
		formatted = string.format("%.2f", num)
	end
	if suffixes[idx] ~= "" then
		local zeros = 3 - string.len(formatted)
		formatted = string.rep("0", zeros) .. formatted
		formatted = formatted .. suffixes[idx]
	end
	return formatted
end
-- for i=1, 64 do
-- 	local val = 2^i
-- 	print(i, ":", val, " -> ", Util.formatNumber(val))
-- end

function Util.color(txt: string, col: Color3): string
	local hex = col:ToHex()
	return '<font color="#' .. tostring(hex:upper()) .. '">' .. txt .. "</font>"
end

function Util.bold(txt: string): string
	return "<b>" .. txt .. "</b>"
end

function Util.italic(txt: string): string
	return "<i>" .. txt .. "</i>"
end

function Util.underline(txt: string): string
	return "<u>" .. txt .. "</u>"
end

function Util.smallcaps(txt: string): string
	return "<sc>" .. txt .. "</sc>"
end

function Util.br(txt: string): string
	return "<s>" .. txt .. "</s>"
end

function Util.size(txt: string, size: number): string
	return '<font size="' .. tostring(size) .. '">' .. txt .. "</font>"
end

function Util.font(txt: string, font: Enum.Font): string
	return '<font face="' .. tostring(font.Name) .. '">' .. txt .. "</font>"
end

function Util.money(amount: number, visualizePositive: boolean?): string
	return "$" .. Util.formatNumber(amount)
end

function Util.numbersOnly(str: string)
	local noLetters = string.gsub(str, "%a", "")

	local noSpaces = string.gsub(noLetters, "%s", "")
	local noWeirdos = string.gsub(noSpaces, "%c", "")
	local noNull = string.gsub(noWeirdos, "%z", "")
	local savePeriods = string.gsub(noNull, "%.", "p")
	local noPunct = string.gsub(savePeriods, "%p", "")
	local addPeriods = string.gsub(noPunct, "p", ".")
	return addPeriods
end

function Util.lettersOnly(str: string): string
	return string.gsub(str, "[^%a]", "")
end

function Util.pseudoWord(len: number)
	local txt = ""
	for i = 1, len do
		local char = string.char(64 + math.random(26))
		if i == 1 then
			char = string.upper(char)
		else
			char = string.lower(char)
		end
		txt ..= char
	end
	return txt
end

function Util.pseudoPhrase(words: number, avgWordLen: number, stDev: number)
	local txt = ""
	for i = 1, words do
		local wordLen = avgWordLen + (math.random(stDev * 2) - stDev)
		txt ..= Util.pseudoWord(wordLen)
		if i ~= words then
			txt ..= " "
		end
	end
	return txt
end

-- Copyright (C) 2012 LoDC
-- https://gist.github.com/efrederickson/4080372

-- local map = {
-- 	I = 1,
-- 	V = 5,
-- 	X = 10,
-- 	L = 50,
-- 	C = 100,
-- 	D = 500,
-- 	M = 1000,
--  }
local numbers = { 1, 5, 10, 50, 100, 500, 1000 }
local chars = { "I", "V", "X", "L", "C", "D", "M" }

function Util.ToRomanNumerals(s: number)
	s = math.abs(s)
	if s == math.huge then
		error("Unable to convert infinity")
	end
	s = math.floor(s)

	local ret = ""
	for i = #numbers, 1, -1 do
		local num = numbers[i]
		while s - num >= 0 and s > 0 do
			ret = ret .. chars[i]
			s = s - num
		end
		--for j = i - 1, 1, -1 do
		for j = 1, i - 1 do
			local n2 = numbers[j]
			if s - (num - n2) >= 0 and s < num and s > 0 and num - n2 ~= n2 then
				ret = ret .. chars[j] .. chars[i]
				s = s - (num - n2)
				break
			end
		end
	end
	return ret
end


return Util
