repeat task.wait()
until _G.TIA_SHAREDINFO.GUI ~= nil

local module = {}

local gui = _G.TIA_SHAREDINFO.GUI
local home = gui.Frame.Home
local editor = gui.Frame.Editor

local datatypePrefixes = {
	boolean = "Bool",
	string = "String",
	number = "Number"
};

local OBJECT_NAME_FORMAT = "%sValue"

function module.getCurrentModuleSource() --returns the source of the module that the user is currently editing
	if _G.TIA_SHAREDINFO.CurrentObject.currentmodule then
		local newmodule = Instance.new("ModuleScript", script.Parent.TempModules)
		game:GetService("Debris"):AddItem(newmodule, 3)
		
		newmodule.Source = _G.TIA_SHAREDINFO.CurrentObject.currentmodule.Source
		return require(newmodule)
	end
end

function module.getValueObject(Type) --returns what type of value a property is
		local success, object = pcall(Instance.new, OBJECT_NAME_FORMAT:format(datatypePrefixes[typeof(Type)]))
		if success and object then
			return object
		else
			error(object)
		end
end

function module.getObjValue(givenobj) --returns ObjectValue that includes the Object, Edit Frame, and the Selection button
	if _G.TIA_SHAREDINFO.CurrentObject.currentmodule then
		for i, val in pairs(_G.TIA_SHAREDINFO.CurrentObject.currentmodule:WaitForChild("Objects"):GetChildren()) do
			if tonumber(givenobj) then
				if val.Name == givenobj then
					return val
				end
			else
				if val.Value == givenobj then
					return val
				end
			end
		end
	end
end

function module.getAllValues() --returns information about every single object, Name, Properties, TweenStyles
	local allvalues = {}

	for i, part in pairs(_G.TIA_SHAREDINFO.CurrentObject.selectedpart) do
		allvalues[module.getObjValue(part).Name] = {}

		allvalues[module.getObjValue(part).Name]["Values"] = _G.apimodule:GetProperties(part, true)

		local yes, no = pcall(function()
			allvalues[module.getObjValue(part).Name]["TweenInfo"]  = {
				["Time"] = tonumber(module.getObjValue(part).Frame.Value.Time.TextBox.Text) or _G.defaulttweens.Time,
				["EasingStyle"] = Enum.EasingStyle[module.getObjValue(part).Frame.Value.Easing.EasingStyle.Selected.Value] or _G.defaulttweens.EasingStyle,
				["EasingDirection"] = Enum.EasingDirection[module.getObjValue(part).Frame.Value.Easing.EasingDirection.Selected.Value] or _G.defaulttweens.EasingDirection,
			}
		end)

		if no then
			allvalues[module.getObjValue(part).Name]["TweenInfo"]  = _G.defaulttweens
		end
	end

	return allvalues
end

function module.isSaved(num) --checking if current animation is saved

	if num == nil then
		return true
	end

	if module.getCurrentModuleSource()[tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text)] then
		return true
	else
		return false
	end
end

return module
