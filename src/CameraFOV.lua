-- -------------------------------------------------------------------------- --
--                                    Types                                   --
-- -------------------------------------------------------------------------- --

---@alias CameraFOV_Area "world"|"interior"
---@alias CameraFOV_Options { worldFOV?: number, interiorFOV?: number, overrideCutsceneFOV?: boolean }

-- -------------------------------------------------------------------------- --
--                                 Attributes                                 --
-- -------------------------------------------------------------------------- --

---@class CameraFOV
---@field new fun(enable: boolean, options?: CameraFOV_Options): CameraFOV
---@field private _isSimpleFirstPersonInstalled boolean
---@field private _isSimpleCustomThirdPersonInstalled boolean
---@field private _CheckSimpleFirstPersonInstalled fun(): boolean
---@field private _CheckSimpleCustomThirdPersonInstalled fun(): boolean
---@field isEnabled boolean
---@field worldFOV number
---@field interiorFOV number
---@field shouldOverrideCutsceneFOV boolean
---@field IsEnabled fun(self: CameraFOV): boolean
---@field SetEnabled fun(self: CameraFOV, enable: boolean): nil
---@field IsCutsceneFOVOverriden fun(self: CameraFOV): boolean
---@field SetOverrideCutsceneFOV fun(self: CameraFOV, enable: boolean): nil
---@field GetWorldFOV fun(self: CameraFOV): number
---@field SetWorldFOV fun(self: CameraFOV, fov: number): nil
---@field GetInteriorFOV fun(self: CameraFOV): number
---@field SetInteriorFOV fun(self: CameraFOV, fov: number): nil
---@field GetFOVInArea fun(self: CameraFOV, area: CameraFOV_Area): number
---@field GetFOVInAreaId fun(self: CameraFOV, areaId: integer): number
---@field GetFOVInCurrentArea fun(self: CameraFOV): number
---@field SetFOVInArea fun(self: CameraFOV, area: CameraFOV_Area, fov: number): nil
---@field SetFOVInAreaId fun(self: CameraFOV, areaId: integer, fov: number): nil
---@field ApplyToActualCameraFOV fun(self: CameraFOV): nil
CameraFOV = {}
CameraFOV.__index = CameraFOV

-- -------------------------------------------------------------------------- --
--                                 Constructor                                --
-- -------------------------------------------------------------------------- --

---@param enable boolean
---@param options? CameraFOV_Options
---@return CameraFOV
function CameraFOV.new(enable, options)
	local instance = setmetatable({}, CameraFOV)

	-- Check other mod is installed or not

	instance._isSimpleFirstPersonInstalled = false
	instance._isSimpleCustomThirdPersonInstalled = false
	local camFOV = CameraFOV
	CreateThread(function()
		Wait(1)

		if camFOV._CheckSimpleFirstPersonInstalled() then --[[@diagnostic disable-line]]
			instance._isSimpleFirstPersonInstalled = true --[[@diagnostic disable-line]]
			print('"Simple First Person" mod installed.')
		end

		if camFOV._CheckSimpleCustomThirdPersonInstalled() then --[[@diagnostic disable-line]]
			instance._isSimpleCustomThirdPersonInstalled = true --[[@diagnostic disable-line]]
			print('"Simple Custom Third Person" mod installed.')
		end
	end)

	-- Instance variable initialization

	instance.isEnabled = enable

	instance.worldFOV = options and options.worldFOV or 85
	instance.interiorFOV = options and options.interiorFOV or 71
	instance.shouldOverrideCutsceneFOV = options and options.overrideCutsceneFOV
		or false

	return instance
end

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

-- ------------------------- Private Static Methods ------------------------- --

---@return boolean
function CameraFOV._CheckSimpleFirstPersonInstalled()
	---@diagnostic disable-next-line: undefined-field
	if type(_G.SIMPLE_FIRST_PERSON) == "table" then
		return true
	end
	return false
end

---@return boolean
function CameraFOV._CheckSimpleCustomThirdPersonInstalled()
	---@diagnostic disable-next-line: undefined-field
	if type(_G.SIMPLE_CUSTOM_THIRD_PERSON) == "table" then
		return true
	end
	return false
end

-- ----------------------------- Public Methods ----------------------------- --

-- State

---@return boolean
function CameraFOV:IsEnabled()
	return self.isEnabled
end

---@param enable boolean
function CameraFOV:SetEnabled(enable)
	self.isEnabled = enable

	if not self.isEnabled then
		CameraDefaultFOV()
	end
end

---@return boolean
function CameraFOV:IsCutsceneFOVOverriden()
	return self.shouldOverrideCutsceneFOV
end

---@param enable boolean
function CameraFOV:SetOverrideCutsceneFOV(enable)
	self.shouldOverrideCutsceneFOV = enable
end

-- FOV

---@return number
function CameraFOV:GetWorldFOV()
	return self.worldFOV
end

---@param fov number
function CameraFOV:SetWorldFOV(fov)
	self.worldFOV = fov
end

---@return number
function CameraFOV:GetInteriorFOV()
	return self.interiorFOV
end

---@param fov number
function CameraFOV:SetInteriorFOV(fov)
	self.interiorFOV = fov
end

---@param area CameraFOV_Area
---@return number
function CameraFOV:GetFOVInArea(area)
	return area == "world" and self.worldFOV or self.interiorFOV
end

---@param areaId integer
---@return number
function CameraFOV:GetFOVInAreaId(areaId)
	return areaId == 0 and self.worldFOV or self.interiorFOV
end

---@return number
function CameraFOV:GetFOVInCurrentArea()
	return AreaGetVisible() == 0 and self.worldFOV or self.interiorFOV
end

-- Local shared variable
---@type "worldFOV"|"interiorFOV"
local attribute = "worldFOV"

---@param area CameraFOV_Area
---@param fov number
function CameraFOV:SetFOVInArea(area, fov)
	attribute = area == "world" and "worldFOV" or "interiorFOV"
	self[attribute] = fov
end

---@param areaId integer
---@param fov number
function CameraFOV:SetFOVInAreaId(areaId, fov)
	attribute = areaId == 0 and "worldFOV" or "interiorFOV"
	self[attribute] = fov
end

local currentAreaId = 0
function CameraFOV:ApplyToActualCameraFOV()
	currentAreaId = AreaGetVisible()
	attribute = currentAreaId == 0 and "worldFOV" or "interiorFOV"

	if
		CameraGetFOV() ~= self[attribute]
		and CameraGetActive() ~= 2
		and (self.shouldOverrideCutsceneFOV or GetCutsceneRunning() == 0)
	then
		if
			(
				self._isSimpleFirstPersonInstalled
				and _G.SIMPLE_FIRST_PERSON.GetSingleton():IsEnabled()
			)
			or (
				self._isSimpleCustomThirdPersonInstalled
				and _G.SIMPLE_CUSTOM_THIRD_PERSON.GetSingleton():IsEnabled()
			)
		then
			return
		end

		self:SetFOVInAreaId(currentAreaId, self:GetFOVInCurrentArea())

		CameraSetFOV(self:GetFOVInCurrentArea())
	end
end
