local dialogueModule = require(script.Parent.Parent.Main:WaitForChild("DialogueModule")) -- Folder that contains all dialogue blocks
local dialogueBlock = workspace:WaitForChild("DialoguePrompts"):WaitForChild("Test") -- Make a dialogue block with proxmity prompt.

--[[
	nil for default settings. The dialogues also supports rich text which allows you to do things like: <b>YOU</b> - Walked to there.
	Which is how I write my dialogues.
]]
	
--[[ 

PROPERTIES:

Text (string): Used to display dialogues. Cannot be nil.
Replies (table):
	- Text (string): The reply text. nil is acceptable only if there is one reply.
	- NextBlock (string): Block to go after the dialogue. Nil ends the dialogue.
	- Function (function): The function that will excecute after the reply.
Seconds (number): How long the dialogue will display before moving on. Nil sets it to default.
TextColor3 (Color3): The color of the text.
Icon (string): Accepts a string of roblox ids to display for the icon. Nil gives it a placeholder.

EXAMPLES:

ExampleBlock1 = {
	Text = "", -- Dont set this to nil. There isn't a reason to set it to nil.
	Replies = {
		{
			Text = nil, -- You can only use nil if there are only one element in replies. It is used to conjoin dialogues without replies.
			NextBlock = "Block2" -- The next block to go to after the reply.
			Function = nil, -- The function that will excecute after reply. You can also put a function even if there are no text.
		},
	},
			
	Seconds = nil, -- Duration of the dialogue before it moves to the next one. Nil is default. Which is a calculation of average reading time.
	TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
	Icon = nil, -- Icon for the pfp, nil will set it to default.
},
ExampleBlock2 = {
	Text = "",
	Replies = { -- This has two elements in replies so there can't be a reply element with a nil text.
		{
			Text = "What??", -- Reply text
			NextBlock = "Block2" -- The next block to go to after the reply.
			Function = nil, -- The function that will excecute after reply, will not execute if Text is nil.
		},
		{
			Text = "Hey", -- Reply text
			NextBlock = nil -- Setting this to nil will stop the dialogue
			Function = function()
				print("Hello")
			end, -- The function that will excecute after reply, will not execute if Text is nil.
		},
	},
			
	Seconds = nil,
	TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
	Icon = nil,
},
ExampleBlock3 = {
	Text = "",
	Replies = { -- This is acceptable because after the player clicks on the reply, it'll end the dialogue.
		{
			Text = "Bye", -- Reply text
			NextBlock = nil -- Setting to nil will end the dialogue
			Function = nil, -- The function that will excecute after reply, will not execute if Text is nil.
		},
	},
			
	Seconds = nil,
	TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
	Icon = nil,
}
ExampleBlock4 = {
	Text = "",
	Replies = { -- This is acceptable because after the player clicks on the reply, it'll end the dialogue.
		{
			Text = nil, -- Setting both Text and Nextblock works but I don't recommend unless you want to cut dialogue short. 
						-- By doing that, you should also manually adjust the seconds for better timing.
			NextBlock = nil 
			Function = nil, -- The function that will excecute after reply, will not execute if Text is nil.
		},
	},
			
	Seconds = 4.0, -- manually adjusted because Text and NextBlock are both nil.
	TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
	Icon = nil,
}

EXAMPLES TO AVOID:

ExampleBlockToNotDo1 = {
	Text = "",
	Replies = {
		{
			Text = nil, -- Setting this to nil will cause an error because I haven't written code for a nil reply within 2 or more replies. 
						-- It also doesn't make sense to have a nil reply with multiple replies.
			NextBlock = "Block2" -- The next block to go to after the reply.
			Function = nil, -- The function that will excecute after reply, will not execute if Text is nil.
		},
		{
			Text = "Hey", -- Reply text
			NextBlock = nil -- Setting this to nil will stop the dialogue
			Function = nameFunction -- this is acceptable if nameFunction is already defined in the script.
		},
	},
			
	Seconds = nil,
	TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
	Icon = nil,
},
ExampleBlockToNotDo2 = {
	Text = nil, -- Dont do this
	Replies = {
		{
			Text = "Hi",
			NextBlock = nil,
			Function = nil
		},
	},
			
	Seconds = nil,
	TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
	Icon = nil,
},

]]

dialogueBlock.ProximityPrompt.Triggered:Connect(function()
	local DialogueInfo = {	
		Settings = {
			RepliesColor = nil,
			RepliesHoverColor = nil,
			StartBlock = "StartBlock" -- Very important, this will tell the script which block to start with.
		}, 
		
		StartBlock = {
			Text = "<b>TEST DIALOGUE</b> - \"Hello "..game.Players.LocalPlayer.DisplayName..
				", As you can see, this is a test dialogue.\" The block grabs your attention.",
			Replies = {
				{
					Text = nil,
					NextBlock = "GreetingBlock",
					Function = nil,
				},
			},

			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		GreetingBlock = {
			Text = "<b>TEST DIALOGUE</b> - It asks you, \"How are you feeling today?\" But you find confusion in where its voice comes from."..
				   " It notices your worries and reassures you, \"Oh! don't worry about what I am, I'm just a block. Now... back to my question!\"",
			Replies = {
				{
					Text = "\"I'm doing good thank you.\"",
					NextBlock = "FeelingOkayBlock",
					Function = nil,
				},
				{
					Text = "\"Honestly, I'm not feeling well.\"", 
					NextBlock = "YouNotWellBlock",
					Function = function()
						print("sad!")
					end,
				},
				{
					Text = "\"Just... What are you???\"",
					NextBlock = "WhatAreYou",
					Function = nil,
				},
			},

			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		WhatAreYou = {
			Text = "<b>YOU</b> - \"What are you...?\" You chose to persist on the matter of its existence.",
			
			Replies = {
				{
					Text = nil,
					NextBlock = "QuestionedBlock",
					Function = nil
				}
			},

			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		QuestionedBlock = {
			Text = "<b>TEST DIALOGUE</b> - \"Like I said, don't worry about it! I just want to know how are you.\"".. 
				"As it reminds you not to worry, you can't help but feel curiosity come over you.",
			Replies = {
				{
					Text = "Break the block",
					NextBlock = "WaitNo",
					Function = nil
				},
				{
					Text = "\"Fine.\"",
					NextBlock = "GreetingBlock",
					Function = nil,
				},
			},
	
			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		WaitNo = {
			Text = "<b>TEST DIALOGUE</b> - \"Wait... What are you doing!?\" It panics as you sit your foot right on top of it.",
			
			Replies = {
				{
					Text = "... (End).",
					NextBlock = nil,
					Function = function()
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://7772283448"
						sound.Volume = 0.1 -- Set the volume (0 to 10)
						sound.PlayOnRemove = true -- Ensures the sound plays when removed
						sound.Parent = dialogueBlock -- Set the parent (e.g., Workspace or a specific part)
						dialogueBlock:Destroy()
					end,
				},
			},
			
			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		YouNotWellBlock = {
			Text = "<b>YOU</b> - \"I'm not really feeling well.\" You say to the block.",
			Replies = {
				{
					Text = nil,
					NextBlock = "NotFeelingWellBlock",
					Function = nil,
				},
			},
			
			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		NotFeelingWellBlock = {
			Text = "<b>TEST DIALOGUE</b> - \"I hope you'll feel better, I'm sorry to hear that...\"",
			Replies = {
				{
					Text = nil,
					NextBlock = "AfterGreetBlock",
					Function = nil,
				},
			},
			
			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		FeelingOkayBlock = {
			Text = "<b>YOU</b> - \"I feel okay.\" You say to the block.",
			Replies = {
				{
					Text = nil,
					NextBlock = "AfterGreetBlock",
					Function = nil
				},
			},
			
			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		},
		AfterGreetBlock = {
			Text = "<b>TEST DIALOGUE</b> - \"Thank you for talking.\"",
			Replies = {
				{
					Text = "\"Bye!\"",
					NextBlock = nil,
					Function = nil,
				},
			},
			
			Seconds = nil,
			TextColor3 = Color3.new(0.8, 0.592157, 0.576471),
			Icon = nil,
		}
	}
	dialogueModule.RunDialogue(DialogueInfo)
end)
