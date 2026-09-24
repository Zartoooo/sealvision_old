local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")


local IsStudio = RunService:IsStudio()

-- thanks chatgpt
local SimplifiedKeybinds = {
	["RightShift"] = "RSH",  -- Right Shift
	["LeftShift"] = "LSH",   -- Left Shift
	["RightCtrl"] = "RCT",   -- Right Control
	["LeftCtrl"] = "LCT",    -- Left Control
	["RightAlt"] = "RAT",    -- Right Alt (or Option on Mac)
	["LeftAlt"] = "LAT",     -- Left Alt (or Option on Mac)
	["Space"] = "SPC",       -- Spacebar
	["Enter"] = "ENT",       -- Enter (or Return)
	["Backspace"] = "BSP",   -- Backspace
	["Tab"] = "TAB",         -- Tab
	["Escape"] = "ESC",      -- Escape
	["CapsLock"] = "CAP",    -- Caps Lock
	["Insert"] = "INS",      -- Insert
	["Delete"] = "DEL",      -- Delete
	["Home"] = "HOM",        -- Home
	["End"] = "END",         -- End
	["PageUp"] = "PUP",      -- Page Up
	["PageDown"] = "PDN",    -- Page Down
	["Up"] = "UP",           -- Up Arrow
	["Down"] = "DWN",        -- Down Arrow
	["Left"] = "LFT",        -- Left Arrow
	["Right"] = "RGT",       -- Right Arrow
	["F1"] = "F1",           -- Function keys F1 to F12
	["F2"] = "F2",
	["F3"] = "F3",
	["F4"] = "F4",
	["F5"] = "F5",
	["F6"] = "F6",
	["F7"] = "F7",
	["F8"] = "F8",
	["F9"] = "F9",
	["F10"] = "F10",
	["F11"] = "F11",
	["F12"] = "F12",
	["NumLock"] = "NUM",     -- Num Lock
	["ScrollLock"] = "SCR",  -- Scroll Lock
	["PrintScreen"] = "PSC", -- Print Screen
	["Pause"] = "PAU",       -- Pause/Break
	["Mouse1"] = "M1",       -- Left Mouse Button
	["Mouse2"] = "M2",       -- Right Mouse Button
	["Mouse3"] = "M3",       -- Middle Mouse Button
	["Mouse4"] = "M4",       -- Mouse Button 4
	["Mouse5"] = "M5",       -- Mouse Button 5
	["MouseWheelUp"] = "MWU", -- Mouse Wheel Up
	["MouseWheelDown"] = "MWD", -- Mouse Wheel Down
	["One"] = "1",
	["Two"] = "2",
	["Three"] = "3",
	["Four"] = "4",
	["Five"] = "5",
	["Six"] = "6",
	["Seven"] = "7",
	["Eight"] = "8",
	["Nine"] = "9",
	["Zero"] = "0",
	["Minus"] = "-",         -- Minus (-)
	["Equals"] = "=",        -- Equals (=)
	["LeftBracket"] = "[",   -- Left Bracket ([)
	["RightBracket"] = "]",  -- Right Bracket (])
	["Backslash"] = "\\",    -- Backslash (\)
	["Semicolon"] = ";",     -- Semicolon (;)
	["Apostrophe"] = "'",    -- Apostrophe (')
	["Comma"] = ",",         -- Comma (,)
	["Period"] = ".",        -- Period (.)
	["Slash"] = "/",         -- Slash (/)
	["Grave"] = "`",         -- Grave Accent (`)
	["Numpad0"] = "NP0",     -- Numpad 0
	["Numpad1"] = "NP1",     -- Numpad 1
	["Numpad2"] = "NP2",     -- Numpad 2
	["Numpad3"] = "NP3",     -- Numpad 3
	["Numpad4"] = "NP4",     -- Numpad 4
	["Numpad5"] = "NP5",     -- Numpad 5
	["Numpad6"] = "NP6",     -- Numpad 6
	["Numpad7"] = "NP7",     -- Numpad 7
	["Numpad8"] = "NP8",     -- Numpad 8
	["Numpad9"] = "NP9",     -- Numpad 9
	["NumpadMultiply"] = "NP*", -- Numpad Multiply (*)
	["NumpadAdd"] = "NP+",   -- Numpad Add (+)
	["NumpadSubtract"] = "NP-", -- Numpad Subtract (-)
	["NumpadDecimal"] = "NP.", -- Numpad Decimal (.)
	["NumpadDivide"] = "NP/", -- Numpad Divide (/)
	["NumpadEnter"] = "NPE", -- Numpad Enter
}

local Connections = {}
local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(Connections, connection)
	return connection
end

local env = getgenv and getgenv()
local previous = env and env.DeadlinesUI
if type(previous) == "table" and type(previous.unload) == "function" then
	pcall(previous.unload)
end

local Library = {
	Binds = {},
	Flags = {},
	Connections = Connections,
	Disposed = false,
	Opened = true,
	MainWindow = nil,
}

-- Shared Dragging Function
local function EnableDragging(frame, handle, checkMenu)
	local dragging, dragInput, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			-- Only allow dragging if menu is open (if checkMenu is true)
			if checkMenu and not Library.Opened then return end

			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			dragInput = input
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function _darken_color(color, amount)
	amount = math.clamp(amount or 0.7, 0, 1)
	local r = math.clamp(color.R * amount, 0, 1)
	local g = math.clamp(color.G * amount, 0, 1)
	local b = math.clamp(color.B * amount, 0, 1)
	return Color3.new(r, g, b)
end

local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

local Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
	if not IsStudio then
		if not gethui then
			Parent = game:GetService("CoreGui")
		else
			Parent = gethui()
		end
	end
end)

-- StarterGui.ScreenGui
Library["1"] = Instance.new("ScreenGui", Parent) ;
Library["1"]["IgnoreGuiInset"] = true;
Library["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
Library["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;

-- Toggle Logic
connect(UserInputService.InputBegan, function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		Library.Opened = not Library.Opened
		if Library.MainWindow then
			Library.MainWindow.Visible = Library.Opened
		end
	end
end)

function Library:CreateWindow(Config)
	local Title = Config.Title or [[seal<font color="#e25d11">vision</font>.net]]
	local Size = Config.Size or UDim2.new(0, 600, 0, 400)

	local Window = { 
		ActiveTab = nil,
		Tabs = {}
	}

	-- Track the active window so Library:IsMenuBlocked can reach its pickers/flags
	Library.Window = Window

	do
		-- StarterGui.ScreenGui.Window
		Window["2"] = Instance.new("Frame", Library["1"]);
		Window["2"]["BorderSizePixel"] = 0;
		Window["2"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		Window["2"]["Size"] = Size;
		Window["2"]["Position"] = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2);
		Window["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Window["2"]["Name"] = [[Window]];
		Library.MainWindow = Window["2"]

		Window["drag_frame"] = Instance.new("Frame", Window["2"]);
		Window["drag_frame"]["BorderSizePixel"] = 0;
		Window["drag_frame"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		Window["drag_frame"]["Size"] = UDim2.new(1,0,0,30);
		Window["drag_frame"]["Position"] = UDim2.new(0,0,0,0);
		Window["drag_frame"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Window["drag_frame"]["Name"] = [[DragHandle]];
		Window["drag_frame"].BackgroundTransparency = 1

		-- StarterGui.ScreenGui.Window.UIStroke
		Window["3"] = Instance.new("UIStroke", Window["2"]);
		Window["3"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
		Window["3"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
		Window["3"]["Thickness"] = 2;
		Window["3"]["Color"] = Color3.fromRGB(71, 71, 71);


		-- StarterGui.ScreenGui.Window.Inner
		Window["4"] = Instance.new("Frame", Window["2"]);
		Window["4"]["BorderSizePixel"] = 0;
		Window["4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Window["4"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
		Window["4"]["Size"] = UDim2.new(1, -10, 1, -10);
		Window["4"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
		Window["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Window["4"]["Name"] = [[Inner]];
		Window["4"]["BackgroundTransparency"] = 1;


		-- StarterGui.ScreenGui.Window.Inner.Top
		Window["5"] = Instance.new("Frame", Window["4"]);
		Window["5"]["ZIndex"] = 2;
		Window["5"]["BorderSizePixel"] = 0;
		Window["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Window["5"]["Size"] = UDim2.new(1, 0, 0, 15);
		Window["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Window["5"]["Name"] = [[Top]];
		Window["5"]["BackgroundTransparency"] = 1;


		-- StarterGui.ScreenGui.Window.Inner.Top.Title
		Window["6"] = Instance.new("TextLabel", Window["5"]);
		Window["6"]["TextStrokeTransparency"] = 0;
		Window["6"]["BorderSizePixel"] = 0;
		Window["6"]["TextSize"] = 12;
		Window["6"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		Window["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Window["6"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		Window["6"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
		Window["6"]["BackgroundTransparency"] = 1;
		Window["6"]["RichText"] = true;
		Window["6"]["Size"] = UDim2.new(0, 100, 1, 0);
		Window["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Window["6"]["Text"] = Title;
		Window["6"]["Name"] = [[Title]];


		-- StarterGui.ScreenGui.Window.Inner.Top.Title.UIPadding
		Window["7"] = Instance.new("UIPadding", Window["6"]);
		Window["7"]["PaddingLeft"] = UDim.new(0, 3);
		Window["7"]["PaddingBottom"] = UDim.new(0, 8);


		-- StarterGui.ScreenGui.Window.Inner.Top.TabsHolder
		Window["8"] = Instance.new("Frame", Window["5"]);
		Window["8"]["BorderSizePixel"] = 0;
		Window["8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Window["8"]["AnchorPoint"] = Vector2.new(1, 0);
		Window["8"]["Size"] = UDim2.new(1, 0, 1, 0);
		Window["8"]["Position"] = UDim2.new(1, -50, 0, 0);
		Window["8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Window["8"]["Name"] = [[TabsHolder]];
		Window["8"]["BackgroundTransparency"] = 1;


		-- StarterGui.ScreenGui.Window.Inner.Top.TabsHolder.UIListLayout
		Window["9"] = Instance.new("UIListLayout", Window["8"]);
		Window["9"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Right;
		Window["9"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
		Window["9"]["FillDirection"] = Enum.FillDirection.Horizontal;
	end

	EnableDragging(Window["2"], Window["drag_frame"], false)

	function Window:CreateColorpickerController()
		local Colorpicker = {
			CurrentPicker = nil,
			CurrentConfig = nil,
			IsDragging = false,
			DragType = nil -- "main", "hue", or "transparency"
		}

		do
			Colorpicker["7d"] = Instance.new("Frame", Library["1"]);
			Colorpicker["7d"]["BorderSizePixel"] = 0;
			Colorpicker["7d"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
			Colorpicker["7d"]["Size"] = UDim2.new(0, 194, 0, 150);
			Colorpicker["7d"]["Position"] = UDim2.new(1, 10, 0, 0);
			Colorpicker["7d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["7d"]["Name"] = "Colorpicker";
			Colorpicker["7d"].Visible = false;
			-- Raise ZIndex so it renders above other UI
			Colorpicker["7d"].ZIndex = 10;

			Colorpicker["7e"] = Instance.new("UIStroke", Colorpicker["7d"]);
			Colorpicker["7e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
			Colorpicker["7e"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
			Colorpicker["7e"]["Thickness"] = 2;
			Colorpicker["7e"]["Color"] = Color3.fromRGB(71, 71, 71);

			Colorpicker["7f"] = Instance.new("Frame", Colorpicker["7d"]);
			Colorpicker["7f"]["BorderSizePixel"] = 0;
			Colorpicker["7f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["7f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
			Colorpicker["7f"]["Size"] = UDim2.new(1, -10, 1, -10);
			Colorpicker["7f"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
			Colorpicker["7f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["7f"]["Name"] = "Inner";
			Colorpicker["7f"]["BackgroundTransparency"] = 1;

			Colorpicker["80"] = Instance.new("Frame", Colorpicker["7f"]);
			Colorpicker["80"]["ZIndex"] = 2;
			Colorpicker["80"]["BorderSizePixel"] = 0;
			Colorpicker["80"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["80"]["Size"] = UDim2.new(1, 0, 0, 15);
			Colorpicker["80"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["80"]["Name"] = "Top";
			Colorpicker["80"]["BackgroundTransparency"] = 1;

			Colorpicker["81"] = Instance.new("TextLabel", Colorpicker["80"]);
			Colorpicker["81"]["TextStrokeTransparency"] = 0;
			Colorpicker["81"]["BorderSizePixel"] = 0;
			Colorpicker["81"]["TextSize"] = 12;
			Colorpicker["81"]["TextXAlignment"] = Enum.TextXAlignment.Left;
			Colorpicker["81"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["81"]["FontFace"] = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			Colorpicker["81"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["81"]["BackgroundTransparency"] = 1;
			Colorpicker["81"]["RichText"] = true;
			Colorpicker["81"]["Size"] = UDim2.new(1, 0, 1, 0);
			Colorpicker["81"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["81"]["Text"] = "Name | <font color=\"#ff0000\">■</font>";
			Colorpicker["81"]["Name"] = "Title";

			Colorpicker["82"] = Instance.new("UIPadding", Colorpicker["81"]);
			Colorpicker["82"]["PaddingLeft"] = UDim.new(0, 3);
			Colorpicker["82"]["PaddingBottom"] = UDim.new(0, 8);

			Colorpicker["83"] = Instance.new("Frame", Colorpicker["7f"]);
			Colorpicker["83"]["BorderSizePixel"] = 0;
			Colorpicker["83"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["83"]["Size"] = UDim2.new(1, 0, 1, -20);
			Colorpicker["83"]["Position"] = UDim2.new(0, 0, 0, 15);
			Colorpicker["83"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["83"]["Name"] = "Content";
			Colorpicker["83"]["BackgroundTransparency"] = 1;

			-- Main color picker area
			Colorpicker["84"] = Instance.new("Frame", Colorpicker["83"]);
			Colorpicker["84"]["BorderSizePixel"] = 0;
			Colorpicker["84"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["84"]["Size"] = UDim2.new(1, 0, 0, 80); -- Fixed height for saturation box
			Colorpicker["84"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["84"]["Name"] = "MainBox";
			Colorpicker["84"]["Active"] = true; -- Sink input
			-- ClipsDescendants keeps the cursor dot from rendering outside the box
			Colorpicker["84"].ClipsDescendants = true
			
			Colorpicker["85"] = Instance.new("UIGradient", Colorpicker["84"]);
			Colorpicker["85"]["Color"] = ColorSequence.new{
				ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 5))
			};

			Colorpicker["86"] = Instance.new("Frame", Colorpicker["84"]);
			Colorpicker["86"]["BorderSizePixel"] = 0;
			Colorpicker["86"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["86"]["Size"] = UDim2.new(1, 0, 1, 0);
			Colorpicker["86"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["86"]["Name"] = "Inner";

			Colorpicker["87"] = Instance.new("UIGradient", Colorpicker["86"]);
			Colorpicker["87"]["Rotation"] = 90;
			Colorpicker["87"]["Transparency"] = NumberSequence.new{
				NumberSequenceKeypoint.new(0.000, 1),
				NumberSequenceKeypoint.new(1.000, 0)
			};
			Colorpicker["87"]["Color"] = ColorSequence.new{
				ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 0, 0))
			};

			Colorpicker["88"] = Instance.new("Frame", Colorpicker["84"]);
			Colorpicker["88"]["BorderSizePixel"] = 0;
			Colorpicker["88"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["88"]["Size"] = UDim2.new(0, 5, 0, 5);
			Colorpicker["88"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
			Colorpicker["88"]["Position"] = UDim2.new(1, 0, 0, 0);
			Colorpicker["88"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["88"]["Name"] = "Cursor";
			-- Raise cursor above the dark overlay frame
			Colorpicker["88"].ZIndex = 5;

			Colorpicker["89"] = Instance.new("UICorner", Colorpicker["88"]);
			Colorpicker["89"]["CornerRadius"] = UDim.new(1, 0);

			Colorpicker["8a"] = Instance.new("UIStroke", Colorpicker["88"]);
			Colorpicker["8a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;

			Colorpicker["8b"] = Instance.new("UIStroke", Colorpicker["84"]);
			Colorpicker["8b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
			Colorpicker["8b"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
			Colorpicker["8b"]["Thickness"] = 2;

			Colorpicker["8c"] = Instance.new("Frame", Colorpicker["83"]);
			Colorpicker["8c"]["Size"] = UDim2.new(1, 0, 0, 30);
			Colorpicker["8c"]["Position"] = UDim2.new(0, 0, 0, 85); -- Position below MainBox
			Colorpicker["8c"]["BackgroundTransparency"] = 1;
			Colorpicker["8c"]["Name"] = "SlidersHolder";

			Colorpicker["8d"] = Instance.new("Frame", Colorpicker["8c"]);
			Colorpicker["8d"]["Size"] = UDim2.new(1, 0, 0, 10);
			Colorpicker["8d"]["BackgroundColor3"] = Color3.new(1, 1, 1);
			Colorpicker["8d"]["Active"] = true;

			

			Colorpicker["8e"] = Instance.new("UIGradient", Colorpicker["8d"]);
			Colorpicker["8e"]["Color"] = ColorSequence.new{
				ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 5)),
				ColorSequenceKeypoint.new(0.200, Color3.fromRGB(235, 255, 0)),
				ColorSequenceKeypoint.new(0.400, Color3.fromRGB(22, 255, 0)),
				ColorSequenceKeypoint.new(0.600, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.800, Color3.fromRGB(0, 18, 255)),
				ColorSequenceKeypoint.new(0.900, Color3.fromRGB(255, 0, 252)),
				ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))
			};

			-- Hue cursor
			Colorpicker["8f"] = Instance.new("Frame", Colorpicker["8d"]);
			Colorpicker["8f"]["BorderSizePixel"] = 0;
			Colorpicker["8f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["8f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
			Colorpicker["8f"]["Size"] = UDim2.new(0, 2, 1, 2);
			Colorpicker["8f"]["Position"] = UDim2.new(1, 0, 0.5, 0);
			Colorpicker["8f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["8f"]["Name"] = "Cursor";
			Colorpicker["8f"].ZIndex = 5;

			Colorpicker["90"] = Instance.new("UIStroke", Colorpicker["8f"]);
			Colorpicker["90"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;

			Colorpicker["91"] = Instance.new("Frame", Colorpicker["8f"]);
			Colorpicker["91"]["BorderSizePixel"] = 0;
			Colorpicker["91"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["91"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
			Colorpicker["91"]["Size"] = UDim2.new(0, 10, 0, 10);
			Colorpicker["91"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
			Colorpicker["91"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["91"]["Name"] = "Grab";
			Colorpicker["91"]["BackgroundTransparency"] = 1;

			Colorpicker["92"] = Instance.new("Frame", Colorpicker["8c"]);
			Colorpicker["92"]["Size"] = UDim2.new(1, 0, 0, 10);
			Colorpicker["92"]["Position"] = UDim2.new(0, 0, 0, 15);
			Colorpicker["92"]["BackgroundColor3"] = Color3.new(1, 1, 1);
			Colorpicker["92"]["Active"] = true;

			Colorpicker["93"] = Instance.new("UIGradient", Colorpicker["92"]);
			Colorpicker["93"]["Color"] = ColorSequence.new{
				ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))
			};

			-- Transparency cursor
			Colorpicker["94"] = Instance.new("Frame", Colorpicker["92"]);
			Colorpicker["94"]["BorderSizePixel"] = 0;
			Colorpicker["94"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["94"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
			Colorpicker["94"]["Size"] = UDim2.new(0, 2, 1, 2);
			Colorpicker["94"]["Position"] = UDim2.new(1, 0, 0.5, 0);
			Colorpicker["94"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["94"]["Name"] = "Cursor";
			Colorpicker["94"].ZIndex = 5;

			Colorpicker["95"] = Instance.new("UIStroke", Colorpicker["94"]);
			Colorpicker["95"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;

			Colorpicker["96"] = Instance.new("Frame", Colorpicker["92"]);
			Colorpicker["96"]["BorderSizePixel"] = 0;
			Colorpicker["96"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Colorpicker["96"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
			Colorpicker["96"]["Size"] = UDim2.new(0, 10, 0, 10);
			Colorpicker["96"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
			Colorpicker["96"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Colorpicker["96"]["Name"] = "Grab";
			Colorpicker["96"]["BackgroundTransparency"] = 1;
			
			-- Ensure Cursors are centered
			Colorpicker["88"].AnchorPoint = Vector2.new(0.5, 0.5)
			Colorpicker["8f"].AnchorPoint = Vector2.new(0.5, 0.5)
			Colorpicker["94"].AnchorPoint = Vector2.new(0.5, 0.5)
		end

		local function getRelativePosition(frame, mousePosition)
			local framePos = frame.AbsolutePosition
			local frameSize = frame.AbsoluteSize
			local relativeX = (mousePosition.X - framePos.X) / frameSize.X
			local relativeY = (mousePosition.Y - framePos.Y) / frameSize.Y
			return Vector2.new(clamp(relativeX, 0, 1), clamp(relativeY, 0, 1))
		end

		local function updateColorFromCurrentValues()
			if not Colorpicker.CurrentConfig then return end

			local hue = math.clamp(Colorpicker["8f"].Position.X.Scale, 0, 1)
			local saturation = math.clamp(Colorpicker["88"].Position.X.Scale, 0, 1)
			local value = math.clamp(1 - Colorpicker["88"].Position.Y.Scale, 0, 1)
			local transparency = math.clamp(Colorpicker["94"].Position.X.Scale, 0, 1)

			local newColor = Color3.fromHSV(hue, saturation, value)
			Colorpicker.CurrentConfig.Color = newColor
			Colorpicker.CurrentConfig.Transparency = transparency

			-- Update UI Elements
			local hueColor = Color3.fromHSV(hue, 1, 1)
			Colorpicker["85"].Color = ColorSequence.new(Color3.new(1,1,1), hueColor)
			Colorpicker["93"].Color = ColorSequence.new(Color3.new(0,0,0), hueColor)

			-- Update Widget Button & darkened stroke
			if Colorpicker.CurrentConfig._WidgetButton then
				local btn = Colorpicker.CurrentConfig._WidgetButton
				btn.BackgroundColor3 = newColor
				local stroke = btn:FindFirstChildOfClass("UIStroke") or btn:FindFirstChild("36")
				if stroke then
					stroke.Color = _darken_color(newColor, 0.7)
				end
			end

			if Colorpicker.CurrentConfig.Callback then
				Colorpicker.CurrentConfig.Callback(newColor, transparency)
			end
		end

		local function startDrag(dragType)
			Colorpicker.IsDragging = true
			Colorpicker.DragType = dragType
		end

		local function stopDrag()
			Colorpicker.IsDragging = false
			Colorpicker.DragType = nil
		end

		local function handleDrag()
			if not Colorpicker.IsDragging or not Colorpicker.DragType then return end
			local mousePos = UserInputService:GetMouseLocation()

			if Colorpicker.DragType == "main" then
				local relativePos = getRelativePosition(Colorpicker["84"], mousePos)
				Colorpicker["88"].Position = UDim2.fromScale(relativePos.X, relativePos.Y)
			elseif Colorpicker.DragType == "hue" then
				local relativePos = getRelativePosition(Colorpicker["8d"], mousePos)
				Colorpicker["8f"].Position = UDim2.fromScale(relativePos.X, 0.5)
			elseif Colorpicker.DragType == "transparency" then
				local relativePos = getRelativePosition(Colorpicker["92"], mousePos)
				Colorpicker["94"].Position = UDim2.fromScale(relativePos.X, 0.5)
			end
			updateColorFromCurrentValues()
		end

		-- Close picker when clicking outside of it
		connect(UserInputService.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if Colorpicker["7d"].Visible then
					local mousePos = UserInputService:GetMouseLocation()
					local absPos  = Colorpicker["7d"].AbsolutePosition
					local absSize = Colorpicker["7d"].AbsoluteSize

					-- Check if mouse is within the bounds of the Colorpicker frame
					local inside = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
						and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y

					-- FIX: Only close if the click was actually outside the UI
					if not inside then
						Colorpicker["7d"].Visible = false
					end
				end
			end
		end)

		Colorpicker["84"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				startDrag("main")
				handleDrag()
			end
		end)

		Colorpicker["91"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				startDrag("hue")
			end
		end)

		Colorpicker["8d"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				startDrag("hue")
				handleDrag()
			end
		end)

		Colorpicker["96"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				startDrag("transparency")
			end
		end)

		Colorpicker["92"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				startDrag("transparency")
				handleDrag()
			end
		end)

		connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				stopDrag()
			end
		end)

		connect(RunService.Heartbeat, function()
			if Colorpicker.IsDragging then
				handleDrag()
			end
		end)

		function Colorpicker:SetVisible(visible)
			Colorpicker["7d"].Visible = visible
		end

		function Colorpicker:LoadPicker(Config)
			if not Config or not Config.Name or not Config.Color then
				warn("LoadPicker: Invalid config provided")
				return
			end

			if Config._AbsolutePosition then
				local btnPos  = Config._AbsolutePosition
				local btnSize = Config._AbsoluteSize or Vector2.new(0, 0)
				Colorpicker["7d"].Position = UDim2.fromOffset(btnPos.X + btnSize.X + 4, btnPos.Y)
			end

			Colorpicker.CurrentConfig = Config

			local colorHex = string.format("#%02x%02x%02x", 
				math.floor(Config.Color.R * 255), 
				math.floor(Config.Color.G * 255), 
				math.floor(Config.Color.B * 255)
			)
			Colorpicker["81"].Text = Config.Name .. " | <font color=\"" .. colorHex .. "\">■</font>"

			local hue, saturation, value = Config.Color:ToHSV()

			Colorpicker["8f"].Position = UDim2.new(hue, 0, 0.5, 0)

			local transparency = Config.Transparency or 0
			Colorpicker["94"].Position = UDim2.new(transparency, 0, 0.5, 0)

			local hueColor = Color3.fromHSV(hue, 1, 1)
			Colorpicker["85"].Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, hueColor)
			}

			Colorpicker["93"].Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(1, hueColor)
			}

			Colorpicker["88"].Position = UDim2.fromScale(saturation, 1 - value)
		end

		return Colorpicker
	end

	Window.PickerController = Window:CreateColorpickerController()

	function Window:SetTab(Tab)
		if Window.ActiveTab then
			Window.ActiveTab:SetActivated(false)
		end
		if Tab then
			Window.ActiveTab = Tab;
			Tab:SetActivated(true)
		end
	end

	function Window:AddTab(Config)
		local Name = Config.Name or "Tab"

		local Tab = {
			Active = false,
			Subtabs = {},
			ActiveSubtab = nil
		}

		do
			Tab["e"] = Instance.new("Frame", Window["8"]);
			Tab["e"]["BorderSizePixel"] = 0;
			Tab["e"].BackgroundColor3 = Color3.fromRGB(47, 47, 47)
			Tab["e"]["Size"] = UDim2.new(0, 100, 1, 0);
			Tab["e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["e"]["Name"] = [[Active]];

			Tab["f"] = Instance.new("UIStroke", Tab["e"]);
			Tab["f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
			Tab["f"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
			Tab["f"]["Thickness"] = 2;

			Tab["10"] = Instance.new("TextLabel", Tab["e"]);
			Tab["10"]["TextStrokeTransparency"] = 0;
			Tab["10"]["BorderSizePixel"] = 0;
			Tab["10"]["TextSize"] = 12;
			Tab["10"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Tab["10"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			Tab["10"].TextColor3 = Color3.fromRGB(166, 166, 166)
			Tab["10"]["BackgroundTransparency"] = 1;
			Tab["10"]["Size"] = UDim2.new(0, 100, 1, 0);
			Tab["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["10"]["Text"] = Name;
			Tab["10"]["Name"] = [[Title]];

			Tab["11"] = Instance.new("UIPadding", Tab["10"]);
			Tab["11"]["PaddingBottom"] = UDim.new(0, 3);

			Tab["12"] = Instance.new("Frame", Tab["e"]);
			Tab["12"]["BorderSizePixel"] = 0;
			Tab["12"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 34);
			Tab["12"]["Size"] = UDim2.new(1, 0, 0, 2);
			Tab["12"]["Position"] = UDim2.new(0, 0, 1, 0);
			Tab["12"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["12"]["Name"] = [[StrokeCache]];
			Tab["12"].Visible = false

			Tab["13"] = Instance.new("Frame", Window["4"]);
			Tab["13"]["BorderSizePixel"] = 0;
			Tab["13"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Tab["13"]["Size"] = UDim2.new(1, 0, 1, -15);
			Tab["13"]["Position"] = UDim2.new(0, 0, 0, 15);
			Tab["13"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["13"]["Name"] = [[Content]];
			Tab["13"]["BackgroundTransparency"] = 1;
			Tab["13"].Visible = false -- Starts hidden

			Tab["14"] = Instance.new("Frame", Tab["13"]);
			Tab["14"]["BorderSizePixel"] = 0;
			Tab["14"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 34);
			Tab["14"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
			Tab["14"]["Size"] = UDim2.new(1, -4, 1, -4);
			Tab["14"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
			Tab["14"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["14"]["Name"] = [[Inner]];

			Tab["15"] = Instance.new("UIStroke", Tab["14"]);
			Tab["15"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
			Tab["15"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
			Tab["15"]["Thickness"] = 2;

			Tab["16"] = Instance.new("UIPadding", Tab["14"]);
			Tab["16"]["PaddingTop"] = UDim.new(0, 7);
			Tab["16"]["PaddingRight"] = UDim.new(0, 7);
			Tab["16"]["PaddingLeft"] = UDim.new(0, 7);
			Tab["16"]["PaddingBottom"] = UDim.new(0, 7);

			Tab["17"] = Instance.new("Frame", Tab["14"]);
			Tab["17"]["BorderSizePixel"] = 0;
			Tab["17"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			Tab["17"]["Size"] = UDim2.new(1, 0, 0, 15);
			Tab["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			Tab["17"]["Name"] = [[Subtabs]];
			Tab["17"]["BackgroundTransparency"] = 1;

			Tab["18"] = Instance.new("UIListLayout", Tab["17"]);
			Tab["18"]["Padding"] = UDim.new(0, -1);
			Tab["18"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
			Tab["18"]["FillDirection"] = Enum.FillDirection.Horizontal;
		end

		local function _update_tab_content()
			if Tab.Active then
				Tab["12"].Visible = true
				Tab["10"].TextColor3 = Color3.fromRGB(227, 94, 18)
				Tab["e"].BackgroundColor3 = Color3.fromRGB(34, 34, 34)
				Tab["13"].Visible = true
			else
				Tab["12"].Visible = false
				Tab["10"].TextColor3 = Color3.fromRGB(166, 166, 166)
				Tab["e"].BackgroundColor3 = Color3.fromRGB(47, 47, 47)
				Tab["13"].Visible = false
			end
		end

		local function _update_subtab_size()
			local frames = {}
			for _, v in ipairs(Tab["17"]:GetChildren()) do
				if v:IsA("Frame") then
					table.insert(frames, v)
				end
			end
			local count = #frames
			if count == 0 then return end
			local sizefrac = 1 / count
			for _, v in ipairs(frames) do
				v.Size = UDim2.new(sizefrac, 0, 1, 0)
			end
		end

		function Tab:SetActivated(IsActivated)
			Tab.Active = IsActivated
			_update_tab_content()
			-- Fix: If a tab is activated, ensure its active subtab is also visually refreshed
			if IsActivated and Tab.ActiveSubtab then
				Tab.ActiveSubtab:SetActivated(true)
			end
		end

		Tab["e"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Window:SetTab(Tab)
			end
		end)

		table.insert(Window.Tabs, Tab)

		function Tab:SetSubtab(Subtab)
			if Tab.ActiveSubtab then
				Tab.ActiveSubtab:SetActivated(false)
			end
			if Subtab then
				Tab.ActiveSubtab = Subtab
				Subtab:SetActivated(true)
			end
		end

		function Tab:AddSubtab(Config)
			local Name = Config.Name or "Main"

			local Subtab = {
				Active = false,
				Sections = {}
			}

			do
				Subtab["19"] = Instance.new("Frame", Tab["17"]);
				Subtab["19"]["BorderSizePixel"] = 0;
				Subtab["19"]["BackgroundColor3"] = Color3.fromRGB(47, 47, 47);
				Subtab["19"]["Size"] = UDim2.new(0.5, 0, 1, 0);
				Subtab["19"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Subtab["19"]["Name"] = [[SubButton]];

				Subtab["1a"] = Instance.new("UIStroke", Subtab["19"]);
				Subtab["1a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Subtab["1a"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
				Subtab["1a"]["Thickness"] = 2;

				Subtab["1b"] = Instance.new("TextLabel", Subtab["19"]);
				Subtab["1b"]["TextStrokeTransparency"] = 0;
				Subtab["1b"]["BorderSizePixel"] = 0;
				Subtab["1b"]["TextSize"] = 12;
				Subtab["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Subtab["1b"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
				Subtab["1b"]["TextColor3"] = Color3.fromRGB(166, 166, 166);
				Subtab["1b"]["BackgroundTransparency"] = 1;
				Subtab["1b"]["Size"] = UDim2.new(1, 0, 1, 0);
				Subtab["1b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Subtab["1b"]["Text"] = Name;
				Subtab["1b"]["Name"] = [[Title]];

				Subtab["1c"] = Instance.new("UIPadding", Subtab["1b"]);
				Subtab["1c"]["PaddingBottom"] = UDim.new(0, 3);

				Subtab["21"] = Instance.new("Frame", Tab["14"]);
				Subtab["21"]["BorderSizePixel"] = 0;
				Subtab["21"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Subtab["21"]["Size"] = UDim2.new(1, 0, 1, -29);
				Subtab["21"]["Position"] = UDim2.new(0, 0, 0, 29);
				Subtab["21"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Subtab["21"]["Name"] = [[SubtabContent]];
				Subtab["21"]["BackgroundTransparency"] = 1;
				Subtab["21"].Visible = false

				Subtab["22"] = Instance.new("Frame", Subtab["21"]);
				Subtab["22"]["BorderSizePixel"] = 0;
				Subtab["22"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Subtab["22"]["Size"] = UDim2.new(0.5, 0, 1, 0);
				Subtab["22"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Subtab["22"]["Name"] = [[Left]];
				Subtab["22"]["BackgroundTransparency"] = 1;

				Subtab["23"] = Instance.new("UIListLayout", Subtab["22"]);
				Subtab["23"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

				Subtab["24"] = Instance.new("UIPadding", Subtab["22"]);
				Subtab["24"]["PaddingRight"] = UDim.new(0, 4);
				Subtab["24"]["PaddingLeft"] = UDim.new(0, 4);

				Subtab["5e"] = Instance.new("Frame", Subtab["21"]);
				Subtab["5e"]["BorderSizePixel"] = 0;
				Subtab["5e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Subtab["5e"]["Size"] = UDim2.new(0.5, 0, 1, 0);
				Subtab["5e"]["Position"] = UDim2.new(0.5, 0, 0, 0);
				Subtab["5e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Subtab["5e"]["Name"] = [[Right]];
				Subtab["5e"]["BackgroundTransparency"] = 1;

				Subtab["5f"] = Instance.new("UIListLayout", Subtab["5e"]);
				Subtab["5f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

				Subtab["60"] = Instance.new("UIPadding", Subtab["5e"]);
				Subtab["60"]["PaddingRight"] = UDim.new(0, 4);
				Subtab["60"]["PaddingLeft"] = UDim.new(0, 4);
			end

			local function _update_subtab_content()
				if Subtab.Active and Tab.Active then
					Subtab["19"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 34)
					Subtab["1b"]["TextColor3"] = Color3.fromRGB(227, 94, 18)
					Subtab["21"].Visible = true
				else
					Subtab["19"]["BackgroundColor3"] = Color3.fromRGB(47, 47, 47)
					Subtab["1b"]["TextColor3"] = Color3.fromRGB(166, 166, 166)
					Subtab["21"].Visible = false
				end
			end

			function Subtab:SetActivated(IsActivated)
				Subtab.Active = IsActivated
				_update_subtab_content()
			end

			Subtab["19"].InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Tab:SetSubtab(Subtab)
				end
			end)

			table.insert(Tab.Subtabs, Subtab)

			_update_subtab_size()

			-- Fix: If this is the first subtab added, make it active
			if #Tab.Subtabs == 1 then
				Tab:SetSubtab(Subtab)
			end

			function Subtab:AddSection(Config)
				local Name = Config.Name or "Section"
				local Side = Config.Side or "Left"

				local Section = {
					Elements = {}	
				}

				do
					local SectionParent = Subtab["22"]
					if Side == "Right" then
						SectionParent = Subtab["5e"]
					end

					Section["25"] = Instance.new("Frame", SectionParent);
					Section["25"]["BorderSizePixel"] = 0;
					Section["25"]["BackgroundColor3"] = Color3.fromRGB(29, 29, 29);
					Section["25"]["Size"] = UDim2.new(1, 0, 0, 300);
					Section["25"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					Section["25"]["Name"] = [[Section]];

					Section["26"] = Instance.new("UIStroke", Section["25"]);
					Section["26"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
					Section["26"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
					Section["26"]["Thickness"] = 2;

					Section["27"] = Instance.new("TextLabel", Section["25"]);
					Section["27"]["TextStrokeTransparency"] = 0;
					Section["27"]["BorderSizePixel"] = 0;
					Section["27"]["TextSize"] = 12;
					Section["27"]["TextXAlignment"] = Enum.TextXAlignment.Left;
					Section["27"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
					Section["27"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
					Section["27"]["TextColor3"] = Color3.fromRGB(166, 166, 166);
					Section["27"]["BackgroundTransparency"] = 1;
					Section["27"]["Size"] = UDim2.new(1, 0, 0, 0);
					Section["27"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					Section["27"]["Text"] = Name;
					Section["27"]["Name"] = [[Title]];

					Section["28"] = Instance.new("UIPadding", Section["27"]);
					Section["28"]["PaddingLeft"] = UDim.new(0, 10);
					Section["28"]["PaddingBottom"] = UDim.new(0, 5);

					Section["29"] = Instance.new("Frame", Section["25"]);
					Section["29"]["BorderSizePixel"] = 0;
					Section["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
					Section["29"]["Size"] = UDim2.new(1, 0, 1, 0);
					Section["29"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					Section["29"]["Name"] = [[Content]];
					Section["29"]["BackgroundTransparency"] = 1;

					Section["2a"] = Instance.new("UIListLayout", Section["29"]);
					Section["2a"]["Padding"] = UDim.new(0, 10);
					Section["2a"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

					Section["2b"] = Instance.new("UIPadding", Section["29"]);
					Section["2b"]["PaddingTop"] = UDim.new(0, 10);
					Section["2b"]["PaddingRight"] = UDim.new(0, 10);
					Section["2b"]["PaddingLeft"] = UDim.new(0, 10);
					Section["2b"]["PaddingBottom"] = UDim.new(0, 10);
				end

				local function _update_section_size()
					local absolutesize = 20

					for i,v in ipairs(Section.Elements) do
						absolutesize = absolutesize + v["Main"].Size.Y.Offset + 10
						v["Main"].ZIndex = #Section.Elements - i
					end

					Section["25"].Size = UDim2.new(1, 0, 0, absolutesize - 10)
				end

				_update_section_size()

				local function _build_keybind_ui(parentFrame, Flag, Config, BindForList)
					local DefaultKey    = Config.Default or Enum.KeyCode.L
					local Type          = Config.Type or "Toggle"
					local HideFromList  = Config.ExcludeFromList or false
					local KbName        = Config.Name or "Bind"

					local Keybind = {
						Name           = KbName,
						Value          = false,
						ListeningToKey = false,
						Type           = Type,
						Hovering       = false,
						PopupOpened    = false,
						Key            = DefaultKey
					}

					local kbMain = Instance.new("Frame", parentFrame);
					kbMain["BorderSizePixel"] = 0;
					kbMain["BackgroundColor3"] = Color3.fromRGB(40, 40, 40);
					kbMain["Size"] = UDim2.new(0, 25, 0, 10);
					kbMain["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					kbMain["Name"] = [[Keybind]];
					Keybind["Main"] = kbMain

					local kbStroke = Instance.new("UIStroke", kbMain);
					kbStroke["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
					kbStroke["LineJoinMode"] = Enum.LineJoinMode.Miter;
					kbStroke["Thickness"] = 2;
					Keybind["36"] = kbStroke

					local kbTitle = Instance.new("TextLabel", kbMain);
					kbTitle["TextStrokeTransparency"] = 0;
					kbTitle["BorderSizePixel"] = 0;
					kbTitle["TextSize"] = 10;
					kbTitle["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
					kbTitle["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
					kbTitle["TextColor3"] = Color3.fromRGB(255, 255, 255);
					kbTitle["BackgroundTransparency"] = 1;
					kbTitle["Size"] = UDim2.new(1, 0, 1, 0);
					kbTitle["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					kbTitle["Text"] = SimplifiedKeybinds[DefaultKey.Name] or DefaultKey.Name;
					kbTitle["Name"] = [[Title]];
					Keybind["37"] = kbTitle

					local kbTitlePad = Instance.new("UIPadding", kbTitle);
					kbTitlePad["PaddingBottom"] = UDim.new(0, 2);
					Keybind["38"] = kbTitlePad

					local kbInner = Instance.new("Frame", kbMain);
					kbInner["BorderSizePixel"] = 0;
					kbInner["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
					kbInner["AnchorPoint"] = Vector2.new(0.5, 0.5);
					kbInner["Size"] = UDim2.new(1, -2, 1, -2);
					kbInner["Position"] = UDim2.new(0.5, 0, 0.5, 0);
					kbInner["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					kbInner["Name"] = [[Inner]];
					kbInner["BackgroundTransparency"] = 1;
					Keybind["39"] = kbInner

					local kbInnerStroke = Instance.new("UIStroke", kbInner);
					kbInnerStroke["LineJoinMode"] = Enum.LineJoinMode.Miter;
					kbInnerStroke["Color"] = Color3.fromRGB(29, 29, 29);
					Keybind["3a"] = kbInnerStroke

					-- Popup
					local kbPopup = Instance.new("Frame", kbMain);
					kbPopup["Active"] = true;
					kbPopup["BorderSizePixel"] = 0;
					kbPopup["BackgroundColor3"] = Color3.fromRGB(40, 40, 40);
					kbPopup["Size"] = UDim2.new(0, 50, 0, 32);
					kbPopup["Position"] = UDim2.new(1, 0, 0, 0);
					kbPopup["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					kbPopup["Name"] = [[Popup]];
					kbPopup.Visible = false;
					kbPopup.ZIndex = 20;
					Keybind["3b"] = kbPopup

					local kbPopupInner = Instance.new("Frame", kbPopup);
					kbPopupInner["BorderSizePixel"] = 0;
					kbPopupInner["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
					kbPopupInner["AnchorPoint"] = Vector2.new(0.5, 0.5);
					kbPopupInner["Size"] = UDim2.new(1, -2, 1, -2);
					kbPopupInner["Position"] = UDim2.new(0.5, 0, 0.5, 0);
					kbPopupInner["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					kbPopupInner["Name"] = [[Inner]];
					kbPopupInner["BackgroundTransparency"] = 1;
					Keybind["3c"] = kbPopupInner

					local kbPopupInnerStroke = Instance.new("UIStroke", kbPopupInner);
					kbPopupInnerStroke["LineJoinMode"] = Enum.LineJoinMode.Miter;
					kbPopupInnerStroke["Color"] = Color3.fromRGB(29, 29, 29);
					Keybind["3d"] = kbPopupInnerStroke

					local kbList = Instance.new("UIListLayout", kbPopupInner);
					kbList["SortOrder"] = Enum.SortOrder.LayoutOrder;
					Keybind["3e"] = kbList

					local function makePopupLabel(text, name)
						local lbl = Instance.new("TextLabel", kbPopupInner);
						lbl["TextStrokeTransparency"] = 0;
						lbl["BorderSizePixel"] = 0;
						lbl["TextSize"] = 10;
						lbl["TextXAlignment"] = Enum.TextXAlignment.Left;
						lbl["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						lbl["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
						lbl["TextColor3"] = Color3.fromRGB(255, 255, 255);
						lbl["BackgroundTransparency"] = 1;
						lbl["Size"] = UDim2.new(1, 0, 0, 10);
						lbl["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						lbl["Text"] = text;
						lbl["Name"] = name;
						lbl.ZIndex = 21;
						local pad = Instance.new("UIPadding", lbl);
						pad["PaddingLeft"] = UDim.new(0, 3);
						pad["PaddingBottom"] = UDim.new(0, 2);
						return lbl
					end

					local lblAlways = makePopupLabel("ALWAYS", "Always On")
					local lblToggle = makePopupLabel("TOGGLE", "Toggle")
					local lblHold   = makePopupLabel("HOLD",   "Hold")
					Keybind["3f"] = lblAlways
					Keybind["41"] = lblToggle
					Keybind["43"] = lblHold

					local kbPopupStroke = Instance.new("UIStroke", kbPopup);
					kbPopupStroke["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
					kbPopupStroke["LineJoinMode"] = Enum.LineJoinMode.Miter;
					kbPopupStroke["Thickness"] = 2;
					Keybind["45"] = kbPopupStroke

					local function _refreshTypeHighlight()
						for _, lbl in ipairs({ lblAlways, lblToggle, lblHold }) do
							lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
						end
						local match = kbPopupInner:FindFirstChild(Keybind.Type)
						if match then
							match.TextColor3 = Color3.fromRGB(227, 94, 18)
						end
					end
					_refreshTypeHighlight()

					function Keybind:SetType(T)
						Keybind.Type = T
						_refreshTypeHighlight()
						if BindForList then BindForList:Update(Keybind) end
					end

					kbMain.MouseEnter:Connect(function() Keybind.Hovering = true  end)
					kbMain.MouseLeave:Connect(function() Keybind.Hovering = false end)

					connect(UserInputService.InputBegan, function(input)
						if Library:IsMenuBlocked() then return end
						
						if Keybind.PopupOpened then
							if input.UserInputType == Enum.UserInputType.MouseButton1
								or input.UserInputType == Enum.UserInputType.MouseButton2 then
								local mousePos = UserInputService:GetMouseLocation()
								local absPos   = kbPopup.AbsolutePosition
								local absSize  = kbPopup.AbsoluteSize
								local inside = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
									and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
								if not inside then
									Keybind.PopupOpened = false
									kbPopup.Visible = false
								end
							end
						end

						if Keybind.Hovering
							and input.UserInputType == Enum.UserInputType.MouseButton1
							and not Keybind.ListeningToKey
							and not Keybind.PopupOpened then
							Keybind.ListeningToKey = true
							kbTitle.Text = "..."
							return 
						end

						if Keybind.ListeningToKey
							and input.UserInputType == Enum.UserInputType.Keyboard then
							Keybind.Key = input.KeyCode
							kbTitle.Text = SimplifiedKeybinds[input.KeyCode.Name] or input.KeyCode.Name
							Keybind.ListeningToKey = false
							if BindForList then BindForList:Update(Keybind) end
							return
						end

						if Keybind.Hovering
							and input.UserInputType == Enum.UserInputType.MouseButton2
							and not Keybind.ListeningToKey then
							Keybind.PopupOpened = true
							kbPopup.Visible = true
							return
						end

						if not Keybind.ListeningToKey and not Keybind.PopupOpened then
							if input.KeyCode == Keybind.Key then
								if Keybind.Type == "Always On" then
									Keybind.Value = true
								elseif Keybind.Type == "Toggle" then
									Keybind.Value = not Keybind.Value
								elseif Keybind.Type == "Hold" then
									Keybind.Value = true
								end
								if BindForList then BindForList:Update(Keybind) end
							end
						end
					end)

					connect(UserInputService.InputEnded, function(input)
						if Keybind.Type == "Hold" and input.KeyCode == Keybind.Key then
							Keybind.Value = false
							if BindForList then BindForList:Update(Keybind) end
						end
					end)

					lblAlways.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Keybind:SetType("Always On")
							Keybind.Value = true
							Keybind.PopupOpened = false
							kbPopup.Visible = false
							if BindForList then BindForList:Update(Keybind) end
						end
					end)
					lblToggle.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Keybind:SetType("Toggle")
							Keybind.PopupOpened = false
							kbPopup.Visible = false
						end
					end)
					lblHold.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Keybind:SetType("Hold")
							Keybind.PopupOpened = false
							kbPopup.Visible = false
						end
					end)

					if not HideFromList then
						table.insert(Library.Binds, Keybind)
					end
					Library.Flags[Flag] = Keybind

					return Keybind
				end

				function Section:AddCheckbox(Flag, Config)
					local Name    = Config.Name    or "Checkbox"
					local Default = Config.Default or false

					local Checkbox = {
						Value    = Default,
						Default  = Default,
						Callback = Config.Callback
					}				

					do
						Checkbox["Main"] = Instance.new("Frame", Section["29"]);
						Checkbox["Main"]["BorderSizePixel"] = 0;
						Checkbox["Main"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Checkbox["Main"]["Size"] = UDim2.new(1, 0, 0, 10);
						Checkbox["Main"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Checkbox["Main"]["Name"] = [[Checkbox]];
						Checkbox["Main"]["BackgroundTransparency"] = 1;

						Checkbox["2d"] = Instance.new("TextLabel", Checkbox["Main"]);
						Checkbox["2d"]["TextStrokeTransparency"] = 0;
						Checkbox["2d"]["BorderSizePixel"] = 0;
						Checkbox["2d"]["TextSize"] = 12;
						Checkbox["2d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
						Checkbox["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Checkbox["2d"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
						Checkbox["2d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
						Checkbox["2d"]["BackgroundTransparency"] = 1;
						Checkbox["2d"]["Size"] = UDim2.new(1, 0, 1, 0);
						Checkbox["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Checkbox["2d"]["Text"] = Name;
						Checkbox["2d"]["Name"] = "";

						Checkbox["2e"] = Instance.new("UIPadding", Checkbox["2d"]);
						Checkbox["2e"]["PaddingLeft"] = UDim.new(0, 20);
						Checkbox["2e"]["PaddingBottom"] = UDim.new(0, 2);

						Checkbox["2f"] = Instance.new("Frame", Checkbox["Main"]);
						Checkbox["2f"]["BorderSizePixel"] = 0;
						Checkbox["2f"]["BackgroundColor3"] = Color3.fromRGB(227, 94, 18);
						Checkbox["2f"]["Size"] = UDim2.new(0, 10, 0, 10);
						Checkbox["2f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Checkbox["2f"]["Name"] = [[Box]];

						Checkbox["30"] = Instance.new("UIStroke", Checkbox["2f"]);
						Checkbox["30"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
						Checkbox["30"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
						Checkbox["30"]["Thickness"] = 2;

						Checkbox["31"] = Instance.new("Frame", Checkbox["2f"]);
						Checkbox["31"]["BorderSizePixel"] = 0;
						Checkbox["31"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Checkbox["31"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
						Checkbox["31"]["Size"] = UDim2.new(1, -2, 1, -2);
						Checkbox["31"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
						Checkbox["31"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Checkbox["31"]["Name"] = [[Inner]];
						Checkbox["31"]["BackgroundTransparency"] = 1;

						Checkbox["32"] = Instance.new("UIStroke", Checkbox["31"]);
						Checkbox["32"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
						Checkbox["32"]["Color"] = Color3.fromRGB(157, 63, 10);

						Checkbox["33"] = Instance.new("Frame", Checkbox["Main"]);
						Checkbox["33"]["BorderSizePixel"] = 0;
						Checkbox["33"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Checkbox["33"]["AnchorPoint"] = Vector2.new(1, 0);
						Checkbox["33"]["Size"] = UDim2.new(1, 0, 0, 10);
						Checkbox["33"]["Position"] = UDim2.new(1, 0, 0, 0);
						Checkbox["33"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Checkbox["33"]["Name"] = [[Keybinds]];
						Checkbox["33"]["BackgroundTransparency"] = 1;

						Checkbox["34"] = Instance.new("UIListLayout", Checkbox["33"]);
						Checkbox["34"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Right;
						Checkbox["34"]["Padding"] = UDim.new(0, 5);
						Checkbox["34"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
						Checkbox["34"]["FillDirection"] = Enum.FillDirection.Horizontal;
					end

					local function _update_checkbox_color()
						if Checkbox.Value then
							Checkbox["2f"]["BackgroundColor3"] = Color3.fromRGB(227, 94, 18);
							Checkbox["31"].Visible = true
						else
							Checkbox["2f"]["BackgroundColor3"] = Color3.fromRGB(14, 14, 14);
							Checkbox["31"].Visible = false
						end
					end

					_update_checkbox_color()

					Checkbox["2f"].InputBegan:Connect(function(input)
						if Library:IsMenuBlocked() then return end -- BLOCK INPUT
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Checkbox.Value = not Checkbox.Value
							_update_checkbox_color()
							if Checkbox.Callback then
								Checkbox.Callback(Checkbox.Value)
							end
						end
					end)

					Library.Flags[Flag] = Checkbox

					table.insert(Section.Elements, Checkbox)
					_update_section_size()

					function Checkbox:AddKeybind(Flag, Config)
						local bindForList = Library.KeybindsList:AddBind({ Name = Config.Name or "Bind", Type = Config.Type or "Toggle", Key = Config.Default or Enum.KeyCode.L, Value = false })
						return _build_keybind_ui(Checkbox["33"], Flag, Config, bindForList)
					end

					function Checkbox:AddColorpicker(Flag, Config)
						local CpName  = Config.Name    or "Colorpicker"
						local Default = Config.Default or Color3.new(1, 1, 1)

						local ColorOption = {
							Color        = Default,
							Name         = CpName,
							Transparency = 0,
							Callback     = Config.Callback or nil,
						}

						-- CHANGED: Use TextButton to guarantee click detection
						local cpFrame = Instance.new("TextButton", Checkbox["33"])
						cpFrame["BorderSizePixel"] = 0
						cpFrame["BackgroundColor3"] = ColorOption.Color
						cpFrame["Size"] = UDim2.new(0, 25, 0, 10)
						cpFrame["BorderColor3"] = Color3.fromRGB(0, 0, 0)
						cpFrame["Name"] = [[Colorpicker]]
						cpFrame["Text"] = ""
						cpFrame["AutoButtonColor"] = false
						ColorOption["35"] = cpFrame

						local cpStroke = Instance.new("UIStroke", cpFrame)
						cpStroke["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border
						cpStroke["LineJoinMode"] = Enum.LineJoinMode.Miter
						cpStroke["Thickness"] = 2
						ColorOption["36"] = cpStroke

						local cpInner = Instance.new("Frame", cpFrame)
						cpInner["BorderSizePixel"] = 0
						cpInner["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
						cpInner["AnchorPoint"] = Vector2.new(0.5, 0.5)
						cpInner["Size"] = UDim2.new(1, -2, 1, -2)
						cpInner["Position"] = UDim2.new(0.5, 0, 0.5, 0)
						cpInner["BorderColor3"] = Color3.fromRGB(0, 0, 0)
						cpInner["Name"] = [[Inner]]
						cpInner["BackgroundTransparency"] = 1
						ColorOption["37"] = cpInner

						local cpInnerStroke = Instance.new("UIStroke", cpInner)
						cpInnerStroke["LineJoinMode"] = Enum.LineJoinMode.Miter
						cpInnerStroke["Color"] = Color3.fromRGB(109, 115, 206)
						ColorOption["38"] = cpInnerStroke

						cpFrame.MouseButton1Click:Connect(function()
							if Library:IsMenuBlocked() and not Window.PickerController["7d"].Visible then return end
							
							ColorOption._AbsolutePosition = cpFrame.AbsolutePosition
							ColorOption._AbsoluteSize     = cpFrame.AbsoluteSize

							ColorOption.Callback = function(newColor, newTransparency)
								ColorOption.Color        = newColor
								ColorOption.Transparency = newTransparency
								cpFrame.BackgroundColor3 = newColor
								
								ColorOption._AbsolutePosition = cpFrame.AbsolutePosition
								ColorOption._AbsoluteSize     = cpFrame.AbsoluteSize
								ColorOption._WidgetButton     = cpFrame -- Store reference for dynamic stroke
								if Config.Callback then Config.Callback(newColor, newTransparency) end
							end

							Window.PickerController:LoadPicker(ColorOption)
							Window.PickerController:SetVisible(true)
						end)

						Library.Flags[Flag] = ColorOption
						return ColorOption
					end

					return Checkbox
				end

				function Section:AddLabel(Config)
					local Name = Config.Name or "Label"

					local Label = {}

					do
						Label["Main"] = Instance.new("Frame", Section["29"]);
						Label["Main"]["BorderSizePixel"] = 0;
						Label["Main"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Label["Main"]["Size"] = UDim2.new(1, 0, 0, 10);
						Label["Main"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Label["Main"]["Name"] = [[Label]];
						Label["Main"]["BackgroundTransparency"] = 1;

						Label["2d"] = Instance.new("TextLabel", Label["Main"]);
						Label["2d"]["TextStrokeTransparency"] = 0;
						Label["2d"]["BorderSizePixel"] = 0;
						Label["2d"]["TextSize"] = 12;
						Label["2d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
						Label["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Label["2d"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
						Label["2d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
						Label["2d"]["BackgroundTransparency"] = 1;
						Label["2d"]["Size"] = UDim2.new(1, 0, 1, 0);
						Label["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Label["2d"]["Text"] = Name;
						Label["2d"]["Name"] = "";

						Label["2e"] = Instance.new("UIPadding", Label["2d"]);
						Label["2e"]["PaddingLeft"] = UDim.new(0, 20);
						Label["2e"]["PaddingBottom"] = UDim.new(0, 2);

						Label["33"] = Instance.new("Frame", Label["Main"]);
						Label["33"]["BorderSizePixel"] = 0;
						Label["33"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Label["33"]["AnchorPoint"] = Vector2.new(1, 0);
						Label["33"]["Size"] = UDim2.new(1, 0, 0, 10);
						Label["33"]["Position"] = UDim2.new(1, 0, 0, 0);
						Label["33"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Label["33"]["Name"] = [[Keybinds]];
						Label["33"]["BackgroundTransparency"] = 1;

						Label["34"] = Instance.new("UIListLayout", Label["33"]);
						Label["34"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Right;
						Label["34"]["Padding"] = UDim.new(0, 5);
						Label["34"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
						Label["34"]["FillDirection"] = Enum.FillDirection.Horizontal;
					end

					table.insert(Section.Elements, Label)
					_update_section_size()

					function Label:AddKeybind(Flag, Config)
						local bindForList = Library.KeybindsList:AddBind({ Name = Config.Name or "Bind", Type = Config.Type or "Toggle", Key = Config.Default or Enum.KeyCode.L, Value = false })
						return _build_keybind_ui(Label["33"], Flag, Config, bindForList)
					end

					return Label
				end

				function Section:AddSlider(Flag, Config)
					local Name    = Config.Name    or "Slider"
					local Min     = Config.Min     or 0
					local Max     = Config.Max     or 100
					local Default = Config.Default or Min
					local Format  = Config.Format  or "%i"

					Default = math.clamp(Default, Min, Max)

					local Slider = {
						Value    = Default,
						Dragging = false,
						Min      = Min,
						Max      = Max,
						Callback = Config.Callback,
					}

					Slider["Main"] = Instance.new("Frame")
					Slider["Main"].BorderSizePixel = 0
					Slider["Main"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Slider["Main"].Size = UDim2.new(1, 0, 0, 25)
					Slider["Main"].BorderColor3 = Color3.fromRGB(0, 0, 0)
					Slider["Main"].Name = "Slider"
					Slider["Main"].BackgroundTransparency = 1
					Slider["Main"].Parent = Section["29"]

					local TitleLabel = Instance.new("TextLabel")
					TitleLabel.TextStrokeTransparency = 0
					TitleLabel.BorderSizePixel = 0
					TitleLabel.TextSize = 12
					TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
					TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					TitleLabel.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					TitleLabel.BackgroundTransparency = 1
					TitleLabel.Size = UDim2.new(1, 0, 0, 10)
					TitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					TitleLabel.Text = Name
					TitleLabel.Name = "Title"
					TitleLabel.Parent = Slider["Main"]

					local TitlePadding = Instance.new("UIPadding")
					TitlePadding.PaddingLeft = UDim.new(0, 20)
					TitlePadding.PaddingBottom = UDim.new(0, 2)
					TitlePadding.Parent = TitleLabel

					local BarFrame = Instance.new("Frame")
					BarFrame.BorderSizePixel = 0
					BarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					BarFrame.Size = UDim2.new(1, -30, 0, 7)
					BarFrame.Position = UDim2.new(0, 20, 0, 15)
					BarFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					BarFrame.Name = "Bar"
					BarFrame.Parent = Slider["Main"]

					local BarStroke = Instance.new("UIStroke")
					BarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					BarStroke.LineJoinMode = Enum.LineJoinMode.Miter
					BarStroke.Thickness = 2
					BarStroke.Parent = BarFrame

					local MinusLabel = Instance.new("TextLabel")
					MinusLabel.Active = true
					MinusLabel.TextStrokeTransparency = 0
					MinusLabel.BorderSizePixel = 0
					MinusLabel.TextXAlignment = Enum.TextXAlignment.Left
					MinusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					MinusLabel.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					MinusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					MinusLabel.BackgroundTransparency = 1
					MinusLabel.AnchorPoint = Vector2.new(1, 0)
					MinusLabel.Size = UDim2.new(0, 7, 0, 7)
					MinusLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					MinusLabel.Text = "-"
					MinusLabel.Name = "-"
					MinusLabel.Position = UDim2.new(0, -2, 0, 0)
					MinusLabel.Parent = BarFrame

					local MinusPadding = Instance.new("UIPadding")
					MinusPadding.PaddingBottom = UDim.new(0, 1)
					MinusPadding.Parent = MinusLabel

					local PlusLabel = Instance.new("TextLabel")
					PlusLabel.Active = true
					PlusLabel.TextStrokeTransparency = 0
					PlusLabel.BorderSizePixel = 0
					PlusLabel.TextXAlignment = Enum.TextXAlignment.Right
					PlusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					PlusLabel.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					PlusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					PlusLabel.BackgroundTransparency = 1
					PlusLabel.Size = UDim2.new(0, 7, 0, 7)
					PlusLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
					PlusLabel.Text = "+"
					PlusLabel.Name = "+"
					PlusLabel.Position = UDim2.new(1, 3, 0, 0)
					PlusLabel.Parent = BarFrame

					local PlusPadding = Instance.new("UIPadding")
					PlusPadding.PaddingBottom = UDim.new(0, 1)
					PlusPadding.Parent = PlusLabel

					local FilledFrame = Instance.new("Frame")
					FilledFrame.BorderSizePixel = 0
					FilledFrame.BackgroundColor3 = Color3.fromRGB(227, 94, 18)
					FilledFrame.Size = UDim2.new(0.6, 0, 1, 0)
					FilledFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					FilledFrame.Name = "Filled"
					FilledFrame.Parent = BarFrame

					local InnerFrame = Instance.new("Frame")
					InnerFrame.BorderSizePixel = 0
					InnerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					InnerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
					InnerFrame.Size = UDim2.new(1, -2, 1, -2)
					InnerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
					InnerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					InnerFrame.Name = "Inner"
					InnerFrame.BackgroundTransparency = 1
					InnerFrame.Parent = FilledFrame

					local InnerStroke = Instance.new("UIStroke")
					InnerStroke.LineJoinMode = Enum.LineJoinMode.Miter
					InnerStroke.Color = Color3.fromRGB(157, 63, 10)
					InnerStroke.Parent = InnerFrame

					local FilledTitle = Instance.new("TextLabel")
					FilledTitle.TextStrokeTransparency = 0
					FilledTitle.BorderSizePixel = 0
					FilledTitle.TextSize = 12
					FilledTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					FilledTitle.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					FilledTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					FilledTitle.BackgroundTransparency = 1
					FilledTitle.AnchorPoint = Vector2.new(0.5, 0)
					FilledTitle.Size = UDim2.new(0, 30, 1, 0)
					FilledTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
					FilledTitle.Text = "60%"
					FilledTitle.Name = "Title"
					FilledTitle.Position = UDim2.new(1, 0, 0, 0)
					FilledTitle.Parent = FilledFrame

					local FilledPadding = Instance.new("UIPadding")
					FilledPadding.PaddingBottom = UDim.new(0, -5)
					FilledPadding.Parent = FilledTitle

					local function UpdateSlider(Value)
						Slider.Value = math.clamp(Value, Slider.Min, Slider.Max)
						local range = Slider.Max - Slider.Min
						local Percent = range > 0 and (Slider.Value - Slider.Min) / range or 0
						FilledFrame.Size = UDim2.new(Percent, 0, 1, 0)
						FilledTitle.Text = string.format(Format, Slider.Value)
						if Slider.Callback then
							Slider.Callback(Slider.Value)
						end
					end

					BarFrame.InputBegan:Connect(function(input)
						if Library:IsMenuBlocked() then return end
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Slider.Dragging = true
							local MouseX = input.Position.X
							local BarAbsolutePosition = BarFrame.AbsolutePosition.X
							local BarAbsoluteSize = BarFrame.AbsoluteSize.X
							local RelativeX = math.clamp(MouseX - BarAbsolutePosition, 0, BarAbsoluteSize)
							local Percent = BarAbsoluteSize > 0 and RelativeX / BarAbsoluteSize or 0
							UpdateSlider(Slider.Min + (Slider.Max - Slider.Min) * Percent)
						end
					end)

					BarFrame.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Slider.Dragging = false
						end
					end)

					connect(UserInputService.InputChanged, function(input)
						if Slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
							local MouseX = input.Position.X
							local BarAbsolutePosition = BarFrame.AbsolutePosition.X
							local BarAbsoluteSize = BarFrame.AbsoluteSize.X
							local RelativeX = math.clamp(MouseX - BarAbsolutePosition, 0, BarAbsoluteSize)
							local Percent = BarAbsoluteSize > 0 and RelativeX / BarAbsoluteSize or 0
							UpdateSlider(Slider.Min + (Slider.Max - Slider.Min) * Percent)
						end
					end)

					MinusLabel.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Slider:Set(math.clamp(Slider.Value - 1, Min, Max))
						end
					end)

					PlusLabel.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Slider:Set(math.clamp(Slider.Value + 1, Min, Max))
						end
					end)

					function Slider:Set(Value)
						UpdateSlider(Value)
					end

					UpdateSlider(Default)

					table.insert(Section.Elements, Slider)
					_update_section_size()

					Library.Flags[Flag] = Slider

					return Slider
				end

				function Section:AddDropdown(Flag, Config)
					local Name      = Config.Name    or "Dropdown"
					local IsMulti   = Config.Multi   or false
					local Values    = Config.Values  or {}
					local Default   = Config.Default or 1

					local Dropdown = {
						Value                    = IsMulti and {} or Values[Default] or nil,
						IsOpened                 = false,
						CurrentlySelectedObjects = IsMulti and {} or nil,
						Callback                 = Config.Callback,
					}

					do
						Dropdown["Main"] = Instance.new("Frame", Section["29"]);
						Dropdown["Main"]["BorderSizePixel"] = 0;
						Dropdown["Main"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Dropdown["Main"]["Size"] = UDim2.new(1, 0, 0, 25);
						Dropdown["Main"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Dropdown["Main"]["Name"] = [[Dropdown]];
						Dropdown["Main"]["BackgroundTransparency"] = 1;

						Dropdown["5f"] = Instance.new("TextLabel", Dropdown["Main"]);
						Dropdown["5f"]["TextStrokeTransparency"] = 0;
						Dropdown["5f"]["BorderSizePixel"] = 0;
						Dropdown["5f"]["TextSize"] = 12;
						Dropdown["5f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
						Dropdown["5f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Dropdown["5f"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
						Dropdown["5f"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
						Dropdown["5f"]["BackgroundTransparency"] = 1;
						Dropdown["5f"]["Size"] = UDim2.new(1, 0, 0, 10);
						Dropdown["5f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Dropdown["5f"]["Text"] = Name;
						Dropdown["5f"]["Name"] = [[Title]];

						Dropdown["60"] = Instance.new("UIPadding", Dropdown["5f"]);
						Dropdown["60"]["PaddingLeft"] = UDim.new(0, 20);
						Dropdown["60"]["PaddingBottom"] = UDim.new(0, 2);

						Dropdown["61"] = Instance.new("Frame", Dropdown["Main"]);
						Dropdown["61"]["BorderSizePixel"] = 0;
						Dropdown["61"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 34);
						Dropdown["61"]["Size"] = UDim2.new(1, -30, 0, 11);
						Dropdown["61"]["Position"] = UDim2.new(0, 20, 0, 15);
						Dropdown["61"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Dropdown["61"]["Name"] = [[dropdown]];

						Dropdown["62"] = Instance.new("UIStroke", Dropdown["61"]);
						Dropdown["62"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
						Dropdown["62"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

						Dropdown["63"] = Instance.new("TextLabel", Dropdown["61"]);
						Dropdown["63"]["TextStrokeTransparency"] = 0;
						Dropdown["63"]["BorderSizePixel"] = 0;
						Dropdown["63"]["TextSize"] = 10;
						Dropdown["63"]["TextXAlignment"] = Enum.TextXAlignment.Left;
						Dropdown["63"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Dropdown["63"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
						Dropdown["63"]["TextColor3"] = Color3.fromRGB(166, 166, 166);
						Dropdown["63"]["BackgroundTransparency"] = 1;
						Dropdown["63"]["Size"] = UDim2.new(1, 0, 0, 10);
						Dropdown["63"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Dropdown["63"]["Text"] = [[Head]];
						Dropdown["63"]["Name"] = [[Selected]];
						Dropdown["63"].TextTruncate = Enum.TextTruncate.AtEnd

						Dropdown["64"] = Instance.new("UIPadding", Dropdown["63"]);
						Dropdown["64"]["PaddingLeft"] = UDim.new(0, 5);
						Dropdown["64"]["PaddingBottom"] = UDim.new(0, 2);

						Dropdown["65"] = Instance.new("Frame", Dropdown["61"]);
						Dropdown["65"]["BorderSizePixel"] = 0;
						Dropdown["65"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Dropdown["65"]["AnchorPoint"] = Vector2.new(1, 0);
						Dropdown["65"]["Size"] = UDim2.new(0, 11, 0, 11);
						Dropdown["65"]["Position"] = UDim2.new(1, 0, 0, 0);
						Dropdown["65"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Dropdown["65"]["Name"] = [[_]];
						Dropdown["65"]["BackgroundTransparency"] = 1;

						Dropdown["66"] = Instance.new("ImageLabel", Dropdown["65"]);
						Dropdown["66"]["BorderSizePixel"] = 0;
						Dropdown["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Dropdown["66"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
						Dropdown["66"]["Image"] = [[rbxassetid://18330279950]];
						Dropdown["66"]["Size"] = UDim2.new(1, -3, 1, -3);
						Dropdown["66"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Dropdown["66"]["BackgroundTransparency"] = 1;
						Dropdown["66"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

						Dropdown["67"] = Instance.new("Frame", Dropdown["61"]);
						Dropdown["67"]["BorderSizePixel"] = 0;
						Dropdown["67"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 34);
						Dropdown["67"]["Size"] = UDim2.new(1, 0, 0, 20);
						Dropdown["67"]["Position"] = UDim2.new(0, 0, 1, 0);
						Dropdown["67"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Dropdown["67"]["Name"] = [[Actualdown]];
						Dropdown["67"].Visible = false
						Dropdown["67"].ZIndex = 10

						Dropdown["68"] = Instance.new("UIStroke", Dropdown["67"]);
						Dropdown["68"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
						Dropdown["68"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

						Dropdown["69"] = Instance.new("UIListLayout", Dropdown["67"]);
						Dropdown["69"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
					end

					local function update_selected_value(item, value)
						if IsMulti then
							if item.Selected then
								table.insert(Dropdown.Value, value)
							else
								for i, v in ipairs(Dropdown.Value) do
									if v == value then
										table.remove(Dropdown.Value, i)
										break
									end
								end
							end
						else
							Dropdown.Value = value
						end
					end

					local function _update_selected_dropdown_text()
						local res = ""
						if IsMulti then
							for i, v in ipairs(Dropdown.Value) do
								res = res .. v .. ", "
							end
							if res ~= "" then
								res = string.sub(res, 1, -3) 
							end
						else
							res = tostring(Dropdown.Value)
						end
						Dropdown["63"].Text = res
					end

					local function update_item_color(item)
						if item.Selected then
							item["6c"]["TextColor3"] = Color3.fromRGB(227, 94, 18)
						else
							item["6c"]["TextColor3"] = Color3.fromRGB(166, 166, 166)
						end
					end

					local function handle_item_selection(item, value)
						if IsMulti then
							item.Selected = not item.Selected
							update_selected_value(item, value)
							update_item_color(item)
						else
							if Dropdown.CurrentlySelectedObjects then
								Dropdown.CurrentlySelectedObjects:SetActivated(false)
							end
							Dropdown.CurrentlySelectedObjects = item
							item.Selected = true
							update_selected_value(item, value)
							update_item_color(item)
						end
						_update_selected_dropdown_text()
						if Dropdown.Callback then
							Dropdown.Callback(Dropdown.Value)
						end
					end

					function Dropdown:AddItem(Value)
						local Item = { Selected = false }

						Item["6c"] = Instance.new("TextLabel", Dropdown["67"])
						Item["6c"]["TextStrokeTransparency"] = 0
						Item["6c"]["BorderSizePixel"] = 0
						Item["6c"]["TextSize"] = 10
						Item["6c"]["TextXAlignment"] = Enum.TextXAlignment.Left
						Item["6c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
						Item["6c"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
						Item["6c"]["TextColor3"] = Color3.fromRGB(166, 166, 166)
						Item["6c"]["BackgroundTransparency"] = 1
						Item["6c"]["Size"] = UDim2.new(1, 0, 0, 10)
						Item["6c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0)
						Item["6c"]["Text"] = Value
						Item["6c"]["Name"] = [[Unselected]]

						Item["6d"] = Instance.new("UIPadding", Item["6c"])
						Item["6d"]["PaddingLeft"] = UDim.new(0, 5)
						Item["6d"]["PaddingBottom"] = UDim.new(0, 2)

						function Item:SetActivated(IsActivated)
							Item.Selected = IsActivated
							update_item_color(Item)
						end

						Item["6c"].InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								handle_item_selection(Item, Value)
								-- Single-select dropdowns close after a choice is made;
								-- otherwise they stay open and IsMenuBlocked blocks the rest of the UI.
								if not IsMulti then
									Dropdown.IsOpened = false
									Dropdown["67"].Visible = false
								end
							end
						end)

						return Item
					end

					local function update_dropdown_size()
						local sizey = 0
						for i, v in ipairs(Dropdown["67"]:GetChildren()) do
							if v:IsA("TextLabel") then
								sizey = sizey + v.Size.Y.Offset
							end
						end
						Dropdown["67"]["Size"] = UDim2.new(1, 0, 0, sizey)
					end

					local function update_dropdown_opening()
						Dropdown["67"].Visible = Dropdown.IsOpened
					end

					Dropdown["61"].InputBegan:Connect(function(input)
						if Window.PickerController["7d"].Visible then return end 

						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							Dropdown.IsOpened = not Dropdown.IsOpened
							update_dropdown_opening()
						end
					end)

					for i, value in ipairs(Values) do
						local item = Dropdown:AddItem(value)
						if i == Default then
							handle_item_selection(item, value)
						end
						update_dropdown_size()
					end

					table.insert(Section.Elements, Dropdown)
					_update_section_size()

					Library.Flags[Flag] = Dropdown

					return Dropdown
				end

				function Section:AddInput(Flag, Config)
					local Name     = Config.Name     or "Input"
					local Callback = Config.Callback or function() end
					local Input    = { Value = "" }

					do
						Input["Main"] = Instance.new("Frame", Section["29"]);
						Input["Main"]["BorderSizePixel"] = 0;
						Input["Main"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
						Input["Main"]["Size"] = UDim2.new(1, 0, 0, 10);
						Input["Main"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Input["Main"]["Name"] = [[Textbox]];
						Input["Main"]["BackgroundTransparency"] = 1;

						Input["73"] = Instance.new("TextBox", Input["Main"]);
						Input["73"]["Active"] = true;
						Input["73"]["TextStrokeTransparency"] = 0;
						Input["73"]["Name"] = [[text]];
						Input["73"]["TextXAlignment"] = Enum.TextXAlignment.Left;
						Input["73"]["PlaceholderColor3"] = Color3.fromRGB(166, 166, 166);
						Input["73"]["BorderSizePixel"] = 0;
						Input["73"]["TextSize"] = 10;
						Input["73"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
						Input["73"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 34);
						Input["73"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
						Input["73"]["Selectable"] = true;
						Input["73"]["PlaceholderText"] = Name;
						Input["73"]["Size"] = UDim2.new(1, -30, 1, 0);
						Input["73"]["Position"] = UDim2.new(0, 20, 0, 0);
						Input["73"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
						Input["73"]["Text"] = Input.Value;
						Input["73"].ClipsDescendants = true

						Input["74"] = Instance.new("UIStroke", Input["73"]);
						Input["74"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
						Input["74"]["LineJoinMode"] = Enum.LineJoinMode.Miter;

						Input["75"] = Instance.new("UIPadding", Input["73"]);
						Input["75"]["PaddingLeft"] = UDim.new(0, 5);
						Input["75"]["PaddingBottom"] = UDim.new(0, 2);
					end

					Input["73"]:GetPropertyChangedSignal("Text"):Connect(function()
						Input.Value = Input["73"].Text
						Callback(Input.Value)
					end)

					Library.Flags[Flag] = Input

					table.insert(Section.Elements, Input)
					_update_section_size()

					return Input
				end

				return Section
			end

			return Subtab
		end

		-- Fix: Automatically select first tab created
		if #Window.Tabs == 1 then
			task.spawn(function()
				Window:SetTab(Tab)
			end)
		end

		return Tab
	end

	return Window
end


function Library:Unload()
	if self.Disposed then
		return
	end
	self.Disposed = true
	self.Opened = false

	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	table.clear(self.Connections)

	if self["1"] then
		self["1"]:Destroy()
		self["1"] = nil
	end
	self.MainWindow = nil
	self.Window = nil

	if env and env.DeadlinesUI == self then
		env.DeadlinesUI = nil
	end
end
Library.unload = Library.Unload

-- hacky
function Library:IsMenuBlocked()
	if self.Disposed then
		return true
	end
	-- Check if Colorpicker is open
	if self.Window and self.Window.PickerController and self.Window.PickerController["7d"].Visible then
		return true
	end
	-- Check if any dropdown is open
	for _, flag in pairs(self.Flags) do
		if flag.IsOpened then return true end
	end
	return false
end

function Library:CreateKeybindsList()
	local Keybinds = {
		Pos = UDim2.new(0, 10, 0, 200)
	}

	do
		Keybinds["71"] = Instance.new("Frame", Library["1"]);
		Keybinds["71"]["BorderSizePixel"] = 0;
		Keybinds["71"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		Keybinds["71"]["Size"] = UDim2.new(0, 258, 0, 78);
		Keybinds["71"]["Position"] = UDim2.new(0.78862, 0, 0.32561, 0);
		Keybinds["71"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Keybinds["71"]["Name"] = [[KeybindsList]];

		Keybinds["72"] = Instance.new("UIStroke", Keybinds["71"]);
		Keybinds["72"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
		Keybinds["72"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
		Keybinds["72"]["Thickness"] = 2;
		Keybinds["72"]["Color"] = Color3.fromRGB(71, 71, 71);

		Keybinds["73"] = Instance.new("Frame", Keybinds["71"]);
		Keybinds["73"]["BorderSizePixel"] = 0;
		Keybinds["73"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Keybinds["73"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
		Keybinds["73"]["Size"] = UDim2.new(1, -10, 1, -10);
		Keybinds["73"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
		Keybinds["73"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Keybinds["73"]["Name"] = [[Inner]];
		Keybinds["73"]["BackgroundTransparency"] = 1;

		Keybinds["74"] = Instance.new("Frame", Keybinds["73"]);
		Keybinds["74"]["ZIndex"] = 2;
		Keybinds["74"]["BorderSizePixel"] = 0;
		Keybinds["74"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Keybinds["74"]["Size"] = UDim2.new(1, 0, 0, 15);
		Keybinds["74"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Keybinds["74"]["Name"] = [[Top]];
		Keybinds["74"]["BackgroundTransparency"] = 1;

		Keybinds["75"] = Instance.new("TextLabel", Keybinds["74"]);
		Keybinds["75"]["TextStrokeTransparency"] = 0;
		Keybinds["75"]["BorderSizePixel"] = 0;
		Keybinds["75"]["TextSize"] = 12;
		Keybinds["75"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		Keybinds["75"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Keybinds["75"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		Keybinds["75"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
		Keybinds["75"]["BackgroundTransparency"] = 1;
		Keybinds["75"]["RichText"] = true;
		Keybinds["75"]["Size"] = UDim2.new(1, 0, 1, 0);
		Keybinds["75"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Keybinds["75"]["Text"] = [[Key<font color="#e25d11">binds</font>]];
		Keybinds["75"]["Name"] = [[Title]];

		Keybinds["76"] = Instance.new("UIPadding", Keybinds["75"]);
		Keybinds["76"]["PaddingLeft"] = UDim.new(0, 3);
		Keybinds["76"]["PaddingBottom"] = UDim.new(0, 8);

		Keybinds["77"] = Instance.new("Frame", Keybinds["73"]);
		Keybinds["77"]["BorderSizePixel"] = 0;
		Keybinds["77"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Keybinds["77"]["Size"] = UDim2.new(1, 0, 1, -15);
		Keybinds["77"]["Position"] = UDim2.new(0, 0, 0, 15);
		Keybinds["77"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Keybinds["77"]["Name"] = [[Content]];
		Keybinds["77"]["BackgroundTransparency"] = 1;

		Keybinds["78"] = Instance.new("Frame", Keybinds["77"]);
		Keybinds["78"]["BorderSizePixel"] = 0;
		Keybinds["78"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 34);
		Keybinds["78"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
		Keybinds["78"]["Size"] = UDim2.new(1, -4, 1, -4);
		Keybinds["78"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
		Keybinds["78"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Keybinds["78"]["Name"] = [[Inner]];

		Keybinds["79"] = Instance.new("UIStroke", Keybinds["78"]);
		Keybinds["79"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
		Keybinds["79"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
		Keybinds["79"]["Thickness"] = 2;

		Keybinds["7a"] = Instance.new("UIPadding", Keybinds["78"]);
		Keybinds["7a"]["PaddingTop"] = UDim.new(0, 7);
		Keybinds["7a"]["PaddingRight"] = UDim.new(0, 7);
		Keybinds["7a"]["PaddingLeft"] = UDim.new(0, 7);
		Keybinds["7a"]["PaddingBottom"] = UDim.new(0, 7);

		Keybinds["7b"] = Instance.new("UIListLayout", Keybinds["78"]);
		Keybinds["7b"]["Padding"] = UDim.new(0, 5);
		Keybinds["7b"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
	end

	-- Make KeybindsList draggable only when menu is open
	EnableDragging(Keybinds["71"], Keybinds["71"], true)

	local function _update_size()
		local totalHeight = 23 
		for _, child in pairs(Keybinds["78"]:GetChildren()) do
			if child:IsA("Frame") and child.Name == "BindActive" then
				totalHeight = totalHeight + child.Size.Y.Offset + Keybinds["7b"].Padding.Offset
			end
		end
		Keybinds["71"].Size = UDim2.new(0, 258, 0, totalHeight + 10) 
	end

	function Keybinds:AddBind(BindObj)
		local Bind = {}

		Bind["7c"] = Instance.new("Frame", Keybinds["78"]);
		Bind["7c"]["BorderSizePixel"] = 0;
		Bind["7c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Bind["7c"]["Size"] = UDim2.new(1, 0, 0, 10);
		Bind["7c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Bind["7c"]["Name"] = [[BindActive]];
		Bind["7c"]["BackgroundTransparency"] = 1;

		Bind["7d"] = Instance.new("TextLabel", Bind["7c"]);
		Bind["7d"]["TextStrokeTransparency"] = 0;
		Bind["7d"]["BorderSizePixel"] = 0;
		Bind["7d"]["TextSize"] = 12;
		Bind["7d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		Bind["7d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Bind["7d"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		Bind["7d"]["TextColor3"] = Color3.fromRGB(227, 94, 18);
		Bind["7d"]["BackgroundTransparency"] = 1;
		Bind["7d"]["Size"] = UDim2.new(0, 100, 1, 0);
		Bind["7d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Bind["7d"]["Text"] = "";
		Bind["7d"]["Name"] = [[Title]];

		Bind["7e"] = Instance.new("UIPadding", Bind["7d"]);
		Bind["7e"]["PaddingLeft"] = UDim.new(0, 3);
		Bind["7e"]["PaddingBottom"] = UDim.new(0, 8);

		Bind["7f"] = Instance.new("TextLabel", Bind["7c"]);
		Bind["7f"]["TextStrokeTransparency"] = 0;
		Bind["7f"]["BorderSizePixel"] = 0;
		Bind["7f"]["TextSize"] = 12;
		Bind["7f"]["TextXAlignment"] = Enum.TextXAlignment.Right;
		Bind["7f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Bind["7f"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		Bind["7f"]["TextColor3"] = Color3.fromRGB(227, 94, 18);
		Bind["7f"]["BackgroundTransparency"] = 1;
		Bind["7f"]["AnchorPoint"] = Vector2.new(1, 0);
		Bind["7f"]["Size"] = UDim2.new(0, 100, 1, 0);
		Bind["7f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Bind["7f"]["Text"] = "";
		Bind["7f"]["Name"] = [[Key]];
		Bind["7f"]["Position"] = UDim2.new(1, 0, 0, 0);

		Bind["80"] = Instance.new("UIPadding", Bind["7f"]);
		Bind["80"]["PaddingLeft"] = UDim.new(0, 3);
		Bind["80"]["PaddingBottom"] = UDim.new(0, 8);

		function Bind:Update(State)
			local Name    = State.Name  or "ERROR"
			local Type    = State.Type  or "Toggle"
			local Key     = State.Key   or Enum.KeyCode.L
			local Enabled = State.Value or false

			Bind["7f"].Text = string.format("[%s]", SimplifiedKeybinds[Key.Name] or Key.Name)
			Bind["7d"].Text = string.format("%s (%s)", Name, Type)

			if Enabled then
				Bind["7d"]["TextColor3"] = Color3.fromRGB(227, 94, 18)
				Bind["7f"]["TextColor3"] = Color3.fromRGB(227, 94, 18)
			else
				Bind["7d"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
				Bind["7f"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
			end
		end

		Bind:Update(BindObj)
		_update_size()
		return Bind
	end

	function Keybinds:SetVisibility(Visible)
		Keybinds["71"].Visible = Visible
	end    

	return Keybinds
end

function Library:CreateWatermark(Text)
	local Watermark = {
		Visible = true,
		Text    = Text or "",
	}

	do
		Watermark["8b"] = Instance.new("Frame", Library["1"]);
		Watermark["8b"]["BorderSizePixel"] = 0;
		Watermark["8b"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
		Watermark["8b"]["Size"] = UDim2.new(0, 200, 0, 25);
		Watermark["8b"]["Position"] = UDim2.new(0.005, 0, 0.01, 0);
		Watermark["8b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Watermark["8b"]["Name"] = [[Watermark]];

		Watermark["8c"] = Instance.new("UIStroke", Watermark["8b"]);
		Watermark["8c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
		Watermark["8c"]["LineJoinMode"] = Enum.LineJoinMode.Miter;
		Watermark["8c"]["Thickness"] = 2;
		Watermark["8c"]["Color"] = Color3.fromRGB(71, 71, 71);

		Watermark["8d"] = Instance.new("TextLabel", Watermark["8b"]);
		Watermark["8d"]["TextStrokeTransparency"] = 0;
		Watermark["8d"]["BorderSizePixel"] = 0;
		Watermark["8d"]["TextSize"] = 12;
		Watermark["8d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
		Watermark["8d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Watermark["8d"]["FontFace"] = Font.new([[rbxasset://fonts/families/PressStart2P.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		Watermark["8d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
		Watermark["8d"]["BackgroundTransparency"] = 1;
		Watermark["8d"]["RichText"] = true;
		Watermark["8d"]["Size"] = UDim2.new(1, 0, 1, 0);
		Watermark["8d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Watermark["8d"]["Text"] = Watermark.Text;
		Watermark["8d"]["Name"] = [[Title]];

		Watermark["8e"] = Instance.new("UIPadding", Watermark["8d"]);
		Watermark["8e"]["PaddingLeft"] = UDim.new(0, 4);
		Watermark["8e"]["PaddingBottom"] = UDim.new(0, 4);

		Watermark["8f"] = Instance.new("UIPadding", Watermark["8b"]);
		Watermark["8f"]["PaddingTop"] = UDim.new(0, 5);
		Watermark["8f"]["PaddingRight"] = UDim.new(0, 5);
		Watermark["8f"]["PaddingLeft"] = UDim.new(0, 5);
		Watermark["8f"]["PaddingBottom"] = UDim.new(0, 5);
	end

	-- Make Watermark draggable only when menu is open
	EnableDragging(Watermark["8b"], Watermark["8b"], true)

	function Watermark:SetText(Text)
		if Library.Disposed then
			return
		end
		Watermark.Text = Text or ""
		local label = Watermark["8d"]

		label.Text = Watermark.Text

		-- TextBounds only refreshes after the label re-renders, so size it next frame
		task.defer(function()
			if not Library.Disposed then
				Watermark["8b"].Size = UDim2.new(0, label.TextBounds.X + 20, 0, 25)
			end
		end)
	end

	function Watermark:SetVisible(Visible)
		Watermark["8b"].Visible = Visible
	end

	return Watermark
end

Library.KeybindsList = Library:CreateKeybindsList()
Library.Watermark = Library:CreateWatermark("DEADLINES // LIVE")

function Library:SetKeybindsListVisibility(IsVisible)
	if Library.Disposed then
		return
	end
	Library.KeybindsList["71"].Visible = IsVisible
end

--///////////////-///////////////-///////////////-///////////////-///////////////

local function bind_tracers(callback)
	return function(...)
		local env = getgenv and getgenv()
		local api = env and env.Tracers
		if api and not api.disposed then
			callback(api, ...)
		end
	end
end

return Library
