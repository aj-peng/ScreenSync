--!strict
local TweenService = game:GetService("TweenService")
local Def = require(script.Parent.Definitions)

local AlphaTween =  TweenInfo.new(0.05, Enum.EasingStyle.Bounce)
local SizeTween = TweenInfo.new(0.05, Enum.EasingStyle.Bounce)
local FadeTween = TweenInfo.new(3, Enum.EasingStyle.Linear)

local ComponentGen: Def.ComponentGen = {} :: Def.ComponentGen
ComponentGen.__index = ComponentGen

function ComponentGen.new(component: GuiObject, guiSync: Def.ScreenSync): Def.ComponentSync
	local self = setmetatable({
		component = component,
		guiSync = guiSync,
		
		baseSize = component.Size,
		baseTransparency = component.Transparency,
		
		syncSize = false,
		syncTransparency = false,
		syncScale = 1,
		
		connections = {},
		currentAlphaTween = nil,
		currentSizeTween = nil,
		
	}, ComponentGen)
	
	return self
end

function ComponentGen:Sync(song : Sound)
	local scale = self.syncScale
	local baseSize = self.baseSize
	local component = self.component
	
	if self.syncSize then
		task.spawn(function()
			local conversion = 5_000
			while song.IsPlaying and self.guiSync do
				local loudness = song.PlaybackLoudness
				local converted = loudness / conversion * (song.Volume)

				local newXScale = baseSize.X.Scale + converted * scale
				local newYScale = baseSize.Y.Scale + converted * scale
				local newXOffset = baseSize.X.Offset
				local newYOffset = baseSize.Y.Offset

				local newSize = UDim2.new(newXScale, newXOffset, newYScale, newYOffset)
				
				if self.currentSizeTween then
					self.currentSizeTween:Cancel()
					self.currentSizeTween:Destroy()
				end
				
				self.currentSizeTween = TweenService:Create(component, SizeTween, {Size = newSize})
				self.currentSizeTween:Play()
				task.wait()
			end
		end)
	end
	if self.syncTransparency then
		task.spawn(function()
			local conversion = 1_000
			local minTransparency = 0.6 
			local maxTransparency = 0.8
			local range = maxTransparency - minTransparency

			while song.IsPlaying and self.guiSync do
				local loudness = song.PlaybackLoudness
				local converted = math.min(loudness / conversion, 1)
				local newTransparency = maxTransparency - (range * converted)
				
				if self.currentAlphaTween then
					self.currentAlphaTween:Cancel()
					self.currentAlphaTween:Destroy()
				end
				
				self.currentAlphaTween = TweenService:Create(component, AlphaTween, {Transparency = newTransparency})
				self.currentAlphaTween:Play()
				task.wait()
			end
		end)
	end
end

function ComponentGen:Enable(syncSize : boolean, syncTransparency : boolean, syncScale : number)
	self.syncSize = syncSize
	self.syncTransparency = syncTransparency
	self.syncScale = syncScale
	
	return self
 end

function ComponentGen:Disable()
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	
	if self.currentSizeTween then
		self.currentSizeTween:Cancel()
		self.currentSizeTween:Destroy()
	end

	if self.currentAlphaTween then
		self.currentAlphaTween:Cancel()
		self.currentAlphaTween:Destroy()
	end
	
	if self.component and self.component.Parent then
		self.component.Size = self.baseSize
		self.component.Transparency = self.baseTransparency
	end
	
	return self
end

function ComponentGen:Destroy()
	self:Disable()
	setmetatable(self, nil)
	table.clear(self)
	
	return nil
end

return ComponentGen
