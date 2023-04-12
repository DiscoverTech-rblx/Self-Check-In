--//	Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestService = game:GetService("TestService")

--//	Variables
local Settings = require(workspace:FindFirstChild("DiscoverTech | Self Check In").Settings)
local FlightData = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Data")
local SeatsEvent = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Events"):WaitForChild("SeatsEvent")
local InformationEvent = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Events"):WaitForChild("InformationEvent")
local AdminEvent = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Events"):WaitForChild("AdminEvent")
local RoStrapStorage = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("RoStrap")
local RoStrapRippler = require(RoStrapStorage:WaitForChild("Rippler"))
local RoStrapSnackbar = require(RoStrapStorage:WaitForChild("Snackbar"))
local RoStrapPseudoInstance = require(RoStrapStorage:WaitForChild("PseudoInstance"))
local RoStrapReplicatedPseudoInstance = require(RoStrapStorage:WaitForChild("ReplicatedPseudoInstance"))
local RoStrapColor = require(RoStrapStorage:WaitForChild("Color"))

local group = game:GetService("GroupService"):GetGroupInfoAsync(Settings.Group["Group ID"])
local machinesDetected = 0
local machinesLoaded = 0
local checkedInUsers = {}

--//	Code

-- Setting Up The SCI
for ClassName, ClassDetails in pairs(Settings.Classes) do
	local newClassValue = Instance.new("IntValue")
	newClassValue.Name = ClassName
	newClassValue.Value = 0
	newClassValue.Parent = FlightData:WaitForChild("Flight Seats")
	newClassValue.Changed:Connect(function(newValue)
		SeatsEvent:FireAllClients("seatChanged", ClassName, newValue)
	end)
end

for i, valueDetails in pairs(FlightData["Flight Information"]:GetDescendants()) do
	if valueDetails.ClassName == "StringValue" then
		valueDetails.Changed:Connect(function(newValue)
			InformationEvent:FireAllClients(valueDetails.Name, newValue)
		end)
	end
end

FlightData.Enabled.Changed:Connect(function(newValue)
	AdminEvent:FireAllClients("statusChange", tostring(newValue))
	for i,machine in pairs(workspace:FindFirstChild("DiscoverTech | Self Check In"):WaitForChild("Self Check In Machines"):GetChildren()) do
		if machine.ClassName == "Model" then
			machine.Screen.SelfCheckInPrompt.Enabled = newValue
		end
	end
end)

script["Self Check In V2"].Main.TopBar.BackButton.Visible = false
script["Self Check In V2"].Main.TopBar.BackButton.BackgroundTransparency = 1
script["Self Check In V2"].Main.TopBar.BackButton.TextLabel.TextTransparency = 1
script["Self Check In V2"].Main.TopBar.BackButton.Icon.ImageTransparency = 1
script["Self Check In V2"].Main.Pages.Frame.Parent.Parent.Background.Image = Settings.Basic["Background Image"]
script["Self Check In V2"].Main.Pages.Frame.Step0.BeginButton.BackgroundColor3 = Settings.Basic["Button Colour"]
script["Self Check In V2"].Main.Pages.Frame.Step1.ConfirmButton.BackgroundColor3 = Settings.Basic["Button Colour"]
script["Self Check In V2"].Main.Pages.Frame.Step2.ConfirmButton.BackgroundColor3 = Settings.Basic["Button Colour"]

for i,machine in pairs(workspace:FindFirstChild("DiscoverTech | Self Check In"):WaitForChild("Self Check In Machines"):GetChildren()) do
	if machine.ClassName == "Model" then
		machinesDetected += 1
		machine.Name = "Self Check In Machine " .. machinesDetected
		local NumberValue = Instance.new("NumberValue")
		NumberValue.Name = "InUseBy"
		NumberValue.Value = 0
		NumberValue.Parent = machine.Screen
		local ProximityPrompt = Instance.new("ProximityPrompt")
		ProximityPrompt.Name = "SelfCheckInPrompt"
		ProximityPrompt.ObjectText = "Self Check In"
		ProximityPrompt.ActionText = "Open"
		ProximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonB
		ProximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
		ProximityPrompt.RequiresLineOfSight = false
		ProximityPrompt.ClickablePrompt = true
		ProximityPrompt.Enabled = false
		ProximityPrompt.Parent = machine.Screen

		script["Self Check In V2"].Main:Clone().Parent = machine.Screen.SurfaceGui

		ProximityPrompt.Triggered:Connect(function(Player)
			if FlightData.Enabled.Value == true then
				if NumberValue.Value == 0 then
					if checkedInUsers[Player.UserId] then
						local snackClone = script.SnackbarScript:Clone()
						snackClone.Disabled = false
						snackClone.Parent = Player.PlayerGui
					else 
						if ProximityPrompt.Enabled == true then
							NumberValue.Value = Player.UserId
							ProximityPrompt.Enabled = false
							local sciClone = script.SelfCheckIn_Local:Clone()
							sciClone["Using Machine"].Value = machine.Name
							sciClone.Disabled = false
							sciClone.Parent = Player.PlayerGui
						end
					end
				else
					return
				end
			else
				return
			end
		end)
		machinesLoaded += 1
	end
end

for i,Player in pairs(Players:GetChildren()) do
	if Player:GetRankInGroup(tonumber(Settings.Group["Group ID"])) >= tonumber(Settings.Group["Staff ID"]) then
		script["Self Check In Admin Panel"]:Clone().Parent = Player.PlayerGui
	end
	
	local newPlayer = game.Players:GetPlayerByUserId(Player.UserId)

	newPlayer.CharacterAdded:Connect(function()
		if checkedInUsers[newPlayer.UserId] then
			if checkedInUsers[Player.UserId]["Checked In"] then
				local v = FlightData["Checked In"]:FindFirstChild(newPlayer.UserId)

				if v then
					local seatType = v.Value

					for i,v in pairs(Settings.Basic["Class Ticket Location"]:GetDescendants()) do
						if v.Name == Settings.Classes[seatType]["Ticket Name"] then
							v:Clone().Parent = newPlayer.Backpack
						end
					end

					if Settings.Other["Rename Users"] == true then
						local Head = newPlayer.Character:WaitForChild('Head')
						local headClone = Head:Clone()

						local fakeModel = Instance.new("Model", newPlayer.Character)
						fakeModel.Name = newPlayer.Name .. " | " .. seatType
						headClone.Parent = fakeModel

						local fakeHum = Instance.new("Humanoid", fakeModel)
						fakeHum.Name = "Name Tag"
						fakeHum.MaxHealth = 0
						fakeHum.Health = 0

						local Weld = Instance.new("Weld", headClone)
						Weld.Part0 = headClone
						Weld.Part1 = Head
						Head.Transparency = 1
					end
				end
			end
		end
	end)
end

Players.PlayerAdded:Connect(function(Player)
	if Player:GetRankInGroup(tonumber(Settings.Group["Group ID"])) >= tonumber(Settings.Group["Staff ID"]) then
		script["Self Check In Admin Panel"]:Clone().Parent = Player.PlayerGui
	end
	
	local newPlayer = game.Players:GetPlayerByUserId(Player.UserId)

	newPlayer.CharacterAdded:Connect(function()
		if checkedInUsers[newPlayer.UserId] then
			if checkedInUsers[Player.UserId]["Checked In"] then
				local v = FlightData["Checked In"]:FindFirstChild(newPlayer.UserId)

				if v then
					local seatType = v.Value

					for i,v in pairs(Settings.Basic["Class Ticket Location"]:GetDescendants()) do
						if v.Name == Settings.Classes[seatType]["Ticket Name"] then
							v:Clone().Parent = newPlayer.Backpack
						end
					end

					if Settings.Other["Rename Users"] == true then
						local Head = newPlayer.Character:WaitForChild('Head')
						local headClone = Head:Clone()

						local fakeModel = Instance.new("Model", newPlayer.Character)
						fakeModel.Name = newPlayer.Name .. " | " .. seatType
						headClone.Parent = fakeModel

						local fakeHum = Instance.new("Humanoid", fakeModel)
						fakeHum.Name = "Name Tag"
						fakeHum.MaxHealth = 0
						fakeHum.Health = 0

						local Weld = Instance.new("Weld", headClone)
						Weld.Part0 = headClone
						Weld.Part1 = Head
						Head.Transparency = 1
					end
				end
			end
		end
	end)
end)

--	Events Section

-- Information
InformationEvent.OnServerEvent:Connect(function(Player, infoName, value)
	for i, valueDetails in pairs(FlightData["Flight Information"]:GetDescendants()) do
		if valueDetails.ClassName == "StringValue" and valueDetails.Name == infoName then
			valueDetails.Value = value
		end
	end
end)

-- Seats
Players.PlayerRemoving:Connect(function(Player)
	for i,machine in pairs(workspace:FindFirstChild("DiscoverTech | Self Check In"):WaitForChild("Self Check In Machines"):GetChildren()) do
		if machine.Screen.InUseBy.Value == Player.UserId then
			machine.Screen.InUseBy.Value = 0
			machine.Screen.SelfCheckInPrompt.Enabled = true
			machine.Screen.SurfaceGui.Main:Destroy()
			script["Self Check In V2"].Main:Clone().Parent = machine.Screen.SurfaceGui
		end
	end
	if checkedInUsers[Player.UserId]["Checked In"] then
		FlightData["Flight Seats"][checkedInUsers[Player.UserId]].Value += 1
		if Settings.Other["Log Check Ins"] == true then
			print("[Self Check In] Server has checked out " .. Player.Name .. "! This was because they left the game.")
		end
	end
end)

AdminEvent.OnServerEvent:Connect(function(Player, option, value)
	if option == "deleteSciUi" then
		Player.PlayerGui.SelfCheckIn_Local:Destroy()
		for i,machine in pairs(workspace:FindFirstChild("DiscoverTech | Self Check In"):WaitForChild("Self Check In Machines"):GetChildren()) do
			if machine.Screen.InUseBy.Value == Player.UserId then
				machine.Screen.InUseBy.Value = 0
				machine.Screen.SelfCheckInPrompt.Enabled = true
				machine.Screen.SurfaceGui.Main:Destroy()
				script["Self Check In V2"].Main:Clone().Parent = machine.Screen.SurfaceGui
			end
		end
	elseif option == "statusChange" then
		if tostring(value) == "true" then
			FlightData.Enabled.Value = true
		else
			FlightData.Enabled.Value = false
		end
	elseif option == "closeButtonCheck" then
		FlightData["Flight Seats"][value].Value += 1
	end
end)

SeatsEvent.OnServerEvent:Connect(function(Player, option, seatType, seatNumber)
	if option == "getSeats" then
		for i, Class in pairs(FlightData["Flight Seats"]:GetChildren()) do
			SeatsEvent:FireClient(Player, "getSeatCount", Class.Name, Class.Value)
		end
	elseif option == "updateSeat" then
		FlightData["Flight Seats"][seatType].Value = seatNumber
	elseif option == "bookSeat" then
		if FlightData["Flight Seats"][seatType].Value > 0 then
			if checkedInUsers[Player.UserId] then
				if checkedInUsers[Player.UserId]["Checked In"] then
					SeatsEvent:FireClient(Player, "bookSeat", checkedInUsers[Player.UserId]["Seat"], "fail", "Already checked into ")
				else
					local previousSeat = checkedInUsers[Player.UserId]["Seat"]
					FlightData["Flight Seats"][checkedInUsers[Player.UserId]["Seat"]].Value += 1
					FlightData["Flight Seats"][seatType].Value -= 1
					checkedInUsers[Player.UserId] = {
						["Seat"] = seatType
					}
					SeatsEvent:FireClient(Player, "bookSeat", seatType, "success", "hadClass", previousSeat)
				end
			else
				FlightData["Flight Seats"][seatType].Value -= 1
				checkedInUsers[Player.UserId] = {
					["Seat"] = seatType
				}
				SeatsEvent:FireClient(Player, "bookSeat", seatType, "success")
			end
		else
			SeatsEvent:FireClient(Player, "bookSeat", seatType, "fail", "No seats available for ")
		end
	elseif option == "bookingComplete" then
		for i,v in pairs(Settings.Basic["Class Ticket Location"]:GetDescendants()) do
			if v.Name == Settings.Classes[seatType]["Ticket Name"] then
				v:Clone().Parent = Player.Backpack
			end
		end
		if Settings.Other["Rename Users"] == true then
			local Head = Player.Character:WaitForChild('Head')
			local headClone = Head:Clone()

			local fakeModel = Instance.new("Model", Player.Character)
			fakeModel.Name = Player.Name .. " | " .. seatType
			headClone.Parent = fakeModel

			local fakeHum = Instance.new("Humanoid", fakeModel)
			fakeHum.Name = "Name Tag"
			fakeHum.MaxHealth = 0
			fakeHum.Health = 0

			local Weld = Instance.new("Weld", headClone)
			Weld.Part0 = headClone
			Weld.Part1 = Head
			Head.Transparency = 1
		end
		checkedInUsers[Player.UserId]["Checked In"] = true
		
		local newData = Instance.new("StringValue")
		newData.Name = Player.UserId
		newData.Value = seatType
		newData.Parent = FlightData["Checked In"]
		
		if Settings.Other["Log Check Ins"] == true then
			print("[Self Check In] Checked in " .. Player.Name .. " into " .. seatType .. ", " .. FlightData["Flight Seats"][seatType].Value .. " seats remain for " .. seatType .. ".")
		end
		SeatsEvent:FireClient(Player, "bookingComplete", "yes")
	end
end)

TestService:Message("[Self Check In] - Loaded Systems!\n\nMachines Loaded: " .. machinesLoaded .. "/" .. machinesDetected .. " | Group: " .. group.Name)