--[[ 
	Bully SE: Camera Field of View (FOV)
	Author: RBS ID
	
	Requirements:
	  - Derpy's Script Loader version alpha 3 or greater
]]

-- -------------------------------------------------------------------------- --
--                                    Init                                    --
-- -------------------------------------------------------------------------- --

-- There's a bug below version alpha 3, when calling the `GetConfigValue`
-- function, it always returns `nil`.
RequireLoaderVersion(3)

-- -------------------------------------------------------------------------- --
--                                 Entry Point                                --
-- -------------------------------------------------------------------------- --

function main()
	while not SystemIsReady() do
		Wait(0)
	end

	LoadScript("src/setup.lua")

	CAMERA_FOV_MOD.Init()

	local camFov = CAMERA_FOV_MOD.GetSingleton()

	while true do
		Wait(0)

		if CAMERA_FOV_MOD.IsEnabled() and camFov:IsEnabled() then
			camFov:ApplyToActualCameraFOV()
		end
	end
end
