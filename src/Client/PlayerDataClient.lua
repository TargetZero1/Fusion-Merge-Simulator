--!strict
--references
local Player = game:GetService("Players").LocalPlayer
local CashFrame = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Stats"):WaitForChild("CashFrame")
local FormatUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("FormatUtil"))

return {
	init = function(maid)
		--cash stats
		local intCashColor = CashFrame:WaitForChild("Cash").TextColor3
		local intCash = Player:GetAttribute("Cash") or 0
		Player:GetAttributeChangedSignal("Cash"):Connect(function()
			local cashDiff = math.sign(Player:GetAttribute("Cash") - intCash)
			CashFrame:WaitForChild("Cash").Text = "$" .. FormatUtil.formatNumber(Player:GetAttribute("Cash"))
			-- string.format("$%s", tostring(Player:GetAttribute("Cash")))
			--for i = 1, 2 do
			if cashDiff < 0 then
				CashFrame.Cash.TextColor3 = Color3.fromRGB(255, 0, 0)
			else
				CashFrame.Cash.TextColor3 = Color3.fromRGB(135, 255, 151)
			end
			task.wait(0.4)
			CashFrame.Cash.TextColor3 = intCashColor
			task.wait(0.4)
			--end
			intCash = Player:GetAttribute("Cash")
		end)
	end,
}
