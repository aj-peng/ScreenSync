--[[

--== HOW TO USE! -- This should be in local script. ==--

	local ScreenSync = require(Path.To.ScreenSync)
	local Songs = Path.To.Songs -- In SoundService
	local SongList = Songs:GetChildren()

	local ExampleGui = Path.To.Gui
	local Comp1 = ExampleGui.Path.To.Comp1
	local Comp2 = ExampleGui.Path.To.Comp2

	local screenSync = ScreenSync.new(ExampleGui, SongList)
	local comp1Sync = screenSync:GetComponent(Comp1)
	local comp2Sync = screenSync:GetComponent(Comp2)


		{
			params :
				sizeSync : boolean,        -- If true, will sync size
				transparencySync : boolean -- If true, will sync transparency
				scalar : number			   -- Size multiplier
		}
		
	local scale = 1 -- Can be any number, but I recommend betwen 0.5 and 5 depending on the song.
	comp1Sync:Enable(true, false, scale)
	comp2Sync:Enable(true, false, scale)

  --Song playing logic below.
	--Have fun!
	
]]--
