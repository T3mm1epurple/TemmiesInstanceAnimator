repeat task.wait() until _G.selection ~= nil

local DataManager = require(script.Parent:WaitForChild("DataManaging"))
local UIManager = require(script.Parent:WaitForChild("UIManaging"))
local EditorManager = require(script.Parent:WaitForChild("EditorManaging"))

local home = _G.TIA_SHAREDINFO.GUI.Frame.Home
local editor = _G.TIA_SHAREDINFO.GUI.Frame.Editor

local framechanger = _G.TIA_SHAREDINFO.GUI.Frame.ChangingFrames
local tabchanger = editor.Tabs.ChangingTabs

for i, obj in pairs(home.NavBar.LeftButtons:GetChildren()) do
	if obj:IsA("TextButton") then
		UIManager.applyiconhover(obj)
	end
end

for i, obj in pairs(home.NavBar.RightButtons:GetChildren()) do
	if obj:IsA("TextButton") then
		UIManager.applyiconhover(obj)
	end
end

UIManager.applyiconhover(home.NavBar.MainButton.New)
UIManager.applyiconhover(home.NavBar.MainButton.Edit)

for i, obj in pairs(editor.NavBar.Buttons:GetChildren()) do
	if obj:IsA("TextButton") then
		UIManager.applyiconhover(obj)
	end
end

for i, obj in pairs(editor.TopBar.RightButtons:GetChildren()) do
	if obj:IsA("TextButton") then
		UIManager.applyiconhover(obj)
	end
end

UIManager.applyiconhover(editor.NavBar.Buttons.AnimationInfo.Right)
UIManager.applyiconhover(editor.NavBar.Buttons.AnimationInfo.Left)

UIManager.checkuiscale(home.NavBar.MainButton.Edit).Scale = 0
UIManager.checkuiscale(framechanger).Scale = 0
UIManager.checkuiscale(tabchanger).Scale = 0

_G.selection.SelectionChanged:Connect(function()
	UIManager.checkselected()
end)


UIManager.applyiconhover(editor.Tabs.AddObject.Buttons.Add)
UIManager.applyiconhover(editor.Tabs.AddObject.Buttons.Cancel)

UIManager.checkuiscale(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Trash).Scale = 0
UIManager.checkuiscale(editor.NavBar.Buttons.AnimationInfo.CurrentPoint)

local downheretweenanim = nil

editor.NavBar.Buttons.AnimationInfo.CurrentPoint.MouseEnter:Connect(function()
	if tonumber(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Text) then
		if downheretweenanim then
			downheretweenanim:Cancel()
		end

		editor.NavBar.Buttons.AnimationInfo.CurrentPoint.TextTransparency = 1

		downheretweenanim = _G.tweenservice:Create(UIManager.checkuiscale(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Trash), TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
		downheretweenanim:Play()
	end	
end)

editor.NavBar.Buttons.AnimationInfo.CurrentPoint.MouseLeave:Connect(function()
	if downheretweenanim then
		downheretweenanim:Cancel()
	end

	UIManager.checkuiscale(editor.NavBar.Buttons.AnimationInfo.CurrentPoint.Trash).Scale = 0

	UIManager.checkuiscale(editor.NavBar.Buttons.AnimationInfo.CurrentPoint).Scale = 0
	editor.NavBar.Buttons.AnimationInfo.CurrentPoint.TextTransparency = 0

	downheretweenanim = _G.tweenservice:Create(UIManager.checkuiscale(editor.NavBar.Buttons.AnimationInfo.CurrentPoint), TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	downheretweenanim:Play()
end)
