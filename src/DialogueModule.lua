local tweenService = game:GetService("TweenService")
local textService = game:GetService("TextService")

local dialogueModule = {}

local dialogueFrame = script.Parent.Parent.DialogueFrame
local replyFrame = dialogueFrame.ReplyCanvas.ReplyFrame
local continueButton = dialogueFrame.ContinueButton

local dialogueCanvas = dialogueFrame.DialogueCanvas
local scrollingFrame = dialogueCanvas.ScrollingFrame
local SFuiListLayout = scrollingFrame.UIListLayout

local iconCanvas = dialogueFrame.IconCanvas
local iconImage = iconCanvas.ImageLabel;
local iconPlaceHolder = "rbxassetid://18187379387"

-- Variables for dialouge functions

local currentBlock = nil
local startBlock = nil
local continueDialogue = false
local isChoosingReply = false
local currentDialogueInfo = nil
local autoNext = nil
local endOnContinue = false
local exitingDialogue = false
local enteringDialogue = false

-- Setting

local repliesColor = Color3.new(1, 1, 1)
local repliesHoverColor = Color3.new(1, 0.705882, 0.705882)
local repliesUsedColor = Color3.new(0.654902, 0.654902, 0.654902)
local repliesUsedHoverColor = Color3.new(0.654902, 0.529412, 0.494118)
local textFont = Enum.Font.SourceSans

SFuiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
SFuiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
SFuiListLayout.VerticalFlex = Enum.UIFlexAlignment.None
SFuiListLayout.HorizontalFlex = Enum.UIFlexAlignment.None

-- RUNS THE DIALOGUE.
function dialogueModule.RunDialogue(DialogueInfo)
	if currentBlock then 
		return
	end
	
	while exitingDialogue do
		task.wait(0.2)
	end

	EnterDialogue()
	
	while enteringDialogue do
		task.wait(0.2)
	end
	
	currentDialogueInfo = DialogueInfo
	startBlock = currentDialogueInfo.Settings.StartBlock
	currentBlock = currentDialogueInfo[startBlock]
	
	while currentBlock do
		local readingTime = currentBlock.Seconds or calculateReadingTime(currentBlock.Text)
		CreateDialogue()
		
		iconImage.Image = iconPlaceHolder
		if currentBlock.Icon then
			iconImage.Image = currentBlock.Icon
		end
		
		if #currentBlock.Replies == 1 and not currentBlock.Replies[1].Text then
			if currentBlock.Replies[1].NextBlock then
				local nextBlock = currentBlock.Replies[1].NextBlock
				currentBlock = currentDialogueInfo[nextBlock]
			else
				endOnContinue = true
			end
		else
			CreateReplies()
			-- CreateReplies() also handles the reply choice
		end
		
		continueDialogue = false 
		-- continueButton.MouseButton1Click:Connect(function())... This sets continueDialogue to true
		
		if not isChoosingReply then
			autoNext = AutoNextDialogue(readingTime)
			coroutine.resume(autoNext)
		end
		
		while not continueDialogue or isChoosingReply do	
			task.wait(0.1)
		end
		
		coroutine.close(autoNext)
		if endOnContinue then
			ExitDialogue()
		end
	end	
end

continueButton.MouseButton1Click:Connect(function()
	if not isChoosingReply then
		continueDialogue = true
	end		
end)

function calculateReadingTime(text: string)
	local WPS = 3.1
	local wordCount = 1
	for i = 1, #text do
		local char = text:sub(i, i)
		if char == ' ' then
			wordCount = wordCount + 1
		end
	end
	
	print(wordCount / WPS.. " seconds")
	return wordCount / WPS
end

function AutoNextDialogue(seconds)
	return coroutine.create(function()
		task.wait(seconds)
		
		if not continueDialogue then
			print("Set to true")
			continueDialogue = true
		end
	end)
end

function CreateDialogue()
	local text = Instance.new("TextLabel")
	
	local size = textService:GetTextSize(currentBlock.Text, 20, textFont, Vector2.new(335, math.huge))
	text.Size = UDim2.new(0.95, 0, 0, size.Y)
	
	text.Text = currentBlock.Text
	text.Font = textFont
	text.TextSize = 20
	text.RichText = true
	
	text.TextColor3 = currentBlock.TextColor3
	text.TextScaled = false
	text.TextDirection = Enum.TextDirection.LeftToRight
	text.TextWrapped = true
	text.BackgroundTransparency = 1
	text.TextTransparency = 1
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Center

	text.Parent = scrollingFrame
	
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local Goal = {
		TextTransparency = 0
	}
	local tween = tweenService:Create(text, tweenInfo, Goal)
	tween:Play()
end

function CreateReplies()
	DeleteReplies()
	isChoosingReply = true
	
	for _, reply in ipairs(currentBlock.Replies) do
		local textButton = Instance.new("TextButton")
		
		local size = textService:GetTextSize(reply.Text, 20, textFont, Vector2.new(335, math.huge))
		textButton.Size = UDim2.new(0, 355, 0, size.Y)
		
		textButton.Text = reply.Text
		textButton.Font = textFont
		textButton.TextSize = 18
		
		textButton.Active = true
		textButton.BackgroundTransparency = 1
		textButton.Visible = true
		textButton.ZIndex = 3
		textButton.TextColor3 = repliesColor
		textButton.TextWrapped = true
		
		textButton.Parent = replyFrame
		
		textButton.MouseEnter:Connect(function()
			textButton.TextColor3 = repliesHoverColor
		end)
		
		textButton.MouseLeave:Connect(function()
			textButton.TextColor3 = repliesColor
		end)
		
		textButton.MouseButton1Click:Connect(function()
			if reply.Function then
				reply.Function()
			end
			
			local nextBlock = reply.NextBlock
			if nextBlock then
				if not currentDialogueInfo[nextBlock] then
					ExitDialogue()
					return
				end
				
				currentBlock = currentDialogueInfo[nextBlock]
				isChoosingReply = false
				continueDialogue = true
				DeleteReplies()
			else
				ExitDialogue()
			end
		end)
	end
end

function DeleteDialogue()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

function DeleteReplies()
	for _, child in ipairs(replyFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

function EnterDialogue()
	enteringDialogue = true
	currentBlock = nil
	startBlock = nil
	continueDialogue = false
	isChoosingReply = false
	currentDialogueInfo = nil
	dialogueFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
	
	dialogueFrame.Visible = true

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local Goal = {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}

	local tween = tweenService:Create(dialogueFrame, tweenInfo, Goal)
	tween:Play()
	enteringDialogue = false
end

function ExitDialogue()
	exitingDialogue = true
	currentBlock = nil
	startBlock = nil
	currentDialogueInfo = nil
	
	local tweenInfo = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	local Goal = {
		Position = UDim2.new(0.5, 0, -0.5, 0)
	}
	local tween = tweenService:Create(dialogueFrame, tweenInfo, Goal)
	tween:Play()

	task.wait(1)
	
	DeleteReplies()
	DeleteDialogue()
	
	dialogueFrame.Visible = false
	continueDialogue = false
	isChoosingReply = false
	exitingDialogue = false
end

local function ScrollToBottom()
	local canvasHeight = scrollingFrame.CanvasSize.Y.Offset
	local visibleHeight = scrollingFrame.AbsoluteSize.Y
	local newYPosition = canvasHeight - visibleHeight
	
	local tweenInfo = TweenInfo.new(
		0.2,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)

	local Goal = {
		CanvasPosition = Vector2.new(0, newYPosition)
	}
	local tween = tweenService:Create(scrollingFrame, tweenInfo, Goal)
	tween:Play()
end

local function UpdateCanvasSize()
	local totalHeight = 0
	
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("GuiObject") and child.Visible then	
			totalHeight = totalHeight + child.Size.Y.Offset + SFuiListLayout.Padding.Offset
		end
	end
	
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
	ScrollToBottom()
end
scrollingFrame.ChildAdded:Connect(UpdateCanvasSize)

-- On startup
ExitDialogue()
UpdateCanvasSize()
return dialogueModule
