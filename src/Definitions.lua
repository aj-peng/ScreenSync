--!strict
local Definition = {}

export type ComponentSync = typeof(
	setmetatable(
		{} :: {
			component: GuiObject,
			guiSync: ScreenSync,
			
			default : {
				size : UDim2,
				transparency : number
			},
			
			syncSize : boolean,
			syncTransparency : boolean,
			syncScale : number,
			
			connection : RBXScriptConnection?
		},
		{} :: ComponentGen
	)
)

export type ScreenSync = typeof(
	setmetatable(
		{} :: {
			songs: {Sound},
			rootGui: ScreenGui,
			componentIndex: {[GuiObject]: ComponentSync},
			connections : {RBXScriptConnection}
		},
		{} :: ScreenGen
	)
)

export type ScreenGen = {
	__index: ScreenGen,
	new: (rootGui: ScreenGui, songs : {Sound}) -> ScreenSync,
	
	Enable : (ScreenSync) -> (ScreenSync),
	Disable : (ScreenSync) -> (),
	
	SyncComponents : (ScreenSync, current : Sound, song : Sound) -> (),
	DesyncComponents : (ScreenSync) -> (),
	GetComponent: (ScreenSync , component : GuiObject) -> (ComponentSync?)
}

export type ComponentGen = {
	__index: ComponentGen,
	new: (component: GuiObject, guiSync: ScreenSync) -> (ComponentSync),

	Enable: (ComponentSync, syncSize : boolean, syncTransparency : boolean, syncScale : number) -> (ComponentSync),
	Disable: (ComponentSync) -> ComponentSync,
	Sync : (ComponentSync, song : Sound) -> (),
	Config : {
		sizeConversion : number,
		minTransparency : number,
		maxTransparency : number,
		transparencyConversion : number
	}
}

return Definition