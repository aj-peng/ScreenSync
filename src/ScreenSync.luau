--!strict
local TweenService = game:GetService("TweenService")
local ComponentGen = require(script.ComponentSync)
local Def = require(script.Definitions)

local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Linear)

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
	local function OnPlay(song : Sound, baseVolume : number)
		if currentSong == song then
			return
		end

		if currentSong then
			local muteSong = currentSong
			local muteTween = TweenService:Create(muteSong, FadeTween, 
				{
					Volume = 0
				}
			)
			muteTween:Play()
			muteTween.Completed:Once(function()
				muteTween:Destroy()
				if muteSong ~= currentSong then
					muteSong:Stop()
				end
			end)
		end

		song.Volume = 0.1
		currentSong = song
		local fadeInTween = TweenService:Create(song, FadeTween, {Volume = baseVolume})
		fadeInTween:Play()

		for _, compSync in self.componentIndex do
			compSync:Sync(song)
		end
	end
	
	local function OnStop()
		currentSong = nil
		for _, compSync in self.componentIndex do
			ResetComponent(compSync)
		end
	end
	
	
	for _, song : Sound in songs do
		if song:IsA("Sound") then
			local baseVolume = song.Volume
			song.Volume = 0
			
			table.insert(self.connections, 
				song.Paused:Connect(OnStop)
			)
			table.insert(self.connections,
				song.Stopped:Connect(OnStop)
			)
			table.insert(self.connections,
				song.Ended:Connect(OnStop)
			)
			table.insert(self.connections,
				song.Played:Connect(function()
					OnPlay(song, baseVolume)
				end)
			)
			table.insert(self.connections,
				song.Resumed:Connect(function()
					OnPlay(song, baseVolume)
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
