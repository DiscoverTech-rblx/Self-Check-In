script.Parent.Main.Position = UDim2.new(1.5, 0, 0.5, 0)

--//	Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

--//	Variables
local Settings = require(workspace:FindFirstChild("DiscoverTech | Self Check In").Settings)
local FlightData = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Data")
local SeatsEvent = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Events"):WaitForChild("SeatsEvent")
local InformationEvent = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Events"):WaitForChild("InformationEvent")
local AdminEvent = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("Events"):WaitForChild("AdminEvent")
local Player = Players.LocalPlayer
local Pages = script.Parent:WaitForChild("Main"):WaitForChild("Pages")
local CloseButton = script.Parent:WaitForChild("Main"):WaitForChild("TopBar"):WaitForChild("CloseButton")
local RoStrapStorage = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("RoStrap")
local RoStrapRippler = require(RoStrapStorage:WaitForChild("Rippler"))
local PseudoInstance = require(RoStrapStorage:WaitForChild("PseudoInstance"))


--//	Data
local Data = {}

--//	Code

--	Events CATEGORY  --

-- Seats Event
SeatsEvent.OnClientEvent:Connect(function(eventType, seatName, data1, data2, data3)
	if eventType == "seatChanged" then
		Pages.Classes[seatName].SeatChanger.TextBox.PlaceholderText = data1
		if Pages.Classes[seatName].SeatChanger.TextBox.Text == "Updating..." then
			Pages.Classes[seatName].SeatChanger.TextBox.Text = "Updated!"
			wait(2)
			Pages.Classes[seatName].SeatChanger.TextBox.Text = ""
		end
	end
end)

-- Information Event
InformationEvent.OnClientEvent:Connect(function(informationName, newValue)
	for i,v in pairs(Pages.Information:GetDescendants()) do
		if v.Name == informationName and v.ClassName == "TextBox" then
			v.PlaceholderText = newValue
			if v.Text == "Updating..." then
				v.Text = "Updated!"
				wait(2)
				v.Text = ""
			end
		end
	end
end)

AdminEvent.OnClientEvent:Connect(function(option, newValue)
	if option == "statusChange" then
		if tostring(newValue) == "false" then
			Pages.EnableDisableButton.EnableDisable.Value = false
			Pages.EnableDisableButton.TextLabel.Text = "CLOSED"
			Pages.EnableDisableButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		else
			Pages.EnableDisableButton.EnableDisable.Value = true
			Pages.EnableDisableButton.TextLabel.Text = "OPENED"
			Pages.EnableDisableButton.BackgroundColor3 = Color3.fromRGB(0, 172, 146)
		end
	end
end)


-- Enable Disable Button
Pages.EnableDisableButton.InputBegan:Connect(function(InputObject, gameHandled)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
		Data.Rippler = PseudoInstance.new("Rippler")
		Data.Rippler.Container = Pages.EnableDisableButton
		local mouse = Player:GetMouse()
		Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
		
		if Pages.EnableDisableButton.EnableDisable.Value == false then
			AdminEvent:FireServer("statusChange", "true")
		elseif Pages.EnableDisableButton.EnableDisable.Value == true then
			AdminEvent:FireServer("statusChange", "false")
		end
	end
end)

-- Close Button
CloseButton.InputBegan:Connect(function(InputObject, gameHandled)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
		Data.Rippler = PseudoInstance.new("Rippler")
		Data.Rippler.Container = CloseButton
		local mouse = Player:GetMouse()
		Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
		TweenService:Create(script.Parent.Main, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1.5, 0, 0.5, 0)}):Play()
		wait(0.75)
		TweenService:Create(script.Parent.OpenButton, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1.01, 0, 0.2, 0)}):Play()
	end
end)

-- Information Buttons
for i,v in pairs(Pages.Information:GetDescendants()) do
	if v.ClassName == "TextBox" then
		
		for i,vd in pairs(FlightData["Flight Information"]:GetDescendants()) do
			if vd.Name == v.Name then
				v.PlaceholderText = vd.Value
			end
		end
		
		v.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				InformationEvent:FireServer(v.Name, v.Text)
				v.Text = "Updating..."
			end
		end)
	end
end

-- Class Buttons

for Classname, ClassData in pairs(Settings.Classes) do
	local newClassButton = Pages.Classes.Example:Clone()
	newClassButton.Name = Classname
	newClassButton.TheClassName.Text = Classname
	newClassButton.SeatChanger.TextBox.PlaceholderText = FlightData["Flight Seats"][Classname].Value
	newClassButton.Parent = Pages.Classes
	newClassButton.Visible = true
	newClassButton.SeatChanger.TextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			SeatsEvent:FireServer("updateSeat", Classname, newClassButton.SeatChanger.TextBox.Text)
			newClassButton.SeatChanger.TextBox.Text = "Updating..."
		end
	end)
end

script.Parent.OpenButton.InputBegan:Connect(function(InputObject, gameHandled)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
		Data.Rippler = PseudoInstance.new("Rippler")
		Data.Rippler.Container = script.Parent.OpenButton
		local mouse = Player:GetMouse()
		Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
		TweenService:Create(script.Parent.Main, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		TweenService:Create(script.Parent.OpenButton, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1.1, 0, 0.2, 0)}):Play()
	end
end)
