--!strict
local TweenService = game:GetService("TweenService")
local ComponentGen = require(script.ComponentSync)
local Def = require(script.Definitions)

local ScreenGen: Def.ScreenGen = {} :: Def.ScreenGen
ScreenGen.__index = ScreenGen

local function ResetComponent(component : Def.ComponentSync)
	component.component.Transparency = component.baseTransparency
	component.component.Size = component.baseSize
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
	
	self:EnableSongSync()

	return self
end

function ScreenGen:GetComponent(component: GuiObject)
	return self.componentIndex[component]
end

function ScreenGen:EnableSongSync()
	local songs = self.songs
	if not songs then 
		return self
	end
	
	local currentSong : Sound = nil
	local function UnsyncComponents()
		for _, compSync in self.componentIndex do
			ResetComponent(compSync)
		end
	end
	local function SyncComponents(song: Sound)
		UnsyncComponents()
		currentSong = song
		for _, compSync in self.componentIndex do
			compSync:Sync(song)
		end
	end
	
	for _, song : Sound in songs do
		if song:IsA("Sound") then	
			table.insert(self.connections, 
				song.Paused:Connect(function()
					if currentSong == song then
						UnsyncComponents()
					end
				end)
			)
			table.insert(self.connections,
				song.Stopped:Connect(function()
					if currentSong == song then
						UnsyncComponents()
					end
				end)
			)
			table.insert(self.connections,
				song.Ended:Connect(function()
					if currentSong == song then
						UnsyncComponents()
					end
				end)
			)
			table.insert(self.connections,
				song.Played:Connect(function()
					SyncComponents(song)
				end)
			)
			table.insert(self.connections,
				song.Resumed:Connect(function()
					SyncComponents(song)
				end)
			)
		end
	end
	return self
end

function ScreenGen:Destroy()
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)

	for _, compSync in self.componentIndex do
		compSync:Destroy()
	end
	
	setmetatable(self, nil)
	table.clear(self)
	
	return nil
end

return ScreenGen
