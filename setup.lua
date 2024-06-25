-- -------------------------------------------------------------------------- --
--                                Load Scripts                                --
-- -------------------------------------------------------------------------- --

for _, filename in ipairs({ "utils", "CameraFOV" }) do
	LoadScript(filename .. ".lua")
end

-- -------------------------------------------------------------------------- --
--                               Global Variable                              --
-- -------------------------------------------------------------------------- --

---@class CameraFOVMod
---@field private _VERSION string
---@field private _INSTANCE CameraFOV?
CAMERA_FOV_MOD = {
	_VERSION = "1.0.0",

	_INSTANCE = nil,
}

---@return string
function CAMERA_FOV_MOD.GetVersion()
	return CAMERA_FOV_MOD._VERSION
end

---@return CameraFOV
function CAMERA_FOV_MOD.GetSingleton()
	if CAMERA_FOV_MOD._INSTANCE then
		return CAMERA_FOV_MOD._INSTANCE
	end

	CAMERA_FOV_MOD._INSTANCE = CameraFOV.new()

	-- Delete
	---@diagnostic disable-next-line: assign-type-mismatch
	CameraFOV = nil

	collectgarbage()

	return CAMERA_FOV_MOD._INSTANCE
end
