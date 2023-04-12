game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)

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
local Camera = workspace.Camera
local Player = Players.LocalPlayer
local machineUi = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Screen.SurfaceGui
local Pages = machineUi:WaitForChild("Main"):WaitForChild("Pages"):WaitForChild("Frame")
local ProgressBar = machineUi:WaitForChild("Main"):WaitForChild("BottomBar"):WaitForChild("Progress"):WaitForChild("ProgressBar"):WaitForChild("TheBar")
local CloseButton = machineUi:WaitForChild("Main"):WaitForChild("TopBar"):WaitForChild("CloseButton")
local BackButton = machineUi:WaitForChild("Main"):WaitForChild("TopBar"):WaitForChild("BackButton")
local RoStrapStorage = ReplicatedStorage:WaitForChild("DT_SelfCheckIn"):WaitForChild("RoStrap")
local RoStrapRippler = require(RoStrapStorage:WaitForChild("Rippler"))
local PseudoInstance = require(RoStrapStorage:WaitForChild("PseudoInstance"))
local alertdisabled = false
local originalCFrame = nil

--//	Data
local Data = {
	["Selected Class"] = "";
	["Current Step"] = "0";
	["Disabled Buttons"] = {
		["TopBar"] = {
			["Back Button"] = true;
			["Close Button"] = false;
		};
		["Step0"] = {
			["Begin Button"] = false;	
		};	
		["Step1"] = {
			["Confrim Button"] = true;
		};
		["Step2"] = {
			["Confirm Button"] = true;	
		};
	};
}

--//	Code
BackButton.Visible = false
BackButton.BackgroundTransparency = 1
BackButton.TextLabel.TextTransparency = 1
BackButton.Icon.ImageTransparency = 1
Pages.Parent.Parent.Background.Image = Settings.Basic["Background Image"]
Pages.Step0.BeginButton.BackgroundColor3 = Settings.Basic["Button Colour"]
Pages.Step1.ConfirmButton.BackgroundColor3 = Settings.Basic["Button Colour"]
Pages.Step2.ConfirmButton.BackgroundColor3 = Settings.Basic["Button Colour"]

--	Events CATEGORY  --

-- Seats Event
SeatsEvent.OnClientEvent:Connect(function(eventType, seatName, data1, data2, data3)
	if eventType == "seatChanged" then
		Pages.Step1.Classes[seatName].TheClassSeats.Text = data1 .. " Seats Remaining"
	elseif eventType == "bookSeat" then
		if data1 == "success" then
			Data["Selected Class"] = seatName
			if data2 == "hadClass" then
				TweenService:Create(Pages.Step1.Classes[data3], TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BorderColor3 = Color3.fromRGB(190, 190, 190)}):Play()
			end
			TweenService:Create(Pages.Step1.Classes[seatName], TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BorderColor3 = Settings.Basic["Class Colour"]}):Play()
			Pages.Step2["Class Info"].TheClassName.Text = seatName
			Pages.Step2["Class Info"].TheClassPrice.Text = Pages.Step1.Classes[seatName].TheClassPrice.Text
			TweenService:Create(Pages.Step1.ConfirmButton, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(0, 172, 146)}):Play()
			TweenService:Create(Pages.Step1.ConfirmButton.TextLabel, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(Pages.Step1.ConfirmButton.Icon, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			wait(0.75)
			Data["Disabled Buttons"].Step1["Confirm Button"] = false
		else
			if Pages.Step1:FindFirstChild("Alert") then
				pcall(function()
					TweenService:Create(Pages.Step1.Alert, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1.075, 0)}):Play()
					wait(0.75)
					Pages.Step1.Alert:Destroy()
					wait(0.1)
					local alertClone = script.Alert:Clone()
					alertClone.Description.Text = data2 .. seatName
					alertClone.Parent = Pages.Step1
					TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.928, 0)}):Play()
					alertClone.CloseButton.InputBegan:Connect(function(InputObject, gameHandled)
						if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
							if alertdisabled == false then
								alertdisabled = true
								Data.Rippler = PseudoInstance.new("Rippler")
								Data.Rippler.Container = alertClone.CloseButton
								local mouse = Player:GetMouse()
								Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
								wait(0.15)
								TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1.075, 0)}):Play()
								wait(0.75)
								alertClone:Destroy()
								alertdisabled = false
							end
						end
					end)
				end)
			else
				pcall(function()
					local alertClone = script.Alert:Clone()
					alertClone.Description.Text = data2 .. seatName
					alertClone.Parent = Pages.Step1
					TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.928, 0)}):Play()
					alertClone.CloseButton.InputBegan:Connect(function(InputObject, gameHandled)
						if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
							if alertdisabled == false then
								alertdisabled = true
								Data.Rippler = PseudoInstance.new("Rippler")
								Data.Rippler.Container = alertClone.CloseButton
								local mouse = Player:GetMouse()
								Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
								wait(0.15)
								TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1.075, 0)}):Play()
								wait(0.75)
								alertClone:Destroy()
								alertdisabled = false
							end
						end
					end)
				end)
			end
		end
	elseif eventType == "bookingComplete" then
		TweenService:Create(Pages.Step3.TextLabel, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
		TweenService:Create(Pages.Step3.Desc, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
		TweenService:Create(ProgressBar.Parent.Parent.Visual.Step3, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(0, 172, 146)}):Play()
		script.LoadingSymbolScript.Disabled = true
		for i, v in pairs(Pages.Step3.LoadingFrame:GetChildren()) do
			if v.ClassName == "Frame" then
				TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			end
		end
		wait(1)
		Pages.Step3.Desc.Text = "Successfully Checked In"
		wait(0.05)
		TweenService:Create(Pages.Step3.CheckIcon, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.47, 0)}):Play()
		TweenService:Create(Pages.Step3.CheckIcon, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.143, 0, 0.293, 0)}):Play()
		TweenService:Create(Pages.Step3.Desc, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
		wait(4)
		TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = originalCFrame}):Play()
		wait(1)
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
		Camera.CameraType = Enum.CameraType.Custom
		AdminEvent:FireServer("deleteSciUi")
	end
end)

-- Information Event
InformationEvent.OnClientEvent:Connect(function(informationName, newValue)
	for i,v in pairs(Pages.Step2:GetDescendants()) do
		if v.Name == informationName and v.ClassName == "TextLabel" then
			v.Text = newValue
		end
	end
end)

-- Setting information
Pages.Step2.Aircraftt.Aircraft.Text = FlightData["Flight Information"].Aircraft.Value
Pages.Step2.ArrivalTime["Arrival Time"].Text = FlightData["Flight Information"]["Arrival Time"].Value
Pages.Step2.BoardingTime["Boarding Time"].Text = FlightData["Flight Information"]["Boarding Time"].Value
Pages.Step2.Gatee["Gate"].Text = FlightData["Flight Information"]["Gate"].Value
Pages.Step2.FlightOverview["Arrival Long"].Text = FlightData["Flight Information"]["Airport Information"]["Arrival Long"].Value
Pages.Step2.FlightOverview["Arrival Short"].Text = FlightData["Flight Information"]["Airport Information"]["Arrival Short"].Value
Pages.Step2.FlightOverview["Departing Long"].Text = FlightData["Flight Information"]["Airport Information"]["Departing Long"].Value
Pages.Step2.FlightOverview["Departing Short"].Text = FlightData["Flight Information"]["Airport Information"]["Departing Short"].Value


--  TopBar CATEGORY  --

-- Back Button
BackButton.InputBegan:Connect(function(InputObject, gameHandled)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
		Camera.CFrame = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Camera.CFrame
		if Data["Disabled Buttons"].TopBar["Back Button"] == false then
			Data["Disabled Buttons"].TopBar["Back Button"] = true
			Data.Rippler = PseudoInstance.new("Rippler")
			Data.Rippler.Container = BackButton
			local mouse = Player:GetMouse()
			Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
			if Data["Current Step"] == "2" then
				Data["Current Step"] = "1"
				TweenService:Create(Pages, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(-1, 0, 0.5, 0)}):Play()
				TweenService:Create(ProgressBar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.333, 0, 1, 0)}):Play()
				TweenService:Create(ProgressBar.Parent.Parent.Visual.Step1, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 40, 56)}):Play()
				TweenService:Create(ProgressBar.Parent.Parent.Visual.Step2, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(16, 28, 44)}):Play()
				TweenService:Create(BackButton, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
				TweenService:Create(BackButton.TextLabel, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
				TweenService:Create(BackButton.Icon, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
				--TweenService:Create(CloseButton, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.97, 0)}):Play()
				Data["Disabled Buttons"].TopBar["Back Button"] = true
				Data["Disabled Buttons"].Step2["Confirm Button"] = true
				wait(2.5)
				BackButton.Visible = false
				Data["Disabled Buttons"].TopBar["Close Button"] = true
				Data["Disabled Buttons"].Step1["Confirm Button"] = false
			end
		end
	end
end)

BackButton.MouseButton1Click:Connect(function()
	Camera.CFrame = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Camera.CFrame
	if Data["Disabled Buttons"].TopBar["Back Button"] == false then
		Data["Disabled Buttons"].TopBar["Back Button"] = true
		if Data["Current Step"] == "2" then
			Data["Current Step"] = "1"
			TweenService:Create(Pages, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(-1, 0, 0.5, 0)}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.333, 0, 1, 0)}):Play()
			TweenService:Create(ProgressBar.Parent.Parent.Visual.Step1, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 40, 56)}):Play()
			TweenService:Create(ProgressBar.Parent.Parent.Visual.Step2, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(16, 28, 44)}):Play()
			TweenService:Create(BackButton, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			TweenService:Create(BackButton.TextLabel, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
			TweenService:Create(BackButton.Icon, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
			--TweenService:Create(CloseButton, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.97, 0)}):Play()
			Data["Disabled Buttons"].TopBar["Back Button"] = true
			Data["Disabled Buttons"].Step2["Confirm Button"] = true
			wait(2.5)
			BackButton.Visible = false
			Data["Disabled Buttons"].TopBar["Close Button"] = true
			Data["Disabled Buttons"].Step1["Confirm Button"] = false
		end
	end
end)

--	Exit Button
--[[CloseButton.MouseButton1Click:Connect(function()
	if Data["Disabled Buttons"].TopBar["Close Button"] == false then
		for key, value in pairs(Data["Disabled Buttons"]["TopBar"]) do
			Data["Disabled Buttons"]["TopBar"][key] = true
		end
		for key, value in pairs(Data["Disabled Buttons"]["Step0"]) do
			Data["Disabled Buttons"]["Step0"][key] = true
		end
		for key, value in pairs(Data["Disabled Buttons"]["Step1"]) do
			Data["Disabled Buttons"]["Step1"][key] = true
		end
		for key, value in pairs(Data["Disabled Buttons"]["Step2"]) do
			Data["Disabled Buttons"]["Step2"][key] = true
		end

		TweenService:Create(ProgressBar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 1, 0)}):Play()
		TweenService:Create(ProgressBar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 0.5, 0)}):Play()
		TweenService:Create(ProgressBar.Parent.Parent.Visual.Step1, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(16, 28, 44)}):Play()
		TweenService:Create(ProgressBar.Parent.Parent.Visual.Step2, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(16, 28, 44)}):Play()
		TweenService:Create(ProgressBar.Parent.Parent.Visual.Step3, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(16, 28, 44)}):Play()
		TweenService:Create(Pages, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 0.5, 0)}):Play()
		TweenService:Create(BackButton, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
		TweenService:Create(BackButton.TextLabel, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
		TweenService:Create(BackButton.Icon, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
		--TweenService:Create(CloseButton, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1.03, 0)}):Play()

		if Data["Selected Class"] ~= "" then
			AdminEvent:FireServer("closeButtonCheck", Data["Selected Class"])
		end

		wait(1)
		TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = originalCFrame}):Play()
		wait(1.5)

		game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
		Camera.CameraType = Enum.CameraType.Custom
		AdminEvent:FireServer("deleteSciUi")
	end
end)]]--

-- 	Step 0 CATEGORY  --

-- Step 0 Begin Button
Pages.Step0.BeginButton.InputBegan:Connect(function(InputObject, gameHandled)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
		Camera.CFrame = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Camera.CFrame
		if Data["Disabled Buttons"].Step0["Begin Button"] == false then
			Data["Disabled Buttons"].Step0["Begin Button"] = true
			Data.Rippler = PseudoInstance.new("Rippler")
			Data.Rippler.Container = Pages.Step0.BeginButton
			local mouse = Player:GetMouse()
			Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
			TweenService:Create(Pages, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(-1, 0, 0.5, 0)}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.333, 0, 1, 0)}):Play()
			TweenService:Create(ProgressBar.Parent.Parent.Visual.Step1, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 40, 56)}):Play()
			wait(2.5)
			Data["Current Step"] = "1"
		end
	end
end)



--	Step 1 CATEGORY  --

-- Step 1 Class Buttons
if table.getn(Settings.Classes) > 5 then
	Pages.Step1.Classes.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
end

for Classname, ClassData in pairs(Settings.Classes) do
	local newClassButton = Pages.Step1.Classes.Example:Clone()
	newClassButton.Name = Classname
	newClassButton.TheClassName.Text = Classname
	newClassButton.ClassImage.Image = ClassData["Picture"]
	newClassButton.TheClassSeats.Text = FlightData["Flight Seats"][Classname].Value .. " Seats Remaining"
	if ClassData["ID"] == 0 then
		newClassButton.TheClassPrice.Text = "FREE"
	else
		newClassButton.TheClassPrice.Text = MarketplaceService:GetProductInfo(ClassData["ID"], Enum.InfoType.Asset).PriceInRobux .. "R$"
	end
	newClassButton.Visible = true
	newClassButton.Parent = Pages.Step1.Classes
	Data["Disabled Buttons"]["Step1"][newClassButton.Name .. " Button"] = false
	newClassButton.InputBegan:Connect(function(InputObject, gameHandled)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
			Camera.CFrame = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Camera.CFrame
			Data.Rippler = PseudoInstance.new("Rippler")
			Data.Rippler.Container = newClassButton
			local mouse = Player:GetMouse()
			Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
			if Classname == Data["Selected Class"] then
				if Pages.Step1:FindFirstChild("Alert") then
					pcall(function()
						TweenService:Create(Pages.Step1.Alert, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1.075, 0)}):Play()
						wait(0.75)
						Pages.Step1.Alert:Destroy()
						wait(0.1)
						local alertClone = script.Alert:Clone()
						alertClone.Description.Text = "You have already booked an " .. Classname .. " seat"
						alertClone.Parent = Pages.Step1
						TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.928, 0)}):Play()
					end)
				else
					pcall(function()
						local alertClone = script.Alert:Clone()
						alertClone.Description.Text = "You have already booked an " .. Classname .. " seat"
						alertClone.Parent = Pages.Step1
						TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.928, 0)}):Play()
					end)
				end
			else
				if ClassData["ID"] == 0 or ClassData["ID"] == "0" then
					SeatsEvent:FireServer("bookSeat", Classname)
				else 
					if MarketplaceService:PlayerOwnsAsset(Player, ClassData["ID"]) then
						SeatsEvent:FireServer("bookSeat", Classname)
					else
						if Pages.Step1:FindFirstChild("Alert") then
							pcall(function()
								TweenService:Create(Pages.Step1.Alert, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1.075, 0)}):Play()
								wait(0.75)
								Pages.Step1.Alert:Destroy()
								wait(0.1)
								local alertClone = script.Alert:Clone()
								alertClone.Description.Text = "You don't own " .. Classname
								alertClone.Parent = Pages.Step1
								TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.928, 0)}):Play()
							end)
						else
							pcall(function()
								local alertClone = script.Alert:Clone()
								alertClone.Description.Text = "You don't own " .. Classname
								alertClone.Parent = Pages.Step1
								TweenService:Create(alertClone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.928, 0)}):Play()
							end)
						end
					end
				end
			end
		end
	end)
end

-- Step 1 Confirm Button
Pages.Step1.ConfirmButton.InputBegan:Connect(function(InputObject, gameHandled)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
		Camera.CFrame = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Camera.CFrame
		if Data["Disabled Buttons"].Step1["Confirm Button"] == false then
			Data["Disabled Buttons"].Step1["Confirm Button"] = true
			Data["Disabled Buttons"].TopBar["Back Button"] = true
			Data["Disabled Buttons"].TopBar["Close Button"] = true
			--TweenService:Create(CloseButton, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 1.03, 0)}):Play()
			Data.Rippler = PseudoInstance.new("Rippler")
			Data.Rippler.Container = Pages.Step1.ConfirmButton
			local mouse = Player:GetMouse()
			Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
			TweenService:Create(Pages, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(-2, 0, 0.5, 0)}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.6665, 0, 1, 0)}):Play()
			TweenService:Create(ProgressBar.Parent.Parent.Visual.Step1, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(0, 172, 146)}):Play()
			TweenService:Create(ProgressBar.Parent.Parent.Visual.Step2, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 40, 56)}):Play()
			BackButton.Visible = true
			TweenService:Create(BackButton, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
			TweenService:Create(BackButton.TextLabel, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
			TweenService:Create(BackButton.Icon, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
			wait(2.5)
			Data["Disabled Buttons"].TopBar["Back Button"] = false
			Data["Disabled Buttons"].Step2["Confirm Button"] = false
			Data["Current Step"] = "2"
		end
	end
end)

--	Step 2 CATEGORY  --

-- Step 2 Confirm Button
Pages.Step2.ConfirmButton.InputBegan:Connect(function(InputObject, gameHandled)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
		Camera.CFrame = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Camera.CFrame
		if Data["Disabled Buttons"].Step2["Confirm Button"] == false then
			Data["Disabled Buttons"].Step2["Confirm Button"] = true
			Data["Disabled Buttons"].TopBar["Back Button"] = true
			Data["Disabled Buttons"].TopBar["Close Button"] = true
			Data.Rippler = PseudoInstance.new("Rippler")
			Data.Rippler.Container = Pages.Step2.ConfirmButton
			local mouse = Player:GetMouse()
			Data.Rippler:Ripple(InputObject.Position.X, InputObject.Position.Y)
			TweenService:Create(Pages, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(-3, 0, 0.5, 0)}):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)}):Play()
			TweenService:Create(ProgressBar.Parent.Parent.Visual.Step2, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(0, 172, 146)}):Play()
			TweenService:Create(ProgressBar.Parent.Parent.Visual.Step3, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(28, 40, 56)}):Play()
			TweenService:Create(BackButton, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			TweenService:Create(BackButton.TextLabel, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
			TweenService:Create(BackButton.Icon, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
			wait(5)
			BackButton.Visible = false
			Data["Current Step"] = "3"
			SeatsEvent:FireServer("bookingComplete", Data["Selected Class"])
		end
	end
end)

originalCFrame = Camera.CFrame

Camera.CameraType = Enum.CameraType.Scriptable
TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = workspace["DiscoverTech | Self Check In"]["Self Check In Machines"][script["Using Machine"].Value].Camera.CFrame}):Play()

script.LoadingSymbolScript.Disabled = false
script.BottomBar_Control.Disabled = false
