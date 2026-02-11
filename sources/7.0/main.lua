--PLUGIN INFO
_G.TIA_SHAREDINFO = {}

local toolbar = plugin:CreateToolbar("T.I.A")

local pluginButton = toolbar:CreateButton(
	"T.I.A",
	"",
	"http://www.roblox.com/asset/?id=7880189930")

local info = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, --From what side gui appears
	false, --Widget will be initially enabled
	false, --Don't overdrive previouse enabled state
	600, --default weight
	400, --default height
	550, --minimum weight (optional)
	350 --minimum height (optional)
)

local widget = plugin:CreateDockWidgetPluginGuiAsync(
	"temmies instance animator", --A unique and consistent identifier used to storing the widget’s dock state and other internal details
	info --dock widget info
) widget.Title = "temmies instance animator 7.0" --Giving title to our widget gui

widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_G.TIA_SHAREDINFO.widget = widget

--------------------------------------------------------------------------------------------------------------------------------------------

if not game:GetService("MaterialService"):FindFirstChild("IgnoredProperties") then
	local ignoredproperties = Instance.new("Folder", game:GetService("MaterialService"))
	ignoredproperties.Name = "IgnoredProperties"
end

local gui = script.Parent:WaitForChild("NewFrame"):Clone() gui.Parent = widget

_G.TIA_SHAREDINFO.GUI = gui

_G.apimodule = require(script:WaitForChild("Modules"):WaitForChild("APIService"))
_G.temmiestweenmodule = require(script:WaitForChild("Modules"):WaitForChild("T.I.A"))

_G.selection = game:GetService("Selection")
_G.tweenservice = game:GetService("TweenService")

_G.AddObjectbutton = nil

local home = gui.Frame.Home
local editor = gui.Frame.Editor

local notifications = gui.Frame.Notifications
local framechanger = gui.Frame.ChangingFrames
local tabchanger = editor.Tabs.ChangingTabs

local buttonselector = script:WaitForChild("UI"):WaitForChild("Selector"):Clone()
_G.TIA_SHAREDINFO.ButtonSelector = buttonselector

local DataManager = require(script:WaitForChild("DataManaging"))
local UIManager = require(script:WaitForChild("UIManaging"))
local EditorManager = require(script:WaitForChild("EditorManaging"))
local SettingsManager = require(script:WaitForChild("SettingsManaging"))

_G.tooltip = gui:WaitForChild("ToolTip")

--------------------------------------------------------------------------------------------------------------------------------------------

_G.TIA_SHAREDINFO.CurrentObject = nil

local ObjectInfoTemplate = {
	selectedpart = nil,
	currentmodule = nil,
	points = 0,

	Settings = {},

	OriginalValues = {

	}
}

_G.propertychangefunctions = {}
_G.highlights = {}
_G.tweenplaying = false

_G.defaulttweens = {
	["Time"] = 1,
	["EasingStyle"] = Enum.EasingStyle.Linear,
	["EasingDirection"] = Enum.EasingDirection.In,
}

--------------------------------------------------------------------------------------------------------------------------------------------
--GLOBAL FUNCTIONS

_G.getTableLength = function(tbl)
	local count = 0
	for i, v in pairs(tbl) do
		count = count + 1
	end
	return count
end

_G.deepCopy = function(original)
	local copy = {}

	for key, value in original do
		copy[key] = type(value) == "table" and _G.deepCopy(value) or value
	end

	return copy
end

_G.tableToString = function(tbl, indent)
	indent = indent or ""
	local result = "{\n"
	local nextIndent = indent .. "    " -- Indentation for readability

	for k, v in pairs(tbl) do
		-- Convert key to a string if it's not a number
		local key = (type(k) == "string") and ("[\"" .. k .. "\"]") or ("[" .. k .. "]")

		-- Convert values
		local value
		if type(v) == "table" then
			value = _G.tableToString(v, nextIndent) -- Recursively format tables
		elseif type(v) == "string" then
			value = "\"" .. v .. "\"" -- Add quotes for strings
		elseif type(v) == "boolean" or type(v) == "number" or typeof(v) == "EnumItem" then
			value = tostring(v) -- Convert booleans/numbers normally
		elseif typeof(v) == "Vector3" then
			value = "Vector3.new(" .. v.X .. ", " .. v.Y .. ", " .. v.Z .. ")"
		elseif typeof(v) == "Color3" then
			value = "Color3.new(" .. v.R .. ", " .. v.G .. ", " .. v.B .. ")"
		elseif typeof(v) == "BrickColor" then
			value = "BrickColor.new(\"" .. v.Name .. "\")"
		elseif typeof(v) == "UDim2" then
			value = "UDim2.new(" .. v.X.Scale .. ", " .. v.X.Offset .. ", " .. v.Y.Scale .. ", " .. v.Y.Offset .. ")"
		elseif typeof(v) == "CFrame" then
			value = "CFrame.new(" .. tostring(v) .. ")" -- CFrame stores position & rotation
		elseif typeof(v) == "Instance" then
			value = "\"" .. "cant store objects" .. "\"" -- Comment out objects
		else
			value = "nil --[[ Unsupported Value Type: " .. typeof(v) .. " ]]" -- Fallback for unsupported types
		end

		result = result .. nextIndent .. key .. " = " .. value .. ",\n"
	end

	result = result .. indent .. "}"
	return result
end

_G.LoadToolTip = function(button : TextButton)
	button.MouseEnter:Connect(function()
		if button:GetAttribute("Tooltip") then
			_G.tooltip.TextLabel.Text = button:GetAttribute("Tooltip")
			_G.tooltip.Size = UDim2.new(0,0,0,0)
			
			local absolutey = button.AbsolutePosition.Y
			
			if button.Parent:IsA("ScrollingFrame") then
				absolutey = button.Parent.CanvasPosition.Y + button.AbsolutePosition.Y - button.Parent.AbsolutePosition.Y
				
				if absolutey < 0 then
					absolutey *= -1
				end
			end
			
			_G.tooltip.Position = UDim2.new(0, button.AbsolutePosition.X + button.AbsoluteSize.X/2, 0, absolutey + 45)
			_G.tooltip.Visible = true
			_G.tweenservice:Create(_G.tooltip, TweenInfo.new(.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,127.141724,0,37.7577248)}):Play() --size of locked/enable buttons
		end
	end)
	
	button.MouseLeave:Connect(function()
		_G.tooltip.Visible = false
	end)
end

--------------------------------------------------------------------------------------------------------------------------------------------
--CREATE AND EDIT TWEEN FUNCTIONS

local function InitializeTweenEditor(isNew)
	local sharedObj = _G.TIA_SHAREDINFO.CurrentObject
	local alreadyselect = false
	
	if isNew then
		Instance.new("Folder", _G.TIA_SHAREDINFO.CurrentObject.currentmodule).Name = "DisabledProperties"
	end
	
	-- Setup Objects and UI Frames
	for i, obj in pairs(sharedObj.selectedpart) do
		local objbutton = script.UI:WaitForChild("ObjectButton"):Clone()
		local objData = DataManager.getObjValue(obj)
		
		if isNew then
			-- Logic specific to creating new (Value storage setup)
			local buttonval = Instance.new("ObjectValue", objData)
			buttonval.Name = "SelectionButton"
			buttonval.Value = objbutton
		else
			objData:WaitForChild("SelectionButton").Value = objbutton
		end

		objbutton.Name = obj.Name
		objbutton.ObjectName.Text = obj.Name
		objbutton.Parent = editor.Tabs.Editor.Objects

		objbutton.MouseButton1Click:Connect(function()
			UIManager.selectObjectFrame(obj)
		end)

		local offpoints = objData:WaitForChild("OffPoints")
		objbutton.Toggle.MouseButton1Click:Connect(function()
			local currentPoint = editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text
			if offpoints:FindFirstChild(currentPoint) then
				offpoints:FindFirstChild(currentPoint):Destroy()
				_G.tweenservice:Create(objbutton.Toggle, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Active}):Play()
			else
				local offpoint = Instance.new("NumberValue", offpoints)
				offpoint.Name = currentPoint
				_G.tweenservice:Create(objbutton.Toggle, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Inactive}):Play()
			end
		end)

		local valuesframe = script.UI:WaitForChild("ValuesFrame"):Clone()
		if isNew then
			local frameval = Instance.new("ObjectValue", objData)
			frameval.Name = "Frame"
			frameval.Value = valuesframe
		else
			objData:WaitForChild("Frame").Value = valuesframe
		end

		valuesframe.Name = obj.Name
		valuesframe.Parent = editor.Tabs.Editor.Info

		valuesframe.Time.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			valuesframe.Time.TextBox.Text = valuesframe.Time.TextBox.Text:gsub('[^%d{.}]', '')
			if sharedObj.currentmodule.Settings.Toggles.SyncTime.Value == true then
				for _, v in pairs(valuesframe.Parent:GetChildren()) do
					if v:IsA("Frame") and v ~= valuesframe then
						v.Time.TextBox.Text = valuesframe.Time.TextBox.Text
					end
				end
			end
		end)

		local function EasingManager(frame)
			for _, button in pairs(frame.Options:GetChildren()) do
				if button:IsA("TextButton") then
					button.MouseButton1Click:Connect(function()
						for _, v in pairs(button.Parent:GetChildren()) do
							if v:IsA("TextButton") and v ~= button then
								_G.tweenservice:Create(v, TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Inactive}):Play()
							end
						end
						button.Parent.Parent:WaitForChild("Selected").Value = button.Name
						_G.tweenservice:Create(button, TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Active}):Play()
					end)
				end
			end
		end
		EasingManager(valuesframe.Easing.EasingDirection)
		EasingManager(valuesframe.Easing.EasingStyle)

		if not alreadyselect then
			alreadyselect = true
			UIManager.selectObjectFrame(obj)
		end
	end

	-- Setup Add Object Button
	_G.AddObjectbutton = script.UI:WaitForChild("AddObject"):Clone()
	_G.AddObjectbutton.Parent = editor.Tabs.Editor.Objects
	_G.AddObjectbutton.RealButton.MouseButton1Click:Connect(function()
		_G.selection:Set({})
		UIManager.changetab(editor.Tabs.AddObject)
	end)

	-- Setup Settings Panel
	local settingsfolder = sharedObj.currentmodule:FindFirstChild("Settings")
	for settype, items in pairs(sharedObj.Settings) do
		local specfolder = settingsfolder:FindFirstChild(settype) or Instance.new("Folder", settingsfolder)
		specfolder.Name = settype

		for setname, info in pairs(items) do
			local value = specfolder:FindFirstChild(setname)
			if not value then
				value = DataManager.getValueObject(info.Value)
				value.Name = setname
				value.Value = info.Value
				value.Parent = specfolder
			end

			local frame = script.SettingsFrames:FindFirstChild(settype):Clone()
			frame.Name = setname
			frame.Title.Text = info.Title
			frame.Description.Text = info.Description
			frame.Parent = editor.Tabs.Settings.ScrollingFrame
			UIManager.applyiconhover(frame.Enabled)

			frame.Enabled.MouseButton1Click:Connect(function()
				sharedObj.Settings[settype][setname].Func(value, frame)
			end)

			_G.propertychangefunctions[#_G.propertychangefunctions + 1] = value:GetPropertyChangedSignal("Value"):Connect(function()
				sharedObj.Settings[settype][setname].Value = value.Value
				SettingsManager.SettingGuiChanges[settype](frame, value.Value)
			end)
			SettingsManager.SettingGuiChanges[settype](frame, value.Value)
		end
	end
end

_G.TIA_SHAREDINFO.createnewtween = function()
	if _G.TIA_SHAREDINFO.CurrentObject == nil then
		_G.TIA_SHAREDINFO.CurrentObject = _G.deepCopy(ObjectInfoTemplate)
		_G.TIA_SHAREDINFO.CurrentObject.selectedpart = _G.selection:Get()
		_G.TIA_SHAREDINFO.CurrentObject.Settings = SettingsManager.DefaultSettings

		if #_G.selection:Get() > 1 then
			UIManager.createnotification("Data is stored in: ".._G.selection:Get()[1].Name)
		end

		_G.TIA_SHAREDINFO.CurrentObject.currentmodule = script.Modules.ExampleModule:Clone()
		local configurationfolder = _G.TIA_SHAREDINFO.CurrentObject.selectedpart[1]:FindFirstChild("TemmieTweens") or Instance.new("Configuration", _G.TIA_SHAREDINFO.CurrentObject.selectedpart[1])
		configurationfolder.Name = "TemmieTweens"

		for i, part in pairs(_G.TIA_SHAREDINFO.CurrentObject.selectedpart) do
			local highlight = script:WaitForChild("Highlight"):Clone()
			highlight.Parent = part
			_G.highlights[#_G.highlights + 1] = highlight
		end

		_G.TIA_SHAREDINFO.CurrentObject.currentmodule.Parent = configurationfolder
		_G.TIA_SHAREDINFO.CurrentObject.currentmodule.Name = #configurationfolder:GetChildren()    

		local objectfolder = Instance.new("Configuration", _G.TIA_SHAREDINFO.CurrentObject.currentmodule)
		objectfolder.Name = "Objects"
		local settingsfolder = Instance.new("Configuration", _G.TIA_SHAREDINFO.CurrentObject.currentmodule)
		settingsfolder.Name = "Settings"

		for i, obj in pairs(_G.TIA_SHAREDINFO.CurrentObject.selectedpart) do
			local mainval = Instance.new("ObjectValue", objectfolder)
			mainval.Name = #objectfolder:GetChildren()
			mainval.Value = obj
			Instance.new("Folder", mainval).Name = "OffPoints"
			Instance.new("Folder", mainval).Name = "DisabledProperties"
		end

		InitializeTweenEditor(true)

		UIManager.changetab(editor.Tabs.NoPoints)
		editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text = "?"
		_G.TIA_SHAREDINFO.CurrentObject.OriginalValues = DataManager.getAllValues()
		EditorManager.loadattributes()
	end
end

_G.TIA_SHAREDINFO.editanimation = function(module : ModuleScript)
	if module:IsA("ModuleScript") then
		_G.TIA_SHAREDINFO.CurrentObject = _G.deepCopy(ObjectInfoTemplate)
		_G.TIA_SHAREDINFO.CurrentObject.selectedpart = {}
		_G.TIA_SHAREDINFO.CurrentObject.Settings = SettingsManager.DefaultSettings

		for i, obj in pairs(module:FindFirstChild("Objects"):GetChildren()) do
			_G.TIA_SHAREDINFO.CurrentObject.selectedpart[#_G.TIA_SHAREDINFO.CurrentObject.selectedpart + 1] = obj.Value
		end

		for i, part in pairs(_G.TIA_SHAREDINFO.CurrentObject.selectedpart) do
			local highlight = script:WaitForChild("Highlight"):Clone()
			highlight.Parent = part
			_G.highlights[#_G.highlights + 1] = highlight
		end

		_G.TIA_SHAREDINFO.CurrentObject.currentmodule = module
		_G.TIA_SHAREDINFO.CurrentObject.OriginalValues = DataManager.getAllValues()
		editor.TopBar.AnimationName.Text = module.Name

		InitializeTweenEditor(false)

		for i, obj in pairs(DataManager.getCurrentModuleSource()) do
			EditorManager.addpoint()
		end

		UIManager.changetab(editor.Tabs.Editor)
		EditorManager.loadattributes()
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
--PLUGIN!!

pluginButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	UIManager.checkselected()
end)

--------------------------------------------------------------------------------------------------------------------------------------------
--HOME!!

home.NavBar.MainButton.New.MouseButton1Click:Connect(function()
	if #_G.selection:Get() >= 1 then
		_G.TIA_SHAREDINFO.createnewtween()
		UIManager.changeframe(editor)
	elseif #_G.selection:Get() == 0 then
		UIManager.createnotification("Select atleast one instance!")
	end
end)

home.NavBar.MainButton.Edit.MouseButton1Click:Connect(function()
	if #_G.selection:Get() == 1 then
		UIManager.changeframe(editor)
		UIManager.changetab(editor.Tabs.Editor)
		_G.TIA_SHAREDINFO.editanimation(_G.selection:Get()[1])
	end
end)

home.NavBar.RightButtons.InsertModule.MouseButton1Click:Connect(function()
	script.Modules:WaitForChild("T.I.A"):Clone().Parent = game.ReplicatedStorage
	UIManager.createnotification("Inserted into ReplicatedStorage: 'T.I.A'")
end)

--------------------------------------------------------------------------------------------------------------------------------------------
--RESETTING UI

editor.NavBar.Buttons.Home.MouseButton1Click:Connect(function()
	if UIManager.resetUI(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text)) == true then
		UIManager.resetUI()
	else
		UIManager.createnotification("Save the point!")
	end
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if widget.Enabled == false then
		UIManager.resetUI()
	end
end)

plugin.Unloading:Connect(function()
	UIManager.resetUI()
end)

--------------------------------------------------------------------------------------------------------------------------------------------
--EDITOR!!

for i, obj in pairs(editor.NavBar.Buttons:GetChildren()) do
	if obj:IsA("TextButton") then
		obj.MouseButton1Click:Connect(function()
			UIManager.changetab(editor.Tabs:FindFirstChild(obj.Name))
		end)
	end
end

editor.TopBar.RightButtons.AddPoint.MouseButton1Click:Connect(function()
	if DataManager.isSaved(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text)) == true then
		EditorManager.addpoint()
	else
		UIManager.createnotification("Save the point!")
	end
end)

editor.TopBar.RightButtons.RemovePoint.MouseButton1Click:Connect(function()
	EditorManager.removepoint(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text))
end)

editor.NavBar.Buttons.AnimationInfo.Left.MouseButton1Click:Connect(function()
	if DataManager.isSaved(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) - 1) == true then
		EditorManager.loadpoint(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) - 1)
	else
		UIManager.createnotification("Save the point!")
	end
end)

editor.NavBar.Buttons.AnimationInfo.Right.MouseButton1Click:Connect(function()
	if DataManager.isSaved(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) + 1) == true then
		EditorManager.loadpoint(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) + 1)
	else
		UIManager.createnotification("Save the point!")
	end
end)

editor.TopBar.RightButtons.Save.MouseButton1Click:Connect(function()
	if EditorManager.createPoint(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text)) == true then
		UIManager.createnotification("Successfully saved")
	end
end)

local currenttween = nil

editor.TopBar.RightButtons.PlayAnimation.MouseButton1Click:Connect(function()
	if editor.TopBar.RightButtons.PlayAnimation.PlayIcon.Visible == true then
		EditorManager.teleporttopoint(1)

		editor.TopBar.RightButtons.PlayAnimation.PlayIcon.Visible = false
		editor.TopBar.RightButtons.PlayAnimation.StopIcon.Visible = true
		UIManager.changetab(editor.Tabs.PlayingTween)

		_G.tweenplaying = true
		currenttween = _G.temmiestweenmodule:Load(DataManager.getCurrentModuleSource(), _G.TIA_SHAREDINFO.CurrentObject.selectedpart, _G.TIA_SHAREDINFO.CurrentObject.currentmodule)

		currenttween:Play()
		repeat task.wait() until currenttween.Completed() == true

		UIManager.changetab(editor.Tabs.Editor)
		EditorManager.teleporttopoint(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text))
		editor.TopBar.RightButtons.PlayAnimation.PlayIcon.Visible = true
		editor.TopBar.RightButtons.PlayAnimation.StopIcon.Visible = false
		_G.tweenplaying = false
	else
		if currenttween then
			currenttween:Cancel()
			editor.TopBar.RightButtons.PlayAnimation.PlayIcon.Visible = true
			editor.TopBar.RightButtons.PlayAnimation.StopIcon.Visible = false
			_G.tweenplaying = false
		end
	end
end)

editor.Tabs.AddObject.Buttons.Cancel.MouseButton1Click:Connect(function()
	UIManager.changetab(editor.Tabs.Editor)
end)

editor.Tabs.AddObject.Buttons.Add.MouseButton1Click:Connect(function()

	local objects = _G.selection:Get()

	if objects[1] then
		_G.selection:Set({})

		local module = _G.TIA_SHAREDINFO.CurrentObject.currentmodule

		if _G.AddObjectbutton then
			_G.AddObjectbutton.Parent = script
		end

		for i,obj in pairs(objects) do
			table.insert(_G.TIA_SHAREDINFO.CurrentObject.selectedpart, obj)

			local mainval = Instance.new("ObjectValue", module:WaitForChild("Objects"))
			mainval.Name = #module:WaitForChild("Objects"):GetChildren()
			mainval.Value = obj

			local objbutton = script:WaitForChild("UI"):WaitForChild("ObjectButton"):Clone()

			local buttonval = Instance.new("ObjectValue", mainval)
			buttonval.Name = "SelectionButton"
			buttonval.Value = objbutton
			
			local offpoints = Instance.new("Folder", mainval)
			offpoints.Name = "OffPoints"

			objbutton.Name = obj.Name
			objbutton.ObjectName.Text = obj.Name
			objbutton.Parent = editor.Tabs.Editor.Objects

			objbutton.MouseButton1Click:Connect(function()
				UIManager.selectObjectFrame(obj)
			end)
			
			objbutton.Toggle.MouseButton1Click:Connect(function()
				if offpoints:FindFirstChild(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) then
					offpoints:FindFirstChild(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text):Destroy()
					_G.tweenservice:Create(objbutton.Toggle, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Active}):Play()
				else
					local offpoint = Instance.new("NumberValue", offpoints)
					offpoint.Name = editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text
					_G.tweenservice:Create(objbutton.Toggle, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Inactive}):Play()
				end
			end)

			local valuesframe = script.UI:WaitForChild("ValuesFrame"):Clone()

			local frameval = Instance.new("ObjectValue", mainval)
			frameval.Name = "Frame"
			frameval.Value = valuesframe

			valuesframe.Name = obj.Name
			valuesframe.Parent = editor.Tabs.Editor.Info

			valuesframe.Time.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
				valuesframe.Time.TextBox.Text = valuesframe.Time.TextBox.Text:gsub('[^%d{.}]', '')
				
				if _G.TIA_SHAREDINFO.CurrentObject.currentmodule.Settings.Toggles.SyncTime.Value == true then
					for i, v in pairs(valuesframe.Parent:GetChildren()) do
						if v:IsA("Frame") and v ~= valuesframe then
							v.Time.TextBox.Text = valuesframe.Time.TextBox.Text
						end
					end
				end
			end)
			
			local EasingDirectionFrame = valuesframe.Easing.EasingDirection
			local EasingStyleFrame = valuesframe.Easing.EasingStyle
			local function EasingManager(frame)
				for i, button in pairs(frame.Options:GetChildren()) do
					if button:IsA("TextButton") then
						button.MouseButton1Click:Connect(function()
							for i, v in pairs(button.Parent:GetChildren()) do
								if v:IsA("TextButton") and v ~= button then
									_G.tweenservice:Create(v, TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Inactive}):Play()
								end
							end

							button.Parent.Parent:WaitForChild("Selected").Value = button.Name
							_G.tweenservice:Create(button, TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.togglecolors.Active}):Play()
						end)
					end
				end
			end
			EasingManager(EasingDirectionFrame)
			EasingManager(EasingStyleFrame)
		end

		if _G.AddObjectbutton then
			_G.AddObjectbutton.Parent = editor.Tabs.Editor.Objects
		end

		UIManager.changetab(editor.Tabs.Editor)
	else
		UIManager.createnotification("select atleast 1 object!")
	end
end)

editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Trash.MouseButton1Click:Connect(function()
	UIManager.createnotification("Removed point: "..editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text)

	EditorManager.removepoint(tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text))
end)
