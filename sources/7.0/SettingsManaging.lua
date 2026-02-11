repeat task.wait()
until _G.TIA_SHAREDINFO.GUI ~= nil

local module = {}

local DataManager
local UIManager
local EditorManager

coroutine.resume(coroutine.create(function()
DataManager = require(script.Parent:WaitForChild("DataManaging"))
UIManager = require(script.Parent:WaitForChild("UIManaging"))
EditorManager = require(script.Parent:WaitForChild("EditorManaging"))
	end))

local home = _G.TIA_SHAREDINFO.GUI.Frame.Home
local editor = _G.TIA_SHAREDINFO.GUI.Frame.Editor

module.DefaultSettings = {
	Toggles = {
		Looping = {
			Value = false,
			Title = "Looping",
			Description = "Makes the animation continuously play",
			Func = function(value, ui)
				value.Value = not value.Value
			end,
		},

		SyncTime = {
			Value = false,
			Title = "Sync Time",
			Description = "Time is copied across objects in point",
			Func = function(value, ui)
				value.Value = not value.Value
			end,
		},
	}
}

module.SettingGuiChanges = {
	Toggles = function(gui, newval)
		if newval == true then
			_G.tweenservice:Create(gui.Enabled.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Active}):Play()
			gui.Enabled.Check.Visible = true
			gui.Enabled.X.Visible = false
		else
			_G.tweenservice:Create(gui.Enabled.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Inactive}):Play()
			gui.Enabled.Check.Visible = false
			gui.Enabled.X.Visible = true
		end
	end,
}

return module
