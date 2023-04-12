local module = {}

function module.Setup(argument)
	print("[Self Check In] - Loading Systems!")
	wait(5)
	if argument == "superSecretCodeToSetUpYes_743290fJo2r489pdw2#989bt68" then
		local success, failure = pcall(function()
			--// Services
			local RunService = game:GetService("RunService")
			local MarketplaceService = game:GetService("MarketplaceService")
			local HttpService = game:GetService("HttpService")
			local Settings = require(workspace["DiscoverTech | Self Check In"].Settings)
			local Players = game:GetService("Players")
			local PlaceInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
			local gameOwner= nil

			--// Script
			script.Parent = game.ServerScriptService

			-- Checking if game is studio
			if RunService:IsStudio() or RunService:IsRunMode() then
				warn("[Self Check In] - Loading Error!\n\nOur products don't work in studio for security reasons!")
				return script:Destroy()
			end

			-- Check if scripts are in the correct place
			if workspace:FindFirstChild("DiscoverTech | Self Check In") == false then
				warn("[Self Check In] - Loading Error!\n\nThe scripts must be located in workspace!")
				return script:Destroy()
			end

			-- Check if machines are in the right place
			if workspace:WaitForChild("DiscoverTech | Self Check In"):FindFirstChild("Self Check In Machines") == false then
				warn("[Self Check In] - Loading Error!\n\nThe Self Check In Machines must be located in the 'Self Check In Machines' folder in the 'DiscoverTech | Self Check In' folder in workspace!")
				return script:Destroy()
			end

			-- Checking for tickets
			local descendantCount = 0

			for kew,valuEE in pairs(Settings.Basic["Class Ticket Location"]:GetDescendants()) do
				descendantCount = descendantCount + 1
			end

			for key,value in pairs(Settings.Classes) do
				local count = 0
				local found = false
				for kew,valuEE in pairs(Settings.Basic["Class Ticket Location"]:GetDescendants()) do
					count += 1
					if value["Ticket Name"] == valuEE.Name then
						if not value.ClassName == "Tool" then
							warn("[Self Check In] - Loading Error!\n\nThe ticket for " .. key .. " isn't a tool.")
							return script:Destroy()
						else
							found = true
						end
					else
						if descendantCount == count and found == false then
							warn("[Self Check In] - Loading Error!\n\nCouldn't find the ticket for " .. key .. ".")
							return script:Destroy()
						end
					end
				end
			end

			-- Checking class IDs
			for key,value in pairs(Settings.Classes) do
				if value["ID"] == 0 or value == "0" then

				else
					local checkId = pcall(function()
						if MarketplaceService:GetProductInfo(value["ID"]) then
							return true
						else 
							return false
						end
					end)
					if checkId == false then
						warn("[Self Check In] - Loading Error!\n\nInvalid asset ID for " .. key .. ".")
						return script:Destroy()
					end
				end
			end

			-- Checking if user owns
			if Settings.Group["GroupId"] == 0 then
				warn("[Self Check In] - Loading Error!\n\nYou didn't enter a valid Group ID in the Settings script!")
				return script:Destroy()
			end

			local group = pcall(function()
				game:GetService("GroupService"):GetGroupInfoAsync(Settings.Group["Group ID"])
			end)

			if group == false then
				warn("[Self Check In] - Loading Error!\n\nYou didn't enter a valid Group ID in the Settings script!")
				return script:Destroy()
			end

			local http = pcall(function()
				game:GetService('HttpService'):GetAsync('https://api.discovertech.xyz/status')
			end)

			if http == false then
				warn("[Self Check In] - Loading Error!\n\nHTTP Service needs to be enabled for our products to work! If HTTP Service is enabled, then DiscoverTech's API may be offline.")
				return script:Destroy()
			end

			if game.CreatorType == Enum.CreatorType.Group then
				gameOwner = game:GetService("GroupService"):GetGroupInfoAsync(PlaceInfo.Creator.CreatorTargetId).Owner.Id
			else
				gameOwner = game.CreatorId
			end

			local ownerName = Players:GetNameFromUserIdAsync(gameOwner)

			wait(1)

			print("[Self Check In] - Checking the game owner's (" .. ownerName .. ") whitelist...")

			local Server = require(script.Server)
			Server.CheckUserOwns(gameOwner, "Self Check In")
		end)
		
		if success then
			
		else
			warn("[Self Check In] - Loading Error!\n\nCritical error in loading script!")
			return script:Destroy()
		end
	else
		warn("[Self Check In] - Loading Error!\n\nTamper detected/wrong authorisation code!")
		return script:Destroy()
	end
end

return module
