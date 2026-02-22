--!strict
local TweenService = game:GetService("TweenService")
local ResetTweenInfo = TweenInfo.new(0.5)

local ComponentGen = require(script.ComponentSync)
local Def = require(script.Definitions)

local ScreenGen: Def.ScreenGen = {} :: Def.ScreenGen
ScreenGen.__index = ScreenGen

local function ResetComponent(component : Def.ComponentSync)
	component.component.Size = component.default.size
	component.component.Transparency = component.default.transparency
end

function ScreenGen.new(rootGui: ScreenGui,  songs : {Sound}): Def.ScreenSync
	local componentIndex: {[GuiObject]: Def.ComponentSync} = {}

	local self = setmetatable({
		songs = songs,
		rootGui = rootGui,
		componentIndex = componentIndex,
		connections = {}
	}, ScreenGen)

	for _, component in ipairs(rootGui:GetChildren()) do
		if component:IsA("GuiObject") then
			componentIndex[component] = ComponentGen.new(component, self)
		end
	end

	return self
end

function ScreenGen:Enable()
	local current : Sound? = nil
	for _, song in self.songs do
		if song:IsA("Sound") then	
			table.insert(self.connections, 
				song.Paused:Connect(function()
					if current == song then
						self:DesyncComponents()
					end
				end)
			)
			table.insert(self.connections,
				song.Stopped:Connect(function()
					if current == song then
						self:DesyncComponents()
					end
				end)
			)
			table.insert(self.connections,
				song.Ended:Connect(function()
					if current == song then
						self:DesyncComponents()
					end
				end)
			)
			table.insert(self.connections,
				song.Played:Connect(function()
					current = song
					if current then
						self:SyncComponents(current, song)
					end
				end)
			)
			table.insert(self.connections,
				song.Resumed:Connect(function()
					current = song
					if current then
						self:SyncComponents(current, song)
					end
				end)
			)
		end
	end
	
	return self
end

function ScreenGen:Disable() 
	for _, connection in pairs(self.connections) do
		connection:Disconnect()
	end
	table.clear(self.connections)

	for _, compSync in pairs(self.componentIndex) do
		compSync:Disable()
	end

	return nil
end

function ScreenGen:SyncComponents(current, song)
	self:DesyncComponents()
	for _, compSync in self.componentIndex do
		compSync:Sync(song)
	end
end

function ScreenGen:DesyncComponents()
	for _, compSync in self.componentIndex do
		ResetComponent(compSync)
	end
end

function ScreenGen:GetComponent(component: GuiObject)
	return self.componentIndex[component]
end


return ScreenGen