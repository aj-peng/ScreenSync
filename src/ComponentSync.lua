--!strict
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Def = require(script.Parent.Definitions)

local enableInfo =  TweenInfo.new(0.05, Enum.EasingStyle.Cubic)
local disableInfo = TweenInfo.new(0.75, Enum.EasingStyle.Cubic)

local ComponentGen: Def.ComponentGen = {} :: Def.ComponentGen
ComponentGen.__index = ComponentGen

ComponentGen.Config = {
	sizeConversion = 5_000,
	maxTransparency = 0.8,
	minTransparency = 0.6,
	transparencyConversion = 1_000
}

function ComponentGen.new(component: GuiObject, guiSync: Def.ScreenSync): Def.ComponentSync
	local self = setmetatable({
		component = component,
		guiSync = guiSync,
		
		default = {
			size = component.Size,
			transparency = component.Transparency,
		},
		
		syncSize = false,
		syncTransparency = false,
		syncScale = 1,
		
		connection = nil
	}, ComponentGen)
	
	return self
end

function ComponentGen:Sync(song: Sound)
	self:Disable()

	self.connection = RunService.RenderStepped:Connect(function()
		if not song.IsPlaying or not self.guiSync then
			self:Disable()
			return
		end

		local loudness = song.PlaybackLoudness
		local transparency = self.default.transparency
		local size = self.default.size
		
		if self.syncSize then
			local scale = self.syncScale
			local converted = (loudness / ComponentGen.Config.sizeConversion) * scale
			
			size = UDim2.new(
				size.X.Scale + converted,
				size.X.Offset,
				size.Y.Scale + converted,
				size.Y.Offset
			)
		end
		
		if self.syncTransparency then
			local range = ComponentGen.Config.maxTransparency - ComponentGen.Config.minTransparency
			local converted = math.clamp(loudness / ComponentGen.Config.transparencyConversion, 0, 1)
			transparency = ComponentGen.Config.maxTransparency - (range * converted)
		end
		
		TweenService:Create(self.component, enableInfo, {Size = size, Transparency = transparency}):Play()
	end)
end

function ComponentGen:Enable(syncSize : boolean, syncTransparency : boolean, syncScale : number)
	self.syncSize = syncSize
	self.syncTransparency = syncTransparency
	self.syncScale = syncScale
	
	return self
 end

function ComponentGen:Disable()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
	
	if self.component and self.component.Parent then
		TweenService:Create(self.component, disableInfo, {Size = self.default.size, Transparency = self.default.transparency}):Play()
		
		-- self.component.Size = self.default.size
		-- self.component.Transparency = self.default.transparency
	end
	
	return self
end

return ComponentGen