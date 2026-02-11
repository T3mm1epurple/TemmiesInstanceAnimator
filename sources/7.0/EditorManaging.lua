repeat task.wait()
until _G.TIA_SHAREDINFO.GUI ~= nil

local module = {}

local gui = _G.TIA_SHAREDINFO.GUI
local home = gui.Frame.Home
local editor = gui.Frame.Editor

local DataManager
local UIManager

coroutine.resume(coroutine.create(function()
	DataManager = require(script.Parent.DataManaging)
	UIManager = require(script.Parent.UIManaging)
end))

function module.createPoint(num) --Adds a point to the current animation or saves
	if editor.TopBar.AnimationName.Text ~= "" then
		_G.TIA_SHAREDINFO.CurrentObject.currentmodule.Name = editor.TopBar.AnimationName.Text
	end

	local code = DataManager.getCurrentModuleSource()

	code[num] = code[num] or {}

	code[num] = DataManager.getAllValues()

	_G.TIA_SHAREDINFO.CurrentObject.currentmodule.Source = [[
	local module =  ]].._G.tableToString(code)..[[


return module
	]]

	return true
end

function module.teleporttopoint(num, actualinitialproperties) --changes properties of objects for specific point (visualizing the animation in real time)
	if _G.TIA_SHAREDINFO.CurrentObject then
		local initialproperties = nil

		if num then
			initialproperties = DataManager.getCurrentModuleSource()[num]
		end

		if actualinitialproperties then
			initialproperties = actualinitialproperties
		end

		if initialproperties then
			for uniqueid, information in pairs(initialproperties) do
				for i, part in pairs(_G.TIA_SHAREDINFO.CurrentObject.selectedpart) do
					if DataManager.getObjValue(part).Name == uniqueid then
						for namevalue, value in pairs(information.Values) do
							local yes, no = pcall(function()
								part[namevalue] = value
							end)
						end
					end
				end
			end
		end
	end
end

function module.loadpoint(num) --loads all information about a specific point into editor frame (TweenInfo, Time)
	if num <= _G.TIA_SHAREDINFO.CurrentObject.points and num > 0 then

		local tweentable = _G.defaulttweens

		if DataManager.getCurrentModuleSource()[num] then
			for uniqueid, info in pairs(DataManager.getCurrentModuleSource()[num]) do
				tweentable = info.TweenInfo

				DataManager.getObjValue(uniqueid).Frame.Value.Time.TextBox.Text = tweentable.Time
				DataManager.getObjValue(uniqueid).Frame.Value.Easing.EasingDirection.Selected.Value = string.split(tostring(tweentable.EasingDirection), ".")[3]
				DataManager.getObjValue(uniqueid).Frame.Value.Easing.EasingStyle.Selected.Value = string.split(tostring(tweentable.EasingStyle), ".")[3]

				for i, obj in pairs(DataManager.getObjValue(uniqueid).Frame.Value.Easing.EasingDirection.Options:GetChildren()) do
					if obj:IsA("TextButton") then
						obj.BackgroundColor3 = _G.togglecolors.Inactive
					end
				end

				for i, obj in pairs(DataManager.getObjValue(uniqueid).Frame.Value.Easing.EasingStyle.Options:GetChildren()) do
					if obj:IsA("TextButton") then
						obj.BackgroundColor3 = _G.togglecolors.Inactive
					end
				end

				DataManager.getObjValue(uniqueid).Frame.Value.Easing.EasingDirection.Options:FindFirstChild(string.split(tostring(tweentable.EasingDirection), ".")[3]).BackgroundColor3 = _G.togglecolors.Active
				DataManager.getObjValue(uniqueid).Frame.Value.Easing.EasingStyle.Options:FindFirstChild(string.split(tostring(tweentable.EasingStyle), ".")[3]).BackgroundColor3 = _G.togglecolors.Active

				local becomegreen = true

				for i, obj in pairs(DataManager.getObjValue(uniqueid):GetDescendants()) do
					if obj.Parent.Name == "OffPoints" then
						if obj.Name == tostring(num) then
							local selectionbutton = obj.Parent.Parent.SelectionButton.Value

							if selectionbutton then
								becomegreen = false
								selectionbutton.Toggle.BackgroundColor3 = _G.togglecolors.Inactive
							end
						end
					end
				end

				if becomegreen == true then
					DataManager.getObjValue(uniqueid).SelectionButton.Value.Toggle.BackgroundColor3 = _G.togglecolors.Active
				end
			end
		else
			for i, editframe in pairs(editor.Tabs.Editor.Info:GetChildren()) do

				editframe.Time.TextBox.Text = tweentable.Time

				for i, obj in pairs(editframe.Easing.EasingDirection.Options:GetChildren()) do
					if obj:IsA("TextButton") then
						obj.BackgroundColor3 = _G.togglecolors.Inactive
					end
				end

				for i, obj in pairs(editframe.Easing.EasingStyle.Options:GetChildren()) do
					if obj:IsA("TextButton") then
						obj.BackgroundColor3 = _G.togglecolors.Inactive
					end
				end

				editframe.Easing.EasingDirection.Options:FindFirstChild(editframe.Easing.EasingDirection.Selected.Value).BackgroundColor3 = _G.togglecolors.Active
				editframe.Easing.EasingStyle.Options:FindFirstChild(editframe.Easing.EasingStyle.Selected.Value).BackgroundColor3 = _G.togglecolors.Active
			end

			for i, objbutton in pairs(editor.Tabs.Editor.Objects:GetChildren()) do
				if objbutton:IsA(("TextButton")) and objbutton.Name ~= "AddObject" then
					objbutton.Toggle.BackgroundColor3 = _G.togglecolors.Active
				end
			end
		end



		editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text = num

		module.teleporttopoint(num)
	end
end


function module.addpoint() --adds an existing point from animation
	if _G.TIA_SHAREDINFO.CurrentObject ~= nil then
		_G.TIA_SHAREDINFO.CurrentObject.points += 1

		module.loadpoint(_G.TIA_SHAREDINFO.CurrentObject.points)
		UIManager.changetab(editor.Tabs.Editor)
	end
end

function module.removepoint(num) --remove point from animation
	if num > 0 then
		local code = DataManager.getCurrentModuleSource()

		for i, obj in pairs(_G.TIA_SHAREDINFO.CurrentObject.currentmodule.Objects:GetDescendants()) do
			if obj.Parent == "OffPoints" then
				if obj.Name == tostring(num) then
					obj:Destroy()
				end
			end
		end

		_G.TIA_SHAREDINFO.CurrentObject.points -= 1

		if code[num] then
			code[num] = nil

			local oldnum = 0

			for num, item in pairs(code) do
				if oldnum + 1 ~= num then
					code[num] = nil
					code[oldnum + 1] = item
				end

				oldnum = num
			end

			_G.TIA_SHAREDINFO.CurrentObject.currentmodule.Source = [[
	local module =  ]].._G.tableToString(code)..[[


return module
	]]
		end

		if num - 1 == 0 then
			if code[num] == nil then
				UIManager.changetab(editor.Tabs.NoPoints)

				editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text = "?"
			else
				module.loadpoint(num)
			end
		else
			module.loadpoint(num - 1)
		end
	end
end

function module.loadattributes() --loads attributes into properties tab
	for i, obj in pairs(editor.Tabs.Properties.ScrollingFrame:GetChildren()) do
		if obj:IsA("Frame") then
			obj:Destroy()
		end
	end

	local attributes = {}

	for i, part in pairs(_G.TIA_SHAREDINFO.CurrentObject.selectedpart) do
		for valname, val in pairs(_G.apimodule:GetProperties(part, true)) do
			attributes[valname] = val
		end
	end

	for namevalue, value in pairs(attributes) do
		if not game:GetService("MaterialService"):WaitForChild("IgnoredProperties"):FindFirstChild(namevalue) then
			if _G.temmiestweenmodule:IsTweenable(value) then
				if not editor.Tabs.Properties.ScrollingFrame:FindFirstChild(namevalue) then
					local button = script.Parent:WaitForChild("UI"):WaitForChild("Property"):Clone()
					button.Name = namevalue
					button.TextLabel.Text = namevalue

					button.Parent = editor.Tabs.Properties.ScrollingFrame
					
					local BUTTONS = button.Buttons
					local lockbutton = BUTTONS.Lock
					local enabledbutton = BUTTONS.Enabled
					local ignorebutton = BUTTONS.Ignore

					lockbutton.Changed:Connect(function(val)
						if val == true then
							_G.tweenservice:Create(lockbutton.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Inactive}):Play()
							lockbutton.Unlocked.Visible = false
							lockbutton.Locked.Visible = true
						else
							_G.tweenservice:Create(lockbutton.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Active}):Play()
							lockbutton.Unlocked.Visible = true
							lockbutton.Locked.Visible = false
						end
					end)

					lockbutton.MouseButton1Click:Connect(function()
						button.Locked.Value = not button.Locked.Value
					end)

					UIManager.applyiconhover(lockbutton)
					UIManager.applyiconhover(enabledbutton)
					UIManager.applyiconhover(ignorebutton)
					
					ignorebutton.MouseButton1Click:Connect(function()
						local ignoredproperties = game:GetService("MaterialService"):WaitForChild("IgnoredProperties")

						if not ignoredproperties:FindFirstChild(namevalue) then
							local newvalue = Instance.new("StringValue", ignoredproperties)
							newvalue.Name = namevalue
						end

						UIManager.createnotification(namevalue.." is now ignored")

						button:Destroy()
					end)
					
					local disabledproperties = _G.TIA_SHAREDINFO.CurrentObject.currentmodule:WaitForChild("DisabledProperties")
					
					enabledbutton.MouseButton1Click:Connect(function()
						if not disabledproperties:FindFirstChild(namevalue) then
							local newvalue = Instance.new("StringValue", disabledproperties)
							newvalue.Name = namevalue
							
							_G.tweenservice:Create(enabledbutton.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Inactive}):Play()
							enabledbutton.Check.Visible = false
							enabledbutton.X.Visible = true
						else
							disabledproperties:FindFirstChild(namevalue):Destroy()
							
							_G.tweenservice:Create(enabledbutton.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Active}):Play()
							enabledbutton.Check.Visible = true
							enabledbutton.X.Visible = false
						end
					end)
					
					enabledbutton.MouseButton2Click:Connect(function()
						
						local parts = _G.TIA_SHAREDINFO.CurrentObject.selectedpart
						
						for i, obj in pairs(button.Options:GetChildren()) do
							if obj:IsA("Frame") and obj.Name ~= "Close" then
								obj:Destroy()
							end
						end
						
						for i, part in pairs(parts) do
							local option = script.Parent.UI:WaitForChild("EnableOption"):Clone()
							option.Parent = button.Options
							option.Name = part.Name
							
							local optionbutton = option:WaitForChild("Button")
							
							if DataManager.getObjValue(part):WaitForChild("DisabledProperties"):FindFirstChild(namevalue) then
								optionbutton.UIStroke.Color = _G.togglecolors.Inactive
							end
							
							optionbutton.TextLabel.Text = part.Name
							
							optionbutton.MouseButton1Click:Connect(function()
								local partdisabledproperties = DataManager.getObjValue(part):WaitForChild("DisabledProperties")
								
								if not partdisabledproperties:FindFirstChild(namevalue) then
									local newvalue = Instance.new("StringValue", partdisabledproperties)
									newvalue.Name = namevalue
									_G.tweenservice:Create(optionbutton.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Inactive}):Play()
								else
									partdisabledproperties:FindFirstChild(namevalue):Destroy()
									_G.tweenservice:Create(optionbutton.UIStroke, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = _G.togglecolors.Active}):Play()
								end
							end)
						end
						
						BUTTONS.Visible = false
						button.Options.Visible = true
					end)
					
					button.Options.Close.Close.MouseButton1Click:Connect(function()
						button.Options.Visible = false
						BUTTONS.Visible = true
					end)
					
					if disabledproperties:FindFirstChild(namevalue) then
						enabledbutton.UIStroke.Color = _G.togglecolors.Inactive
						enabledbutton.Check.Visible = false
						enabledbutton.X.Visible = true
					end
					
					for i, obj in pairs(button:GetChildren()) do
						if obj:IsA("TextButton") then
							_G.LoadToolTip(obj)
						end
					end
				end
			end
		end
	end

	for i, part in pairs(_G.TIA_SHAREDINFO.CurrentObject.selectedpart) do
		_G.propertychangefunctions[_G.getTableLength(_G.propertychangefunctions) + 1] = part.Changed:Connect(function(value)
			if _G.tweenplaying == false then
				local buttonvalue = editor.Tabs.Properties.ScrollingFrame:FindFirstChild(value)

				if buttonvalue then
					if buttonvalue.Locked.Value == true then
						local list = DataManager.getCurrentModuleSource()[tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text)]

						if tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) == nil and not list then
							list = {Values = _G.TIA_SHAREDINFO.CurrentObject.OriginalValues}
						elseif not list and tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) ~= nil then
							list = DataManager.getCurrentModuleSource()[tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) - 1]
						end

						if not list then
							list = DataManager.getCurrentModuleSource()[1]
						end

						if list then
							local yes, no = pcall(function()
								part[value] = list[DataManager.getObjValue(part).Name].Values[value]
							end)
						else
							local yes, no = pcall(function()
								part[value] = _G.TIA_SHAREDINFO.CurrentObject.OriginalValues[value]
							end)
							print(no)
						end
					end
				end
			end
		end)
	end
end

return module
