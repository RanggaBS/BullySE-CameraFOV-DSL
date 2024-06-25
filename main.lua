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
---function, it always returns `nil`.
RequireLoaderVersion(3)

-- -------------------------------------------------------------------------- --
--                                 Entry Point                                --
-- -------------------------------------------------------------------------- --

function main()
	while not SystemIsReady() do
		Wait(0)
	end

	LoadScript("setup.lua")

	local camFov = CAMERA_FOV_MOD.GetSingleton()

	---@param fov number
	local function setFOV(fov)
		if CameraGetFOV() ~= fov then
			if
				camFov:IsCutsceneFOVOverriden()
				-- If not in a cutscene & not in super slingshot aim camera (fix cannot
				-- zoom further while in super slingshot aim camera)
				or (GetCutsceneRunning() == 0 and CameraGetActive() ~= 2)
			then
				CameraSetFOV(fov)
			end
		end
	end

	while true do
		Wait(0)

		if camFov:IsEnabled() then
			-- If the player is in the main world (outdoors)
			if AreaGetVisible() == 0 then
				setFOV(camFov:GetFOV("world"))

				-- If the player is indoors
			else
				setFOV(camFov:GetFOV("interior"))
			end
		end
	end
end
