-- -------------------------------------------------------------------------- --
--                                    Types                                   --
-- -------------------------------------------------------------------------- --

---@alias CameraFOVConfig { bEnabled: boolean, bOverrideCutsceneFOV: boolean, fWorldFOV: number, fInteriorFOV: number }
---@alias CameraFOVData { configUserdata: userdata?, configFile: string, command: string, helpText: string }
---@alias CameraFOVArea "world"|"interior"

-- -------------------------------------------------------------------------- --
--                                  Structure                                 --
-- -------------------------------------------------------------------------- --

---@class CameraFOV
---@field private _data CameraFOVData
---@field private _ReadSettings fun(self: CameraFOV): nil
---@field private _RegisterCommand fun(self: CameraFOV): nil
---@field config CameraFOVConfig
CameraFOV = {
	_data = {
		configUserdata = nil,

		configFile = "settings.txt",
		command = "camerafov",
		helpText = [[Usage:
  - camerafov <toggle> (Toggle the mod ON/OFF. <toggle>: "enable"|"disable")
  - camerafov set <area> <fov> (Change the camera FOV. <area>: "world"|"interior", <fov>: number)]],
	},

	config = {
		bEnabled = true,
		bOverrideCutsceneFOV = false,
		fWorldFOV = 85.0,
		fInteriorFOV = 71.0,
	},
}
CameraFOV.__index = CameraFOV

-- -------------------------------------------------------------------------- --
--                              Instance Creation                             --
-- -------------------------------------------------------------------------- --

function CameraFOV.new()
	local instance = setmetatable({}, CameraFOV)

	instance:_ReadSettings()
	instance:_RegisterCommand()

	return instance
end

-- -------------------------------------------------------------------------- --
--                               Private Methods                              --
-- -------------------------------------------------------------------------- --

function CameraFOV:_ReadSettings()
	-- Check config file
	self._data.configUserdata = LoadConfigFile(self._data.configFile)
	if IsConfigMissing(self._data.configUserdata) then
		error(string.format('Missing config file "%s".', self._data.configFile))
	end

	---@param value string
	---@return boolean
	local function checkBoolean(value)
		return ({ ["true"] = true, ["false"] = true })[value]
	end

	---@param value string
	---@return number?
	local function checkNumber(value)
		return tonumber(value)
	end

	-- Read setting value
	for key, value in pairs(self.config) do
		-- Get the value
		local settingValue = GetConfigValue(self._data.configUserdata, key)

		-- If no value specified
		if not settingValue then
			error(string.format('No value specified on key "%s".', key))
		end

		-- If the value is not valid
		local errMsgInvalidValue =
			string.format('Invalid value on key "%s".\n', key)
		if type(value) == "boolean" then
			if not checkBoolean(settingValue) then
				error(
					errMsgInvalidValue .. 'The value must be either "true" or "false".'
				)
			end
		else
			if not checkNumber(settingValue) then
				error(errMsgInvalidValue .. "The value must be a valid number.")
			end
		end

		-- Apply the setting value from settings.txt
		local convertedValue = ({
			["boolean"] = settingValue == "true",
			["number"] = tonumber(settingValue),
		})[type(value)]
		self.config[key] = convertedValue
	end
end

function CameraFOV:_RegisterCommand()
	if not DoesCommandExist(self._data.command) then
		---@param param? string
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
				PrintError(
					'Command action type must be either "enable"|"disable"|"set".'
				)
				return false
			end

			return true
		end

		---@param param? string
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

		---@param param? string
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

		SetCommand(
			self._data.command,

			---@param ... string
			function(...)
				if not isFirstParamValid(arg[1]) then
					return
				end

				if ({ ["enable"] = true, ["disable"] = true })[arg[1]] then
					self:Toggle(arg[1] == "enable")

					-- If turned OFF, revert back the FOV to default
					if not self:IsEnabled() then
						CameraDefaultFOV()
					end
				elseif arg[1] == "set" then
					-- If param2 or param3 is not valid
					if not (isSecondParamValid(arg[2]) and isThirdParamValid(arg[3])) then
						return
					end

					-- Apply the new FOV value
					self:SetFOV(string.lower(arg[2]), tonumber(arg[3]) --[[@as number]])
				end
			end,

			false,
			self._data.helpText
		)
	end
end

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

---@param toggle boolean
function CameraFOV:Toggle(toggle)
	self.config.bEnabled = toggle
end

---@return boolean
function CameraFOV:IsEnabled()
	return self.config.bEnabled == true
end

---@return boolean
function CameraFOV:IsCutsceneFOVOverriden()
	return self.config.bOverrideCutsceneFOV
end

---@param area CameraFOVArea
---@return number
function CameraFOV:GetFOV(area)
	local key = "f" .. CapitalizeFirstLetter(area) .. "FOV"
	return self.config[key] --[[@as number]]
end

---@param area CameraFOVArea
---@param fov number
function CameraFOV:SetFOV(area, fov)
	local key = "f" .. CapitalizeFirstLetter(area) .. "FOV"
	self.config[key] = fov
end
