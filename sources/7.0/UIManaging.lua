repeat task.wait()
until _G.TIA_SHAREDINFO.GUI ~= nil

local module = {}

_G.togglecolors = {
	Active = Color3.fromRGB(63, 130, 27),
	Inactive = Color3.fromRGB(149, 0, 0)
}

local EditorManager
local DataManager

coroutine.resume(coroutine.create(function()
EditorManager = require(script.Parent:WaitForChild("EditorManaging"))
DataManager = require(script.Parent.DataManaging)
	end))

local gui = _G.TIA_SHAREDINFO.GUI
local home = gui.Frame.Home
local editor = gui.Frame.Editor
local notifications = gui.Frame.Notifications
local framechanger = gui.Frame.ChangingFrames
local tabchanger = editor.Tabs.ChangingTabs

function module.checkuiscale(obj) --Adds a UIScale to a UI element if there isn't one
		if obj:FindFirstChildOfClass("UIScale") then
			return obj:FindFirstChildOfClass("UIScale")
		else
			local uiscale = Instance.new("UIScale", obj)
			return uiscale
		end
end

function module.changecreatebutton(changeto) --Changes main create/edit button to whichever one
		local mainbutton = home.NavBar.MainButton

		local newscale = module.checkuiscale(mainbutton.New)
		local editscale = module.checkuiscale(mainbutton.Edit)

		local tochange = mainbutton:FindFirstChild(changeto):FindFirstChildOfClass("UIScale")

		if tochange.Scale == 1 then
			return
		end

		_G.tweenservice:Create(newscale, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0}):Play()
		_G.tweenservice:Create(editscale, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0}):Play()
		task.wait(.05)
		_G.tweenservice:Create(tochange, TweenInfo.new(.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

		mainbutton.TextLabel.MaxVisibleGraphemes = 0

		mainbutton.TextLabel.Text = changeto

		for i=1, #changeto do
			mainbutton.TextLabel.MaxVisibleGraphemes += 1
			task.wait(.05)
		end

		mainbutton.TextLabel.MaxVisibleGraphemes = -1
	end

local changeframerunning = false
local changetabrunning = false
function module.changeframe(frame : Frame)	 --Changes frame (Home/Editor)
	if frame then
		if frame.Visible == false then
			if changeframerunning == false then
				changeframerunning = true

				local uiscale = module.checkuiscale(framechanger)
				uiscale.Scale = 0

				framechanger.Visible = true

				_G.tweenservice:Create(uiscale, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {Scale = 1}):Play()

				coroutine.resume(coroutine.create(function()
					wait(.25)
					home.Visible = false
					editor.Visible = false
					frame.Visible = true
					changeframerunning = false
					wait(.24)
					framechanger.Visible = false
				end))	
			end
		end
	end
end

function module.changetab(frame : Frame) --Changes tab IN EDITOR (Editor, Properties, Settings)
	if frame then
		if frame.Visible == false then
			for i, obj in pairs(editor.Tabs:GetChildren()) do
				if obj:IsA("Frame") then
					obj.Visible = false
				end
			end

			if frame.Name == "Editor" and editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text == "?" then
				editor.Tabs.NoPoints.Visible = true
			else
				frame.Visible = true
			end


			if editor.NavBar.Buttons:FindFirstChild(frame.Name) then
				_G.TIA_SHAREDINFO.ButtonSelector.Parent = editor.NavBar.Buttons:FindFirstChild(frame.Name)
			else
				_G.TIA_SHAREDINFO.ButtonSelector.Parent = nil
			end
		end
	end
end

function module.applyiconhover(obj : GuiObject, tochange : GuiObject) --Adds a simple hover tween to buttons

	if not tochange then
		tochange = obj
	end

	local uiscale = module.checkuiscale(tochange)

	local hovering = false

	obj.MouseEnter:Connect(function()
		hovering = true
		_G.tweenservice:Create(uiscale, TweenInfo.new(.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
	end)

	obj.MouseLeave:Connect(function()
		hovering = false
		_G.tweenservice:Create(uiscale, TweenInfo.new(.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)

	if obj:IsA("TextButton") or obj:IsA("ImageButton") then
		obj.MouseButton1Down:Connect(function()
			_G.tweenservice:Create(uiscale, TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.9}):Play()
		end)

		obj.MouseButton1Up:Connect(function()
			if hovering == true then
				_G.tweenservice:Create(uiscale, TweenInfo.new(.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
			else
				_G.tweenservice:Create(uiscale, TweenInfo.new(.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
			end
		end)
	end
end

function module.createnotification(text) --duh
	local notgui = script.Parent:WaitForChild("UI"):WaitForChild("Notification"):Clone()

	local uiscale = module.checkuiscale(notgui)
	uiscale.Scale = 0

	notgui.Text = text

	notgui.Parent = notifications

	_G.tweenservice:Create(uiscale, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

	coroutine.resume(coroutine.create(function()
		task.wait(3)
		_G.tweenservice:Create(uiscale, TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0}):Play()
		task.wait(.12)
		notgui:Destroy()
	end))
end

function module.selectObjectFrame(obj)  --Switches to specific object frame
	for i, obj in pairs(editor.Tabs.Editor.Objects:GetChildren()) do
		if obj:IsA("TextButton") then
			obj.BackgroundTransparency = 1
		end
	end

	for i, obj in pairs(editor.Tabs.Editor.Info:GetChildren()) do
		obj.Visible = false
	end

	if obj:IsA("Instance") then
		DataManager.getObjValue(obj).SelectionButton.Value.BackgroundTransparency = 0.6

		DataManager.getObjValue(obj).Frame.Value.Visible = true

		_G.selection:Set({obj})
	end
end

function module.checkselected() --changing home UI text/button based on what is selected
	if _G.TIA_SHAREDINFO.CurrentObject == nil then
		if _G.TIA_SHAREDINFO.widget.Enabled == true then

			for i, obj in pairs(home.Tabs.ScrollingFrame:GetChildren()) do
				if obj:IsA("Frame") then
					obj:Destroy()
				end
			end

			if #_G.selection:Get() >= 1 then
				if #_G.selection:Get() > 1 then
					home.Tabs.CurrentObject.Text = "Currently selected: More than one instance"
				else
					home.Tabs.CurrentObject.Text = "Currently selected: ".._G.selection:Get()[1].Name

					if _G.selection:Get()[1]:FindFirstChild("TemmieTweens") then
						for i, currentmodule in pairs(_G.selection:Get()[1]:FindFirstChild("TemmieTweens"):GetChildren()) do
							local guiedit = script.Parent:WaitForChild("UI"):WaitForChild("EditListItem"):Clone()
							guiedit.Name = currentmodule.Name
							guiedit.TextLabel.Text = currentmodule.Name
							guiedit.Parent = home.Tabs.ScrollingFrame


							module.applyiconhover(guiedit.ImageButton)

							guiedit.ImageButton.MouseButton1Click:Connect(function()
								module.changeframe(editor)
								module.changetab(editor.Tabs.Editor)
								_G.TIA_SHAREDINFO.editanimation(currentmodule)
							end)
						end
					end
				end
				home.Tabs.TopInfo.Text = "That's perfect!"
				if _G.selection:Get()[1].Parent.Name == "TemmieTweens" and _G.selection:Get()[1].Parent:IsA("Configuration") and _G.selection:Get()[1]:IsA("ModuleScript") then
					if #_G.selection:Get() > 1 then
						home.Tabs.TopInfo.Text = "You can only select one ModuleScript to edit at a time!"
						module.changecreatebutton("New")
					else
						module.changecreatebutton("Edit")
					end
				else
					module.changecreatebutton("New")
				end
			else
				module.changecreatebutton("New")
				home.Tabs.CurrentObject.Text = "Currently selected: none"
				home.Tabs.TopInfo.Text = "Please select an instance to animate!"
			end
		end
	end
end

function module.resetUI() --Sends you back to home frame, resetting everything

	if _G.TIA_SHAREDINFO.CurrentObject then
		EditorManager.teleporttopoint(nil, _G.TIA_SHAREDINFO.CurrentObject.OriginalValues)
		end

		editor.TopBar.AnimationName.Text = ""

	_G.TIA_SHAREDINFO.CurrentObject = nil
		for i, func in pairs(_G.propertychangefunctions) do
			func:Disconnect()
		end
		_G.propertychangefunctions = {}
		for i, highlight in pairs(_G.highlights) do
			highlight:Destroy()
		end
		_G.highlights = {}
		module.checkselected()

		module.changeframe(home)

		for i, setting in pairs(editor.Tabs.Settings.ScrollingFrame:GetChildren()) do
			if setting:IsA("Frame") then
				setting:Destroy()
			end
		end

		for i, obj in pairs(editor.Tabs.Editor.Objects:GetChildren()) do
			if obj:IsA("TextButton") then
				obj:Destroy()
			end
		end

		for i, obj in pairs(editor.Tabs.Editor.Info:GetChildren()) do
			obj:Destroy()
		end

		if _G.AddObjectbutton then
			_G.AddObjectbutton:Destroy()
			_G.AddObjectbutton = nil
		end
	end

print("Test")

return module
