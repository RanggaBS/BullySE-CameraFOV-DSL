-- -------------------------------------------------------------------------- --
--                                Load Scripts                                --
-- -------------------------------------------------------------------------- --

for _, filename in ipairs({ "Config", "DSLCommandManager", "CameraFOV" }) do
	LoadScript("src/" .. filename .. ".lua")
end

-- -------------------------------------------------------------------------- --
--                               Global Variable                              --
-- -------------------------------------------------------------------------- --

---@class CAMERA_FOV
local privateFields = {
	_INTERNAL = {
		INITIALIZED = false,

		COMMAND = {
			NAME = "camerafov",
			HELP_TEXT = [[Usage:
  - camerafov <toggle> (Toggle the mod ON/OFF. <toggle>: "enable"|"disable")
  - camerafov set <area> <fov> (Change the camera FOV. <area>: "world"|"interior", <fov>: number)]],
		},

		CONFIG = {
			FILENAME_WITH_EXTENSION = "settings.ini",
			DEFAULT_SETTING = {
				bEnabled = false,

				bOverrideCutsceneFOV = false,
				fWorldFOV = 90.0,
				fInteriorFOV = 90.0,
			},
		},

		INSTANCE = {
			---@type CameraFOV
			CameraFOV = nil,

			---@type Config
			Config = nil,
		},
	},
}

-- -------------------------------------------------------------------------- --
--                           Private Static Methods                           --
-- -------------------------------------------------------------------------- --

function privateFields._RegisterCommand()
	local command = privateFields._INTERNAL.COMMAND
	local instance = privateFields._INTERNAL.INSTANCE

	---@param param string
	---@return boolean
	local function isFirstParamValid(param)
		if not param or param == "" then
			PrintError("Command action type didn't specified.")
			return false
		end

		local actionType = {
			["enable"] = true,
			["disable"] = true,
			["set"] = true,
		}
		param = string.lower(param)
		if not actionType[param] then
			PrintError('Command action type must be either "enable"|"disable"|"set".')
			return false
		end

		return true
	end

	---@param param string
	---@return boolean
	local function isSecondParamValid(param)
		if not param or param == "" then
			PrintError("Area didn't specified.")
			return false
		end

		param = string.lower(param)
		if not ({ ["world"] = true, ["interior"] = true })[param] then
			PrintError('Area must be either "world"|"interior"')
			return false
		end

		return true
	end

	---@param param string
	---@return boolean
	local function isThirdParamValid(param)
		if not param or param == "" then
			PrintError("FOV value didn't specified.")
			return false
		end

		if not tonumber(param) then
			PrintError("Invalid number.")
			return false
		end

		return true
	end

	if DSLCommandManager.IsAlreadyExist(command.NAME) then
		DSLCommandManager.Unregister(command.NAME)
	end

	DSLCommandManager.Register(
		command.NAME,

		---@param ... string
		function(...)
			local actionType = arg[1]
			local area = arg[2]
			local fovNumber = arg[3]

			if not isFirstParamValid(actionType) then
				return
			end

			if ({ ["enable"] = true, ["disable"] = true })[actionType] then
				instance.CameraFOV:SetEnabled(actionType == "enable")

				-- If turned OFF, revert back the FOV to default
				if not instance.CameraFOV:IsEnabled() then
					CameraDefaultFOV()
				end
				--
			elseif actionType == "set" then
				-- If param2 or param3 is not valid
				if not (isSecondParamValid(area) and isThirdParamValid(fovNumber)) then
					return
				end

				-- Apply the new FOV value
				instance.CameraFOV:SetFOVInArea(
					string.lower(area),
					tonumber(fovNumber) --[[@as number]]
				)
			end
		end,
		{
			rawArgument = false,
			helpText = command.HELP_TEXT,
		}
	)
end

-- -------------------------------------------------------------------------- --

privateFields.__index = privateFields

---@class CAMERA_FOV
_G.CAMERA_FOV_MOD = setmetatable({
	VERSION = "1.1.0",

	DATA = {
		-- The core mod state.
		IS_ENABLED = true,
	},
}, privateFields)

-- -------------------------------------------------------------------------- --
--                            Public Static Methods                           --
-- -------------------------------------------------------------------------- --

local internal = CAMERA_FOV_MOD._INTERNAL
local instance = internal.INSTANCE

---@return CameraFOV
function CAMERA_FOV_MOD.GetSingleton()
	if not instance.CameraFOV then
		local conf = instance.Config

		instance.CameraFOV =
			CameraFOV.new(conf:GetSettingValue("bEnabled") --[[@as boolean]], {
				worldFOV = conf:GetSettingValue("fWorldFOV") --[[@as number]],
				interiorFOV = conf:GetSettingValue("fInteriorFOV") --[[@as number]],
				overrideCutsceneFOV = conf:GetSettingValue("bOverrideCutsceneFOV") --[[@as boolean]],
			})
	end

	return instance.CameraFOV
end

function CAMERA_FOV_MOD.Init()
	if not internal.INITIALIZED then
		instance.Config = Config.new(
			"src/" .. internal.CONFIG.FILENAME_WITH_EXTENSION,
			internal.CONFIG.DEFAULT_SETTING
		)

		instance.CameraFOV = CAMERA_FOV_MOD.GetSingleton()

		CAMERA_FOV_MOD._RegisterCommand()

		internal.INITIALIZED = true

		-- Delete

		CameraFOV = nil --[[@diagnostic disable-line]]
		Config = nil --[[@diagnostic disable-line]]

		collectgarbage()
	end
end

---@return string
function CAMERA_FOV_MOD.GetVersion()
	return CAMERA_FOV_MOD.VERSION
end

---@return boolean
function CAMERA_FOV_MOD.IsEnabled()
	return CAMERA_FOV_MOD.DATA.IS_ENABLED
end

---@param enable boolean
function CAMERA_FOV_MOD.SetEnabled(enable)
	CAMERA_FOV_MOD.DATA.IS_ENABLED = enable

	-- Also enable
	instance.CameraFOV:SetEnabled(CAMERA_FOV_MOD.DATA.IS_ENABLED)
end
