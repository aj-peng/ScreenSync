--!strict
local Definition = {}

export type ComponentSync = typeof(
	setmetatable(
		{} :: {
			component: GuiObject,
			guiSync: ScreenSync,
			
			baseSize : UDim2,
			baseTransparency : number,
			
			syncSize : boolean,
			syncTransparency : boolean,
			syncScale : number,
			
			connections : {RBXScriptConnection},
			currentAlphaTween : Tween,
			currentSizeTween : Tween,
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
	
	GetComponent: (ScreenSync , component : GuiObject) -> ComponentSync?,
	EnableSongSync : (ScreenSync) -> ScreenSync,
	Destroy : (ScreenSync) -> ()
}

export type ComponentGen = {
	__index: ComponentGen,
	new: (component: GuiObject, guiSync: ScreenSync) -> ComponentSync,

	Enable: (ComponentSync, syncSize : boolean, syncTransparency : boolean, syncScale : number) -> ComponentSync,
	Disable: (ComponentSync) -> ComponentSync,
	Sync : (ComponentSync, song : Sound) -> (),
	Destroy : (ComponentSync) -> ()
}

return Definition
