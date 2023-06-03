--!strict
-- Constants
local LUM_LIMIT = 0.03928
local LUM_DENOM = 12.92
local LUM_OFFSET = 0.055
local LUM_OFFSET_DENOM = 1.055
local R_WEIGHT = 0.2126
local G_WEIGHT = 0.7152
local B_WEIGHT = 0.0722
local L_EXP = 2.4
local MIN_HEX_DIFFERENCE = 100 / 255
local BLACK_COLOR = Color3.fromHex("#000")
local WHITE_COLOR = Color3.fromHex("#FFF")
local CONTRAST_RATIO = 4.5

function getContrastRatio(foreground: Color3, background: Color3): number
	local function getRelativeLuminance(color: Color3): number
		local function solveSpace(v: number): number
			if v < LUM_LIMIT then
				return v / LUM_DENOM
			else
				return ((v + LUM_OFFSET) / LUM_OFFSET_DENOM) ^ L_EXP
			end
		end
		return R_WEIGHT * solveSpace(color.R) + G_WEIGHT * solveSpace(color.G) + B_WEIGHT * solveSpace(color.B)
	end

	local _fH, _fS, fV = foreground:ToHSV()
	local _bH, _bS, bV = background:ToHSV()

	local fLum = getRelativeLuminance(foreground)
	local bLum = getRelativeLuminance(background)

	local lighterRelativeLuminance: number
	local darkerRelativeLuminance: number
	if fV < bV then
		lighterRelativeLuminance = bLum
		darkerRelativeLuminance = fLum
	else
		lighterRelativeLuminance = fLum
		darkerRelativeLuminance = bLum
	end

	return (lighterRelativeLuminance + 0.05) / (darkerRelativeLuminance + 0.05)
end

function checkContrast(color: Color3, background: Color3): boolean
	local minRatio = CONTRAST_RATIO
	local ratio = getContrastRatio(color, background)
	return ratio >= minRatio
end

-- https://github.com/alex-page/a11ycolor/blob/main/index.js
return function(color: Color3, background: Color3): Color3
	-- Check the ratio straight away, if it passes return the value as hex
	if checkContrast(color, background) then
		return color
	end

	-- Ratio didn't pass so we need to find the nearest color
	local isBlackContrast = checkContrast(BLACK_COLOR, background)
	local isWhiteContrast = checkContrast(WHITE_COLOR, background)

	local cH, cS, cV = color:ToHSV()
	local minValue = 0
	local maxValue = 1
	local isDarkColor = false

	-- If black and white both pass on the background
	if isBlackContrast and isWhiteContrast then
		-- Change the min lightness if the color is light
		if cV >= 0.5 then
			minValue = cV
		else -- Change the max lightness if the color is dark
			maxValue = cV
			isDarkColor = true
		end
	elseif isBlackContrast then -- If our colour passes contrast on black
		maxValue = cV
		isDarkColor = true
	else -- Colour doesn't meet contrast pass on black
		minValue = cV
	end

	-- The color to return
	local finalColor: Color3?

	-- Binary search until we find the colour that meets contrast
	local prevColor: Color3?
	while not finalColor do
		local midValue = (minValue + maxValue) / 2
		local midColor = Color3.fromHSV(cH, cS, midValue)
		if checkContrast(midColor, background) then
			if maxValue - minValue <= MIN_HEX_DIFFERENCE then
				finalColor = midColor
			elseif isDarkColor then
				minValue = midValue
			else
				maxValue = midValue
			end
		elseif isDarkColor then
			maxValue = midValue
		else
			minValue = midValue
		end
		if prevColor == midColor then
			break
		end
		prevColor = midColor
	end
	return finalColor or color
end
