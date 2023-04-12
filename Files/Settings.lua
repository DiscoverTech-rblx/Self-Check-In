local Settings = {}

--[[
╔═══╗────────────────╔════╗────╔╗  .
╚╗╔╗║────────────────║╔╗╔╗║────║║
─║║║╠╦══╦══╦══╦╗╔╦══╦╩╣║║╠╩═╦══╣╚═╗
─║║║╠╣══╣╔═╣╔╗║╚╝║║═╣╔╝║║║║═╣╔═╣╔╗║
╔╝╚╝║╠══║╚═╣╚╝╠╗╔╣║═╣║─║║║║═╣╚═╣║║║
╚═══╩╩══╩══╩══╝╚╝╚══╩╝─╚╝╚══╩══╩╝╚╝

Product: Self Check In
Verison: 2.0

]]--

Settings.Basic = {
	["Tool Location"] = game:GetService("ServerStorage"); -- The place location where your ticket tools are located.
	["Airline Name"] = "GROUP_NAME"; -- The name of your airline/group OR set to "GROUP_NAME" to be automatically put as your Roblox group's name.
	["Line Colour"] = Color3.fromRGB(0, 170, 255); -- The Color3 value that you want the line at the bottom to be.
	["Class Colour"] = Color3.fromRGB(0, 170, 255); -- The Color3 value that you want the selected colour of the class to be.
	["Button Colour"] = Color3.fromRGB(0, 172, 146); -- The Color3 value that you want the main buttons to be such as NEXT buttons and CONFIRM buttons.
	["Class Ticket Location"] = game.ServerStorage; -- The place where the tickets are stored in your game.
	["Background Image"] = "http://www.roblox.com/asset/?id=9793017231"
}

Settings.Classes = { -- Add a new value like the one on line 16 to add more classes. The string represents the name of the class, and the table represents the assetId one must own in order to book the class. 0 = none required
	["Economy Class"] = {
		["ID"] = 0; -- The asset ID that the user must own to book this class. (SET AS 0 TO MAKE IT FREE)
		["Ticket Name"] = "Economy Ticket"; -- The name of the tool (ticket) that is given to the user once they have checked in.
		["Picture"] = "rbxassetid://0" -- The picture displayed on the 'Select Class' part of the SCI.
	};
	["Business Class"] = {
		["ID"] = 0; -- The asset ID that the user must own to book this class. (SET AS 0 TO MAKE IT FREE)
		["Ticket Name"] = "Business Ticket"; -- The name of the tool (ticket) that is given to the user once they have checked in.
		["Picture"] = "rbxassetid://0" -- The picture displayed on the 'Select Class' part of the SCI.
	};
	["First Class"] = {
		["ID"] = 0; -- The asset ID that the user must own to book this class. (SET AS 0 TO MAKE IT FREE)
		["Ticket Name"] = "First Ticket"; -- The name of the tool (ticket) that is given to the user once they have checked in.
		["Picture"] = "rbxassetid://0" -- The picture displayed on the 'Select Class' part of the SCI.
	};
	["Investor Class"] = {
		["ID"] = 0; -- The asset ID that the user must own to book this class. (SET AS 0 TO MAKE IT FREE)
		["Ticket Name"] = "Investor Ticket"; -- The name of the tool (ticket) that is given to the user once they have checked in.
		["Picture"] = "rbxassetid://0" -- The picture displayed on the 'Select Class' part of the SCI.
	};
};

Settings.Group = {
	["Group ID"] = 7610424; -- Enter your group ID here.
	["Staff ID"] = 0; -- The minimum rank ID that can configure the Check In system in-game (flight information, seats remaining, enable/disable etc).
};

Settings.Other = {
	["Rename Users"] = true; -- When value is true, the player's will be renamed to their class for example: uhCrypto | First Class
	["Log Check Ins"] = true; -- When value is true, everytime a player checks in or checks out it will be logged in the 'Server' tab of the Developer Console.
};

return(Settings)
