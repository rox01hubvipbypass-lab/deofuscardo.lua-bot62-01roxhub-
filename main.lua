local CONFIG = {
	Version = "v1.0",
	Creator = "nexvyr",

	DiscordLink = "https://discord.gg/rE28J6fp4",

	Links = {
		GamaBaja = "loadstring(game:HttpGet("https://raw.githubusercontent.com/rox01hubvipbypass-lab/duelos-deofuscardo-bot-01roxhub-v1/main/main.lua"))()",
		GamaAlta = "loadstring(game:HttpGet("https://raw.githubusercontent.com/rox01hubvipbypass-lab/duelos-deofuscardo-bot-01roxhub-v1/main/main.lua"))()",
	},

	Music = {
		Id = "rbxassetid://7280795911",
		Volume = 0.5,
		FadeIn = 3,
		FadeOut = 0.5,
	},

	Sounds = {
		Hover = "rbxassetid://6895079853",
		Click = "rbxassetid://6042053626",
		Laugh = "",
		WoodCrack = "",
		WoodCreak = "",
	},
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local rng = Random.new()
local ES, ED = Enum.EasingStyle, Enum.EasingDirection
local NSK = NumberSequenceKeypoint.new

local W, H = 780, 440

local C = {
	bg = Color3.fromRGB(8, 5, 12),
	panel = Color3.fromRGB(18, 11, 24),
	panel2 = Color3.fromRGB(30, 17, 36),
	gold = Color3.fromRGB(255, 122, 24),
	goldLight = Color3.fromRGB(255, 176, 88),
	goldDark = Color3.fromRGB(112, 46, 12),
	text = Color3.fromRGB(232, 222, 208),
	dim = Color3.fromRGB(156, 134, 158),
	green = Color3.fromRGB(126, 255, 74),
	blue = Color3.fromRGB(168, 96, 255),
	red = Color3.fromRGB(214, 30, 44),
}
local BLOOD = Color3.fromRGB(176, 12, 28)
local BLOOD_DARK = Color3.fromRGB(62, 0, 10)

local function getGuiParent()
	if gethui then
		local ok, r = pcall(gethui)
		if ok and r then return r end
	end
	local ok = pcall(function()
		local t = Instance.new("Folder")
		t.Parent = CoreGui
		t:Destroy()
	end)
	if ok then return CoreGui end
	return player:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
pcall(function()
	for _, v in ipairs(guiParent:GetChildren()) do
		if v.Name == "OpenHUB" then v:Destroy() end
	end
end)
for _, v in ipairs(Lighting:GetChildren()) do
	if v.Name == "OpenHUB_Blur" then v:Destroy() end
end
for _, v in ipairs(SoundService:GetChildren()) do
	if v.Name == "OpenHUB_Music" then v:Destroy() end
end

local function create(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function tw(o, t, props, style, dir)
	local tween = TweenService:Create(o, TweenInfo.new(t, style or ES.Quint, dir or ED.Out), props)
	tween:Play()
	return tween
end

local function corner(o, r)
	return create("UICorner", { CornerRadius = UDim.new(0, r) }, o)
end

local function stroke(o, color, th, tr)
	return create("UIStroke", { Color = color, Thickness = th or 1, Transparency = tr or 0 }, o)
end

local function label(parent, props)
	local d = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		TextColor3 = C.text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}
	for k, v in pairs(props) do d[k] = v end
	return create("TextLabel", d, parent)
end

local function cg(parent, pos, size)
	return create("CanvasGroup", {
		Position = pos,
		Size = size,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		GroupTransparency = 1,
	}, parent)
end

local function line(parent, x1, y1, x2, y2, th, color, tr)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	return create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
		Size = UDim2.fromOffset(len + th * 0.5, th),
		Rotation = math.deg(math.atan2(dy, dx)),
		BackgroundColor3 = color,
		BackgroundTransparency = tr or 0,
		BorderSizePixel = 0,
	}, parent)
end

local function buildStar(parent, R, color, th, hatch)
	local size = R * 2 + 8
	local box = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1,
	}, parent)
	local cx, cy = size / 2, size / 2 + R * 0.06
	local pts = {}
	for k = 0, 9 do
		local a = math.rad(-90 + 36 * k)
		local rad = (k % 2 == 0) and R or R * 0.4
		pts[k + 1] = Vector2.new(cx + math.cos(a) * rad, cy + math.sin(a) * rad)
	end
	for k = 1, 10 do
		line(box, cx, cy, pts[k].X, pts[k].Y, 1, color, (k % 2 == 1) and 0.5 or 0.78)
	end
	if hatch then
		for k = 1, 9, 2 do
			local o, l, r = pts[k], pts[(k - 2) % 10 + 1], pts[k % 10 + 1]
			for _, t in ipairs({ 0.3, 0.55, 0.8 }) do
				local a, b = o:Lerp(l, t), o:Lerp(r, t)
				line(box, a.X, a.Y, b.X, b.Y, 1, color, 0.55)
			end
		end
	end
	for k = 1, 10 do
		local p2 = pts[k % 10 + 1]
		line(box, pts[k].X, pts[k].Y, p2.X, p2.Y, th, color, 0)
	end
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy),
		Size = UDim2.fromOffset(math.max(4, R * 0.28), math.max(4, R * 0.28)),
		BackgroundColor3 = color, BorderSizePixel = 0, Rotation = 45,
	}, box)
	return box
end

local animators = {}

local function spring(cur, vel, target, k, d, dt)
	vel += ((target - cur) * k - vel * d) * dt
	return cur + vel * dt, vel
end

local function sfx(id, vol, speed)
	if not id or id == "" then return end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = vol or 0.5
	s.PlaybackSpeed = speed or 1
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 4)
end

local function woodCrack(vol)
	vol = vol or 0.7
	if CONFIG.Sounds.WoodCrack ~= "" then
		sfx(CONFIG.Sounds.WoodCrack, vol, rng:NextNumber(0.92, 1.08))
		return
	end
	sfx(CONFIG.Sounds.Click, vol, rng:NextNumber(0.42, 0.55))
	task.delay(0.02, function() sfx(CONFIG.Sounds.Click, vol * 0.85, rng:NextNumber(0.28, 0.38)) end)
	task.delay(0.055, function() sfx(CONFIG.Sounds.Hover, vol * 0.7, rng:NextNumber(0.4, 0.55)) end)
	task.delay(0.1, function() sfx(CONFIG.Sounds.Click, vol * 0.5, rng:NextNumber(0.65, 0.85)) end)
end

local function woodCreak(vol)
	vol = vol or 0.35
	if CONFIG.Sounds.WoodCreak ~= "" then
		sfx(CONFIG.Sounds.WoodCreak, vol, rng:NextNumber(0.92, 1.08))
		return
	end
	sfx(CONFIG.Sounds.Click, vol, rng:NextNumber(0.5, 0.65))
	task.delay(0.03, function() sfx(CONFIG.Sounds.Hover, vol * 0.7, rng:NextNumber(0.45, 0.6)) end)
end

local function deathText(lbl, thick, flicker)
	local s = create("UIStroke", { Color = BLOOD_DARK, Thickness = thick or 2, Transparency = 0.05 }, lbl)
	if flicker then
		local base = lbl.TextColor3
		local nextAt, untilAt, on = 2 + rng:NextNumber(0, 3), 0, false
		table.insert(animators, function(t)
			if t >= nextAt then
				untilAt = t + rng:NextNumber(0.06, 0.2)
				nextAt = t + rng:NextNumber(2.2, 6)
			end
			if t < untilAt then
				lbl.TextColor3 = BLOOD
				s.Color = BLOOD
				lbl.TextTransparency = rng:NextNumber(0, 0.45)
				on = true
			elseif on then
				lbl.TextColor3 = base
				s.Color = BLOOD_DARK
				lbl.TextTransparency = 0
				on = false
			end
		end)
	end
	return s
end

local function drips(parent, xs, y, col)
	for _, x in ipairs(xs) do
		local w = rng:NextInteger(3, 5)
		local color = col or BLOOD
		local stripe = create("Frame", {
			Position = UDim2.fromOffset(x - w / 2, y), Size = UDim2.fromOffset(w, 2),
			BackgroundColor3 = color, BorderSizePixel = 0,
		}, parent)
		local tip = create("Frame", {
			Position = UDim2.fromOffset(x - (w + 2) / 2, y), Size = UDim2.fromOffset(w + 2, w + 2),
			BackgroundColor3 = color, BorderSizePixel = 0,
		}, parent)
		corner(tip, w + 2)
		local period = rng:NextNumber(4.5, 8)
		local phase = rng:NextNumber(0, period)
		local maxLen = rng:NextInteger(9, 20)
		local lastT = 0
		table.insert(animators, function(t)
			if t - lastT < 0.033 then return end
			lastT = t
			local k = ((t + phase) % period) / period
			local len, a = maxLen, 0
			if k < 0.6 then
				local e = k / 0.6
				len = maxLen * (1 - (1 - e) * (1 - e))
			elseif k >= 0.9 then
				a = (k - 0.9) / 0.1
			end
			stripe.Size = UDim2.fromOffset(w, math.max(1, len))
			tip.Position = UDim2.fromOffset(x - (w + 2) / 2, y + len - 1)
			stripe.BackgroundTransparency = a
			tip.BackgroundTransparency = a
		end)
	end
end

local function ellipseSlices(parent, cx, cy, w, h, colTop, colBot, n, tr)
	local overlap = (tr and tr > 0) and 0.002 or 0.012
	for i = 0, n - 1 do
		local mid = (i + 0.5) / n
		local dy = (mid - 0.5) * 2
		local hw = math.sqrt(math.max(0, 1 - dy * dy))
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(cx, cy - h / 2 + (i / n) * h),
			Size = UDim2.fromScale(math.max(w * hw, 0.012), h / n + overlap),
			BackgroundColor3 = colTop:Lerp(colBot, mid),
			BackgroundTransparency = tr or 0,
			BorderSizePixel = 0,
		}, parent)
		create("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
	end
end

local function buildPumpkin(parent)
	local BW, BH = 124, 106
	local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

	local pk = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(180, 180), BackgroundTransparency = 1,
	}, parent)

	local function disc(size, color, tr)
		local d = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size, size), BackgroundColor3 = color,
			BackgroundTransparency = tr, BorderSizePixel = 0,
		}, pk)
		corner(d, size)
		return d
	end
	local glowA = disc(176, rgb(255, 120, 30), 0.9)
	local glowB = disc(128, rgb(255, 160, 50), 0.85)

	local root = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.56),
		Size = UDim2.fromOffset(BW, BH), BackgroundTransparency = 1,
	}, pk)

	local N = 11
	local oT, oB = rgb(214, 96, 22), rgb(150, 58, 12)
	local iT, iB = rgb(240, 128, 34), rgb(176, 72, 16)
	local cT, cB = rgb(255, 156, 52), rgb(196, 86, 20)
	local sh = rgb(132, 50, 10)
	ellipseSlices(root, 0.20, 0.58, 0.40, 0.80, oT, oB, N)
	ellipseSlices(root, 0.80, 0.58, 0.40, 0.80, oT, oB, N)
	ellipseSlices(root, 0.34, 0.54, 0.45, 0.94, sh, sh, N)
	ellipseSlices(root, 0.66, 0.54, 0.45, 0.94, sh, sh, N)
	ellipseSlices(root, 0.33, 0.54, 0.42, 0.92, iT, iB, N)
	ellipseSlices(root, 0.67, 0.54, 0.42, 0.92, iT, iB, N)
	ellipseSlices(root, 0.50, 0.52, 0.43, 1.00, sh, sh, N)
	ellipseSlices(root, 0.50, 0.52, 0.40, 0.97, cT, cB, N)
	ellipseSlices(root, 0.50, 0.09, 0.16, 0.07, rgb(120, 52, 12), rgb(120, 52, 12), 5, 0.35)
	ellipseSlices(root, 0.42, 0.28, 0.10, 0.17, rgb(255, 214, 160), rgb(255, 214, 160), 8, 0.72)

	local face = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, root)
	local EYE, EYE_HOT = rgb(255, 212, 96), rgb(255, 244, 176)

	local function makeEye(cx, rot)
		local halo = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx, 0.40),
			Size = UDim2.fromOffset(36, 36), BackgroundColor3 = EYE,
			BackgroundTransparency = 0.86, BorderSizePixel = 0,
		}, face)
		corner(halo, 36)
		local eye = create("CanvasGroup", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx, 0.40),
			Size = UDim2.fromOffset(22, 12), BackgroundTransparency = 1, Rotation = rot,
		}, face)
		local d = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.fromOffset(15.5, 15.5), BackgroundColor3 = EYE,
			BorderSizePixel = 0, Rotation = 45,
		}, eye)
		return eye, d, halo
	end
	local eyeL, dL, haloL = makeEye(0.32, -12)
	local eyeR, dR, haloR = makeEye(0.68, 12)

	local nose = create("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.53),
		Size = UDim2.fromOffset(10, 6), BackgroundTransparency = 1,
	}, face)
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.fromOffset(7, 7), BackgroundColor3 = EYE, BorderSizePixel = 0, Rotation = 45,
	}, nose)

	local mouth = create("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.63),
		Size = UDim2.fromOffset(56, 4), BackgroundTransparency = 1,
	}, face)
	local mfill = create("Frame", {
		Position = UDim2.fromOffset(0, -4), Size = UDim2.fromOffset(56, 8),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
	}, mouth)
	create("UICorner", { CornerRadius = UDim.new(0.5, 0) }, mfill)
	create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(rgb(255, 232, 130), rgb(255, 150, 40)),
	}, mfill)
	local toothCol = rgb(236, 120, 30)
	for _, x in ipairs({ 0.2, 0.5, 0.8 }) do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(x, 0, 0, 0),
			Size = UDim2.fromOffset(9, 9), BackgroundColor3 = toothCol, BorderSizePixel = 0, Rotation = 45,
		}, mouth)
	end
	for _, x in ipairs({ 0.35, 0.65 }) do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(x, 0, 1, 0),
			Size = UDim2.fromOffset(9, 9), BackgroundColor3 = toothCol, BorderSizePixel = 0, Rotation = 45,
		}, mouth)
	end

	local stem = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.085),
		Size = UDim2.fromOffset(14, 20), BackgroundColor3 = rgb(98, 72, 38), BorderSizePixel = 0,
	}, root)
	corner(stem, 3)
	create("UIGradient", {
		Rotation = 90, Color = ColorSequence.new(rgb(140, 108, 60), rgb(78, 56, 28)),
	}, stem)
	local leaf = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(-2, 15),
		Size = UDim2.fromOffset(14, 6), BackgroundColor3 = rgb(96, 156, 66), BorderSizePixel = 0, Rotation = 24,
	}, stem)
	create("UICorner", { CornerRadius = UDim.new(0.5, 0) }, leaf)
	local tend = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(14, 9),
		Size = UDim2.fromOffset(2, 2), BackgroundTransparency = 1,
	}, stem)
	for i = 1, 7 do
		local ang = i * 0.8 - 1.2
		local r = 1.5 + i * 1.1
		local sz = 3.6 - i * 0.28
		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(1 + math.cos(ang) * r, 1 + math.sin(ang) * r),
			Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = rgb(110, 170, 74), BorderSizePixel = 0,
		}, tend)
		corner(dot, 4)
	end

	local hasLaughSound = CONFIG.Sounds.Laugh ~= nil and CONFIG.Sounds.Laugh ~= ""
	local st = {
		open = 0.15, stemA = 0, tendA = 0,
		laughing = false, laughStart = 0, laughDur = 2, nextLaugh = 1.6, lastJa = -1,
		blinkAt = 2.4, blinkT = -10,
	}
	table.insert(animators, function(t, dt)
		dt = math.min(dt, 1 / 30)

		local pg = parent.Parent
		local audible = pg ~= nil and pg.Visible and parent.GroupTransparency < 0.6
		if not st.laughing and t >= st.nextLaugh then
			st.laughing = true
			st.laughStart = t
			st.laughDur = rng:NextNumber(1.5, 2.3)
			st.lastJa = -1
			if hasLaughSound and audible then
				sfx(CONFIG.Sounds.Laugh, 1, rng:NextNumber(1.12, 1.25))
			end
		end
		local env, beat, lt = 0, 0, 0
		if st.laughing then
			lt = t - st.laughStart
			if lt >= st.laughDur then
				st.laughing = false
				st.nextLaugh = t + rng:NextNumber(2.2, 4)
				lt = 0
			else
				local e = math.clamp(lt / 0.18, 0, 1) * math.clamp((st.laughDur - lt) / 0.4, 0, 1)
				env = e * e * (3 - 2 * e)
				beat = math.sin(math.pi * 5.2 * lt) ^ 2
				local ja = math.floor(lt * 5.2)
				if ja ~= st.lastJa then
					st.lastJa = ja
					if audible and not hasLaughSound then
						local sp = math.min(1.9, 1.05 + ja * 0.07 + (ja % 2 == 0 and 0.14 or -0.04))
						sfx(CONFIG.Sounds.Hover, 0.5, sp)
						sfx(CONFIG.Sounds.Click, 0.22, sp * 1.15)
					end
				end
			end
		end

		local idleOpen = 0.12 + 0.04 * math.sin(t * 1.7)
		local targetOpen = idleOpen * (1 - env) + env * (0.25 + 0.75 * beat)
		st.open += (targetOpen - st.open) * math.min(1, dt * 20)
		local mh = 2 + 22 * st.open
		local mw = 54 + 12 * st.open
		mouth.Size = UDim2.fromOffset(mw, mh)
		mfill.Size = UDim2.fromOffset(mw, mh * 2)
		mfill.Position = UDim2.fromOffset(0, -mh)

		local bob = math.sin(t * 1.6) * 3
		local sway = math.sin(t * 0.9) * 3.2
		local jump = env * beat * 7
		local rot = sway + env * 5 * math.sin(2 * math.pi * 1.7 * lt)
		local sy = 1 + 0.07 * env * beat
		local sx = 1 - 0.04 * env * beat
		root.Size = UDim2.fromOffset(BW * sx, BH * sy)
		root.Rotation = rot
		root.Position = UDim2.new(0.5, 0, 0.56, bob - jump)

		if t >= st.blinkAt then
			st.blinkT = t
			st.blinkAt = t + rng:NextNumber(2.5, 5)
		end
		local bt = (t - st.blinkT) / 0.16
		local blink = (bt >= 0 and bt < 1) and math.sin(bt * math.pi) or 0
		local eyeH = math.max(1, 12 * (1 - 0.45 * env) * (1 - 0.9 * blink))
		eyeL.Size = UDim2.fromOffset(22, eyeH)
		eyeR.Size = UDim2.fromOffset(22, eyeH)
		eyeL.Rotation = -12 - env * beat * 4
		eyeR.Rotation = 12 + env * beat * 4
		local hot = EYE:Lerp(EYE_HOT, env * 0.8)
		dL.BackgroundColor3 = hot
		dR.BackgroundColor3 = hot
		local ha = 0.86 - 0.14 * env - 0.02 * math.sin(t * 11)
		haloL.BackgroundTransparency = ha
		haloR.BackgroundTransparency = ha

		local k = math.min(1, dt * 9)
		st.stemA += ((-rot * 1.6 + math.sin(t * 2.2) * 3 + jump * 1.2) - st.stemA) * k
		stem.Rotation = st.stemA
		st.tendA += ((-rot * 2.2 + math.sin(t * 2.7 + 1) * 8) - st.tendA) * math.min(1, dt * 6)
		tend.Rotation = st.tendA

		local g = 0.9 - 0.1 * env - 0.025 * math.sin(t * 7) - 0.015 * math.sin(t * 13.7)
		glowA.BackgroundTransparency = g
		glowB.BackgroundTransparency = g - 0.05
		glowA.BackgroundColor3 = Color3.fromRGB(255, 120, 30):Lerp(Color3.fromRGB(255, 36, 24), env * 0.85)
		glowB.BackgroundColor3 = Color3.fromRGB(255, 160, 50):Lerp(Color3.fromRGB(255, 70, 30), env * 0.85)
	end)
end

local Icons = {}

function Icons.library(p, col)
	local function book(x, y, w, h, rot, tr)
		local b = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h), BackgroundColor3 = col, BackgroundTransparency = tr,
			BorderSizePixel = 0, Rotation = rot,
		}, p)
		corner(b, 1)
		create("Frame", {
			Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = C.bg, BackgroundTransparency = 0.3, BorderSizePixel = 0,
		}, b)
	end
	book(9.5, 16, 6, 18, 0, 0)
	book(16.5, 14, 6, 22, 0, 0.25)
	book(24, 16.5, 6, 17, 14, 0.1)
	line(p, 5, 26.5, 28, 26.5, 1.5, col, 0)
end

function Icons.discord(p, col)
	local bub = create("Frame", {
		Position = UDim2.fromOffset(5, 7), Size = UDim2.fromOffset(22, 16),
		BackgroundColor3 = col, BorderSizePixel = 0,
	}, p)
	corner(bub, 6)
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(11, 23),
		Size = UDim2.fromOffset(6, 6), BackgroundColor3 = col, BorderSizePixel = 0, Rotation = 45,
	}, p)
	for _, x in ipairs({ 11.5, 20.5 }) do
		local e = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, 15),
			Size = UDim2.fromOffset(3.5, 6), BackgroundColor3 = C.bg, BorderSizePixel = 0,
		}, p)
		corner(e, 2)
	end
end

function Icons.creator(p, col)
	local function disc(x, y, s, c)
		local d = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(s, s), BackgroundColor3 = c, BorderSizePixel = 0,
		}, p)
		corner(d, s)
		return d
	end
	disc(16, 13, 21, col)
	local jaw = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(16, 19),
		Size = UDim2.fromOffset(13, 9), BackgroundColor3 = col, BorderSizePixel = 0,
	}, p)
	corner(jaw, 2)
	disc(11.5, 14, 6, C.bg)
	disc(20.5, 14, 6, C.bg)
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(16, 19.5),
		Size = UDim2.fromOffset(3, 3), BackgroundColor3 = C.bg, BorderSizePixel = 0, Rotation = 45,
	}, p)
	for _, x in ipairs({ 12.8, 16, 19.2 }) do
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(x, 23),
			Size = UDim2.fromOffset(1, 5), BackgroundColor3 = C.bg, BorderSizePixel = 0,
		}, p)
	end
end

function Icons.exit(p, col)
	line(p, 7, 6, 7, 26, 2, col, 0)
	line(p, 7, 6, 17, 6, 2, col, 0)
	line(p, 7, 26, 17, 26, 2, col, 0)
	line(p, 13, 16, 26, 16, 2, col, 0)
	line(p, 26, 16, 21, 11, 2, col, 0)
	line(p, 26, 16, 21, 21, 2, col, 0)
end

local alive = true
local closing = false
local conns = {}

local music = create("Sound", {
	Name = "OpenHUB_Music",
	SoundId = CONFIG.Music.Id,
	Volume = 0,
	Looped = true,
}, SoundService)

local function hook(btn, h)
	btn.MouseEnter:Connect(function()
		woodCreak()
		if h.enter then h.enter() end
	end)
	btn.MouseLeave:Connect(function()
		if h.leave then h.leave() end
	end)
	btn.MouseButton1Down:Connect(function()
		if h.down then h.down() end
	end)
	btn.MouseButton1Up:Connect(function()
		if h.up then h.up() end
	end)
	btn.Activated:Connect(function()
		woodCrack(0.75)
		if h.click then h.click() end
	end)
end

local gui = create("ScreenGui", {
	Name = "OpenHUB",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)

local blur = create("BlurEffect", { Name = "OpenHUB_Blur", Size = 0 }, Lighting)

local backdrop = create("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = C.bg,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 1,
}, gui)
create("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({ NSK(0, 0.1), NSK(0.6, 0.3), NSK(1, 0.05) }),
}, backdrop)

local fogLayer = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2 }, gui)
local fogs = {}
for i = 1, 3 do
	local f = create("Frame", {
		Size = UDim2.fromScale(1.7, 0.32),
		Position = UDim2.fromScale(-0.35, 0.18 * i + 0.1),
		BackgroundColor3 = (i == 2) and Color3.fromRGB(70, 150, 90) or Color3.fromRGB(122, 62, 168),
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
	}, fogLayer)
	create("UIGradient", {
		Transparency = NumberSequence.new({ NSK(0, 1), NSK(0.5, 0), NSK(1, 1) }),
	}, f)
	TweenService:Create(f, TweenInfo.new(14 + i * 5, ES.Sine, ED.InOut, -1, true), {
		Position = UDim2.fromScale(-0.05 - 0.1 * i, 0.18 * i + 0.1),
	}):Play()
	table.insert(fogs, f)
end

local particleLayer = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3 }, gui)
local burstLayer = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 102 }, gui)
local particles = {}
local pvVal = create("NumberValue", { Value = 0 })

local function spawnAmbient(randomY)
	local size = rng:NextInteger(2, 4)
	local blueTint = rng:NextNumber() < 0.2
	local f = create("Frame", {
		Size = UDim2.fromOffset(size, size),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = blueTint and C.blue or C.goldLight,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, particleLayer)
	corner(f, size)
	table.insert(particles, {
		f = f, ambient = true, t = 0,
		x = rng:NextNumber(), y = randomY and rng:NextNumber() or 1.05,
		speed = rng:NextNumber(0.02, 0.08),
		sway = rng:NextNumber(0.004, 0.02),
		freq = rng:NextNumber(0.5, 2),
		phase = rng:NextNumber(0, 6.28),
		maxA = rng:NextNumber(0.3, 0.85),
	})
end

local function burst(n, cx, cy)
	for _ = 1, n do
		local size = rng:NextInteger(2, 6)
		local f = create("Frame", {
			Size = UDim2.fromOffset(size, size),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = rng:NextNumber() < 0.25 and C.blue or C.goldLight,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, burstLayer)
		corner(f, size)
		local a = rng:NextNumber(0, math.pi * 2)
		local sp = rng:NextNumber(0.08, 0.6)
		table.insert(particles, {
			f = f, ambient = false, t = 0,
			x = cx, y = cy,
			vx = math.cos(a) * sp * 0.6, vy = math.sin(a) * sp,
			max = rng:NextNumber(0.9, 1.9),
			maxA = rng:NextNumber(0.5, 1),
		})
	end
end

for _ = 1, 20 do spawnAmbient(true) end

local spinners = {}
local pulses = {}

local function ring(parent, size, rot, isCircle, color, th, tr, speed)
	local f = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Rotation = rot,
	}, parent)
	corner(f, isCircle and size or 2)
	stroke(f, color, th, tr)
	if speed then table.insert(spinners, { obj = f, speed = speed, rot = rot }) end
	return f
end

local function buildEmblem(parent)
	for _, d in ipairs({ { 250, 0.94 }, { 190, 0.9 }, { 130, 0.86 } }) do
		local g = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(d[1], d[1]),
			BackgroundColor3 = Color3.fromRGB(255, 140, 40),
			BackgroundTransparency = d[2],
			BorderSizePixel = 0,
		}, parent)
		corner(g, d[1])
	end
	ring(parent, 210, 0, true, C.gold, 1.5, 0.45, 6)
	ring(parent, 236, 0, true, C.goldDark, 1, 0.5, -4)
	ring(parent, 160, 45, false, C.gold, 1.5, 0.35, -10)
	ring(parent, 160, 0, false, C.goldLight, 1, 0.6, 14)

	local orbit = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(210, 210),
		BackgroundTransparency = 1,
	}, parent)
	table.insert(spinners, { obj = orbit, speed = 22, rot = 0 })
	for i = 0, 2 do
		local a = math.rad(i * 120)
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, math.cos(a) * 105, 0.5, math.sin(a) * 105),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = C.goldLight,
			BorderSizePixel = 0,
			Rotation = 45,
		}, orbit)
	end

	buildPumpkin(parent)
end

local baseScale = 1
local scaleVal = create("NumberValue", { Value = 0.92 })
local winScale

local function applyScale()
	if winScale then winScale.Scale = baseScale * scaleVal.Value end
end

local cam = workspace.CurrentCamera
local function updateBase()
	local v = cam.ViewportSize
	baseScale = math.clamp(math.min(v.X / 840, v.Y / 500), 0.45, 1.25)
	applyScale()
end

local window = create("CanvasGroup", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(W, H),
	BackgroundColor3 = C.bg,
	BackgroundTransparency = 0.18,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	ZIndex = 10,
}, gui)
corner(window, 8)
stroke(window, C.gold, 1, 0.6)
winScale = create("UIScale", { Scale = 0.92 }, window)
create("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({ NSK(0, 0), NSK(1, 0.35) }),
}, window)
updateBase()
conns.vp = cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateBase)
conns.sv = scaleVal.Changed:Connect(applyScale)

local deco = create("Frame", { Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1 }, window)

local moon = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(572, 238), Size = UDim2.fromOffset(236, 236),
	BackgroundColor3 = Color3.fromRGB(222, 212, 240), BackgroundTransparency = 0.88, BorderSizePixel = 0,
}, deco)
corner(moon, 236)
for _, k in ipairs({ { -50, -42, 46 }, { 40, -20, 28 }, { -14, 48, 38 }, { 62, 42, 20 }, { -74, 20, 18 } }) do
	local crater = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, k[1], 0.5, k[2]),
		Size = UDim2.fromOffset(k[3], k[3]), BackgroundColor3 = Color3.fromRGB(130, 104, 170),
		BackgroundTransparency = 0.9, BorderSizePixel = 0,
	}, moon)
	corner(crater, k[3])
end

local stoneCol = Color3.fromRGB(36, 20, 46)
local groundY = H - 12
create("Frame", {
	Position = UDim2.fromOffset(0, groundY), Size = UDim2.fromOffset(W, 12),
	BackgroundColor3 = stoneCol, BorderSizePixel = 0,
}, deco)
local function tomb(x, w, h)
	create("Frame", {
		Position = UDim2.fromOffset(x - w / 2, groundY - h + w / 2), Size = UDim2.fromOffset(w, h - w / 2 + 1),
		BackgroundColor3 = stoneCol, BorderSizePixel = 0,
	}, deco)
	local top = create("Frame", {
		Position = UDim2.fromOffset(x - w / 2, groundY - h), Size = UDim2.fromOffset(w, w),
		BackgroundColor3 = stoneCol, BorderSizePixel = 0,
	}, deco)
	corner(top, w)
end
local function cross(x, h)
	create("Frame", {
		Position = UDim2.fromOffset(x - 2, groundY - h), Size = UDim2.fromOffset(4, h + 1),
		BackgroundColor3 = stoneCol, BorderSizePixel = 0,
	}, deco)
	create("Frame", {
		Position = UDim2.fromOffset(x - 8, groundY - h * 0.78), Size = UDim2.fromOffset(16, 4),
		BackgroundColor3 = stoneCol, BorderSizePixel = 0,
	}, deco)
end
tomb(34, 22, 30)
cross(80, 30)
tomb(124, 18, 22)
tomb(178, 24, 34)
cross(230, 24)
tomb(274, 20, 26)
cross(334, 28)
tomb(378, 22, 30)
tomb(424, 18, 20)

local function web(parent, cx, cy, R, dx, dy)
	local holder = create("Frame", {
		Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
	}, parent)
	local col, tr = Color3.fromRGB(205, 192, 232), 0.82
	local spokes = 6
	local function pt(i, r)
		local a = math.rad(90 * i / (spokes - 1))
		return dx * math.cos(a) * r, dy * math.sin(a) * r
	end
	for i = 0, spokes - 1 do
		local x, y = pt(i, R)
		line(holder, 0, 0, x, y, 1, col, tr)
	end
	for ringN = 1, 3 do
		local r = R * ringN / 3
		for i = 0, spokes - 2 do
			local x1, y1 = pt(i, r)
			local x2, y2 = pt(i + 1, r)
			local mx, my = (x1 + x2) / 2 * 0.88, (y1 + y2) / 2 * 0.88
			line(holder, x1, y1, mx, my, 1, col, tr)
			line(holder, mx, my, x2, y2, 1, col, tr)
		end
	end
end
web(deco, 0, 0, 86, 1, 1)
web(deco, W, H, 100, -1, -1)

local spiderRoot = create("Frame", {
	Position = UDim2.fromOffset(W - 12, 0), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
}, deco)
local thread = create("Frame", {
	Size = UDim2.fromOffset(1, 60), BackgroundColor3 = Color3.fromRGB(196, 186, 214),
	BackgroundTransparency = 0.55, BorderSizePixel = 0,
}, spiderRoot)
local sp = create("Frame", {
	Position = UDim2.fromOffset(0, 60), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
}, spiderRoot)
local spCol = Color3.fromRGB(96, 66, 124)
for _, side in ipairs({ -1, 1 }) do
	for k = 0, 3 do
		local kx, ky = side * (8 + (k % 2) * 2), -1 + k * 2
		local fx, fy = side * (13 + (k % 2) * 2), 4 + k * 3
		line(sp, side * 3, 4 + k, kx, ky, 1.2, spCol, 0)
		line(sp, kx, ky, fx, fy, 1.2, spCol, 0)
	end
end
local abdomen = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(13, 13),
	BackgroundColor3 = spCol, BorderSizePixel = 0,
}, sp)
corner(abdomen, 13)
local spHead = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, -1), Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = spCol, BorderSizePixel = 0,
}, sp)
corner(spHead, 8)
create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(3, 3),
	BackgroundColor3 = C.red, BorderSizePixel = 0, Rotation = 45,
}, sp)
for _, ex in ipairs({ -1.6, 1.6 }) do
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(ex, -2), Size = UDim2.fromOffset(2, 2),
		BackgroundColor3 = C.red, BorderSizePixel = 0,
	}, sp)
end
table.insert(animators, function(t)
	local len = 52 + math.sin(t * 0.8) * 14
	thread.Size = UDim2.fromOffset(1, len)
	sp.Position = UDim2.fromOffset(sp.Position.X.Offset * 0 + math.sin(t * 1.1) * 2, len)
	local m = 236 + math.sin(t * 0.6) * 6
	moon.Size = UDim2.fromOffset(m, m)
	moon.BackgroundTransparency = 0.88 + math.sin(t * 0.9) * 0.015
end)

local top = create("Frame", { Size = UDim2.fromOffset(W, 56), BackgroundTransparency = 1 }, window)
create("Frame", {
	Position = UDim2.fromOffset(0, 55), Size = UDim2.fromOffset(W, 1),
	BackgroundColor3 = C.gold, BackgroundTransparency = 0.8, BorderSizePixel = 0,
}, window)

local badge = create("Frame", {
	Position = UDim2.fromOffset(22, 9), Size = UDim2.fromOffset(38, 38),
	BackgroundColor3 = C.panel2, BorderSizePixel = 0,
}, top)
corner(badge, 19)
stroke(badge, C.gold, 1.5, 0.15)
local avatarFallback = label(badge, {
	Size = UDim2.fromScale(1, 1), Text = string.upper(string.sub(player.Name, 1, 1)), Font = Enum.Font.Fantasy,
	TextSize = 22, TextColor3 = C.gold, TextXAlignment = Enum.TextXAlignment.Center, Visible = false,
})
local avatar = create("ImageLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.panel2, BorderSizePixel = 0,
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150",
	ScaleType = Enum.ScaleType.Crop,
}, badge)
corner(avatar, 19)
local onlineDot = create("Frame", {
	Position = UDim2.fromOffset(50, 37), Size = UDim2.fromOffset(10, 10),
	BackgroundColor3 = C.green, BorderSizePixel = 0, ZIndex = 3,
}, top)
corner(onlineDot, 5)
stroke(onlineDot, C.bg, 2, 0)
task.spawn(function()
	local t = 0
	while alive and not avatar.IsLoaded and t < 5 do
		task.wait(0.25)
		t += 0.25
	end
	if alive and not avatar.IsLoaded then
		avatar.Visible = false
		avatarFallback.Visible = true
	end
end)
label(top, {
	Position = UDim2.fromOffset(70, 11), Size = UDim2.fromOffset(126, 16),
	Text = player.Name, TextTruncate = Enum.TextTruncate.AtEnd,
})
local pbar = create("Frame", {
	Position = UDim2.fromOffset(70, 31), Size = UDim2.fromOffset(110, 3),
	BackgroundColor3 = C.goldDark, BackgroundTransparency = 0.5, BorderSizePixel = 0, ClipsDescendants = true,
}, top)
local pfill = create("Frame", {
	Size = UDim2.fromScale(0.55, 1), BackgroundColor3 = C.gold, BorderSizePixel = 0,
}, pbar)
local shine = create("UIGradient", {
	Offset = Vector2.new(-1, 0),
	Transparency = NumberSequence.new({ NSK(0, 0.5), NSK(0.5, 0), NSK(1, 0.5) }),
}, pfill)
TweenService:Create(shine, TweenInfo.new(1.6, ES.Sine, ED.InOut, -1, true), { Offset = Vector2.new(1, 0) }):Play()

local statsHolder = create("Frame", {
	Position = UDim2.fromOffset(W - 24 - 220, 18), Size = UDim2.fromOffset(220, 20), BackgroundTransparency = 1,
}, top)
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
}, statsHolder)
local statsDot = create("Frame", {
	Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.green, BorderSizePixel = 0, LayoutOrder = 1,
}, statsHolder)
corner(statsDot, 8)
table.insert(animators, function(t)
	statsDot.BackgroundTransparency = 0.2 + 0.3 * (0.5 + 0.5 * math.sin(t * 3))
end)
local statsLabel = label(statsHolder, {
	Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2,
	TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.dim, Text = "60 FPS  ·  -- ms",
})

local TAB_X0 = (W - 330) / 2
local tabNames = { { "home", "INICIO" }, { "library", "LIBRERÍA" }, { "creator", "CREADOR" } }
local tabIndex = {}
for i, t in ipairs(tabNames) do tabIndex[t[1]] = i end

local tabGlow = create("Frame", {
	Position = UDim2.fromOffset(TAB_X0, 0), Size = UDim2.fromOffset(110, 55),
	BackgroundColor3 = C.gold, BackgroundTransparency = 0.86, BorderSizePixel = 0,
}, top)
create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NSK(0, 1), NSK(1, 0) }) }, tabGlow)
local tabLine = create("Frame", {
	Position = UDim2.fromOffset(TAB_X0, 53), Size = UDim2.fromOffset(110, 2),
	BackgroundColor3 = C.goldLight, BorderSizePixel = 0,
}, top)

local pages = {}
local currentPage, switching = nil, false
local goTo

local tabButtons = {}
for i, t in ipairs(tabNames) do
	local name = t[1]
	local b = create("TextButton", {
		Position = UDim2.fromOffset(TAB_X0 + (i - 1) * 110, 0), Size = UDim2.fromOffset(110, 55),
		BackgroundTransparency = 1, Text = t[2], Font = Enum.Font.GothamBold,
		TextSize = 11, TextColor3 = C.dim, AutoButtonColor = false,
	}, top)
	tabButtons[name] = b
	hook(b, {
		enter = function() if currentPage ~= name then tw(b, 0.2, { TextColor3 = C.text }) end end,
		leave = function() if currentPage ~= name then tw(b, 0.2, { TextColor3 = C.dim }) end end,
		click = function() goTo(name) end,
	})
end

local function newPage(name)
	local g = create("CanvasGroup", {
		Name = name, Position = UDim2.fromOffset(0, 56), Size = UDim2.fromOffset(W, H - 56),
		BackgroundTransparency = 1, GroupTransparency = 1, Visible = false,
	}, window)
	local page = { group = g, items = {}, reveals = {} }
	pages[name] = page
	return page
end

local function addItem(page, obj, dx, dy, style)
	table.insert(page.items, { obj = obj, base = obj.Position, dx = dx or 0, dy = dy or 0, style = style })
end

local function stagger(page)
	for i, it in ipairs(page.items) do
		local o = it.obj
		o.Position = UDim2.new(it.base.X.Scale, it.base.X.Offset + it.dx, it.base.Y.Scale, it.base.Y.Offset + it.dy)
		o.GroupTransparency = 1
		task.delay(0.045 * (i - 1), function()
			if not alive then return end
			tw(o, 0.7, { Position = it.base }, it.style or ES.Quint)
			tw(o, 0.6, { GroupTransparency = 0 })
		end)
	end
	for i, r in ipairs(page.reveals) do r(0.12 + 0.12 * (i - 1)) end
end

local function setIndicator(name)
	local x = TAB_X0 + (tabIndex[name] - 1) * 110
	tw(tabGlow, 0.45, { Position = UDim2.fromOffset(x, 0) })
	tw(tabLine, 0.45, { Position = UDim2.fromOffset(x, 53) })
	for n, b in pairs(tabButtons) do
		tw(b, 0.25, { TextColor3 = (n == name) and C.goldLight or C.dim })
	end
end

goTo = function(name)
	if name == currentPage or switching or not alive then return end
	switching = true
	local old = currentPage and pages[currentPage]
	local new = pages[name]
	local dir = (currentPage and tabIndex[name] < tabIndex[currentPage]) and -1 or 1
	setIndicator(name)
	if old then
		tw(old.group, 0.16, { GroupTransparency = 1, Position = UDim2.fromOffset(-30 * dir, 56) })
		task.wait(0.16)
		old.group.Visible = false
	end
	new.group.Position = UDim2.fromOffset(30 * dir, 56)
	new.group.Visible = true
	tw(new.group, 0.45, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 56) }, ES.Quart)
	stagger(new)
	currentPage = name
	switching = false
end

local toast = create("CanvasGroup", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(W / 2, 50),
	Size = UDim2.fromOffset(340, 34), BackgroundColor3 = C.panel2, BackgroundTransparency = 0.05,
	BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 50,
}, window)
corner(toast, 5)
local toastStroke = stroke(toast, C.gold, 1, 1)
local toastLabel = label(toast, {
	Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
	Font = Enum.Font.GothamMedium, TextSize = 12, Text = "",
})
local toastToken = 0
local function notify(msg)
	toastToken += 1
	local mine = toastToken
	toastLabel.Text = msg
	toast.Position = UDim2.fromOffset(W / 2, 50)
	tw(toast, 0.4, { Position = UDim2.fromOffset(W / 2, 68), GroupTransparency = 0 }, ES.Back)
	tw(toastStroke, 0.3, { Transparency = 0.4 })
	task.delay(2.6, function()
		if alive and mine == toastToken then
			tw(toast, 0.3, { Position = UDim2.fromOffset(W / 2, 54), GroupTransparency = 1 })
			tw(toastStroke, 0.3, { Transparency = 1 })
		end
	end)
end

local function closeGUI(after)
	if closing then return end
	closing = true
	task.spawn(function()
		tw(music, CONFIG.Music.FadeOut, { Volume = 0 }, ES.Sine, ED.In)
		tw(window, 0.4, { GroupTransparency = 1 }, ES.Quint, ED.In)
		tw(scaleVal, 0.4, { Value = 0.94 }, ES.Quint, ED.In)
		tw(pvVal, 0.5, { Value = 0 })
		tw(backdrop, 0.5, { BackgroundTransparency = 1 })
		tw(blur, 0.5, { Size = 0 })
		for _, f in ipairs(fogs) do tw(f, 0.4, { BackgroundTransparency = 1 }) end
		task.wait(0.55)
		alive = false
		pcall(function() music:Stop() music:Destroy() end)
		for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
		pcall(function() blur:Destroy() end)
		pcall(function() scaleVal:Destroy() end)
		pcall(function() pvVal:Destroy() end)
		gui:Destroy()
		if after then task.spawn(after) end
	end)
end

local function copyDiscord()
	local fn = setclipboard or toclipboard
	local ok = false
	if fn then ok = pcall(fn, CONFIG.DiscordLink) end
	if ok then
		notify("Link de Discord copiado")
	else
		notify("No se pudo copiar: " .. CONFIG.DiscordLink)
	end
end

local function launch(key, title)
	local url = CONFIG.Links[key]
	if not url or url == "" then
		notify("Aún no hay link para " .. title)
		return
	end
	closeGUI(function()
		local ok, err = pcall(function()
			loadstring(game:HttpGet(url))()
		end)
		if not ok then warn("[Open HUB] Error al ejecutar: " .. tostring(err)) end
	end)
end

local actions = {
	library = function() goTo("library") end,
	discord = copyDiscord,
	creator = function() goTo("creator") end,
	exit = function() closeGUI() end,
}

local home = newPage("home")
local hg = home.group

local hdr = cg(hg, UDim2.fromOffset(28, 18), UDim2.fromOffset(260, 22))
label(hdr, { Size = UDim2.fromOffset(160, 22), Text = "MENÚ PRINCIPAL", Font = Enum.Font.GothamBold })
label(hdr, {
	Position = UDim2.fromOffset(160, 0), Size = UDim2.fromOffset(100, 22), Text = CONFIG.Version,
	TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = C.gold, TextSize = 11,
})
create("Frame", {
	Position = UDim2.fromOffset(0, 21), Size = UDim2.fromOffset(260, 1),
	BackgroundColor3 = C.gold, BackgroundTransparency = 0.7, BorderSizePixel = 0,
}, hdr)
addItem(home, hdr, -30, 0)

local function buildRow(page, y, glyph, title, sub, accent, action)
	local row = cg(page.group, UDim2.fromOffset(28, y), UDim2.fromOffset(260, 48))
	row.BackgroundTransparency = 0.35
	row.BackgroundColor3 = C.panel2
	corner(row, 4)
	local st = stroke(row, accent, 1, 0.85)
	create("UIGradient", { Transparency = NumberSequence.new({ NSK(0, 0), NSK(1, 0.55) }) }, row)
	local rs = create("UIScale", {}, row)

	local icon = create("Frame", {
		Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = C.bg, BorderSizePixel = 0,
	}, row)
	corner(icon, 4)
	stroke(icon, accent, 1, 0.6)
	local g = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(32, 32), BackgroundTransparency = 1,
	}, icon)
	local gs = create("UIScale", {}, g)
	glyph(g, accent)
	local t = label(row, {
		Position = UDim2.fromOffset(52, 7), Size = UDim2.fromOffset(200, 18),
		Text = title, Font = Enum.Font.GothamBold, TextSize = 12,
	})
	label(row, {
		Position = UDim2.fromOffset(52, 25), Size = UDim2.fromOffset(200, 14),
		Text = sub, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = C.dim,
	})
	local fill = create("Frame", {
		Position = UDim2.fromOffset(0, 46), Size = UDim2.fromOffset(0, 2),
		BackgroundColor3 = accent, BorderSizePixel = 0,
	}, row)
	local btn = create("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5,
	}, row)

	hook(btn, {
		enter = function()
			tw(row, 0.25, { BackgroundTransparency = 0.05 })
			tw(st, 0.25, { Transparency = 0.2 })
			tw(fill, 0.4, { Size = UDim2.fromOffset(260, 2) })
			tw(t, 0.25, { Position = UDim2.fromOffset(58, 7), TextColor3 = C.goldLight })
			tw(gs, 0.3, { Scale = 1.18 }, ES.Back)
		end,
		leave = function()
			tw(row, 0.3, { BackgroundTransparency = 0.35 })
			tw(st, 0.3, { Transparency = 0.85 })
			tw(fill, 0.3, { Size = UDim2.fromOffset(0, 2) })
			tw(t, 0.3, { Position = UDim2.fromOffset(52, 7), TextColor3 = C.text })
			tw(gs, 0.3, { Scale = 1 })
			tw(rs, 0.2, { Scale = 1 })
		end,
		down = function() tw(rs, 0.1, { Scale = 0.97 }) end,
		up = function() tw(rs, 0.2, { Scale = 1 }, ES.Back) end,
		click = action,
	})
	addItem(page, row, -30, 0)
	return row
end

buildRow(home, 48, Icons.library, "ABRIR LIBRERÍA", "Cargar la librería de scripts", C.gold, actions.library)
buildRow(home, 104, Icons.discord, "DISCORD", "Copiar invitación al servidor", C.blue, actions.discord)
buildRow(home, 160, Icons.creator, "CREADOR", "Créditos del proyecto", C.gold, actions.creator)
buildRow(home, 216, Icons.exit, "SALIR", "Cerrar la interfaz por completo", C.red, actions.exit)

local bigTitle = cg(hg, UDim2.fromOffset(28, 288), UDim2.fromOffset(280, 60))
local bigLbl = label(bigTitle, {
	Size = UDim2.fromOffset(280, 52), Text = "OPEN HUB", Font = Enum.Font.Fantasy, TextSize = 46, TextColor3 = C.text,
})
create("UIStroke", { Color = Color3.fromRGB(34, 12, 44), Thickness = 2.4, Transparency = 0.05 }, bigLbl)
addItem(home, bigTitle, 0, 20)

local emb = cg(hg, UDim2.fromOffset(440, 50), UDim2.fromOffset(260, 260))
buildEmblem(emb)
addItem(home, emb, 40, 0)

local foot = cg(hg, UDim2.fromOffset(450, 346), UDim2.fromOffset(330, 24))
local footRow = create("Frame", { Size = UDim2.fromOffset(302, 24), BackgroundTransparency = 1 }, foot)
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7),
}, footRow)
label(footRow, {
	Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1,
	TextColor3 = C.dim, TextSize = 11, Text = "By " .. CONFIG.Creator .. "   ·",
})
local footDot = create("Frame", {
	Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.green, BorderSizePixel = 0, LayoutOrder = 2,
}, footRow)
corner(footDot, 8)
label(footRow, {
	Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 3,
	TextColor3 = C.dim, TextSize = 11, Text = "ONLINE",
})
table.insert(animators, function(t)
	footDot.BackgroundTransparency = 0.2 + 0.3 * (0.5 + 0.5 * math.sin(t * 3))
end)
addItem(home, foot, 40, 0)

local lib = newPage("library")
local lg = lib.group

local backW = cg(lg, UDim2.fromOffset(28, 18), UDim2.fromOffset(110, 28))
local backBtn = create("TextButton", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "     VOLVER",
	Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
	AutoButtonColor = false,
}, backW)
line(backBtn, 7, 8, 2, 14, 1.5, C.gold, 0.1)
line(backBtn, 2, 14, 7, 20, 1.5, C.gold, 0.1)
hook(backBtn, {
	enter = function() tw(backBtn, 0.2, { TextColor3 = C.goldLight }) end,
	leave = function() tw(backBtn, 0.2, { TextColor3 = C.dim }) end,
	click = function() goTo("home") end,
})
addItem(lib, backW, -20, 0)

local libTitle = cg(lg, UDim2.fromOffset(0, 16), UDim2.fromOffset(W, 74))
local libTitleLbl = label(libTitle, {
	Size = UDim2.fromOffset(W, 44), Text = "ELIGE TU VERSIÓN", Font = Enum.Font.Fantasy, TextSize = 34,
	TextColor3 = C.goldLight, TextXAlignment = Enum.TextXAlignment.Center,
})
deathText(libTitleLbl, 2.2, true)
drips(libTitle, { 258, 312, 368, 424, 480, 526 }, 33)
addItem(lib, libTitle, 0, -20)
local libSub = cg(lg, UDim2.fromOffset(0, 62), UDim2.fromOffset(W, 20))
label(libSub, {
	Size = UDim2.fromScale(1, 1), Text = "Selecciona según el rendimiento de tu dispositivo",
	TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Center,
})
addItem(lib, libSub, 0, -14)

local libBusy = false
local libCards = {}

local function buildCard(page, x, y, title, bars, desc, key)
	local CW, CH = 300, 230
	local card = cg(page.group, UDim2.fromOffset(x, y), UDim2.fromOffset(CW, CH))
	card.BackgroundTransparency = 0.3
	card.BackgroundColor3 = C.panel2
	corner(card, 6)
	local st = stroke(card, C.gold, 1.5, 0.45)
	local stG = create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.goldDark),
			ColorSequenceKeypoint.new(0.5, C.goldLight),
			ColorSequenceKeypoint.new(1, C.goldDark),
		}),
	}, st)
	create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NSK(0, 0), NSK(1, 0.5) }) }, card)
	local sc = create("UIScale", {}, card)
	table.insert(libCards, card)

	local spot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(CW / 2, CH / 2),
		Size = UDim2.fromOffset(180, 180), BackgroundColor3 = C.gold,
		BackgroundTransparency = 1, BorderSizePixel = 0,
	}, card)
	corner(spot, 180)

	local inner = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, card)

	local bf = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(150, 24),
		Size = UDim2.fromOffset(50, 40), BackgroundTransparency = 1,
	}, inner)
	local heights = { 14, 26, 40 }
	local barObjs = {}
	for i = 1, 3 do
		local b = create("Frame", {
			Position = UDim2.fromOffset((i - 1) * 19, 40 - heights[i]), Size = UDim2.fromOffset(12, heights[i]),
			BackgroundColor3 = (i <= bars) and C.gold or C.goldDark,
			BackgroundTransparency = (i <= bars) and 0 or 0.5, BorderSizePixel = 0,
		}, bf)
		corner(b, 2)
		barObjs[i] = b
	end

	local tl = label(inner, {
		Position = UDim2.fromOffset(0, 80), Size = UDim2.fromOffset(300, 40), Text = title,
		Font = Enum.Font.Fantasy, TextSize = 34, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Center,
	})
	deathText(tl, 1.6)
	local ol = label(inner, {
		Position = UDim2.fromOffset(0, 122), Size = UDim2.fromOffset(300, 18), Text = "Open HUB",
		Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.gold, TextXAlignment = Enum.TextXAlignment.Center,
	})
	local dl = label(inner, {
		Position = UDim2.fromOffset(24, 146), Size = UDim2.fromOffset(252, 36), Text = desc,
		Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.dim, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top,
	})

	local strip = create("Frame", {
		Position = UDim2.fromOffset(0, 196), Size = UDim2.fromOffset(CW, 34),
		BackgroundColor3 = C.gold, BackgroundTransparency = 0.85, BorderSizePixel = 0, ClipsDescendants = true,
	}, card)
	local fill = create("Frame", {
		Size = UDim2.fromOffset(0, 34), BackgroundColor3 = C.goldLight,
		BackgroundTransparency = 0.55, BorderSizePixel = 0,
	}, strip)
	local sl = label(strip, {
		Size = UDim2.fromScale(1, 1), Text = "EJECUTAR", Font = Enum.Font.GothamBold, TextSize = 11,
		TextColor3 = C.goldLight, TextXAlignment = Enum.TextXAlignment.Center,
	})
	local arrow = create("Frame", {
		Position = UDim2.fromOffset(196, 12), Size = UDim2.fromOffset(8, 10), BackgroundTransparency = 1,
	}, strip)
	line(arrow, 1, 1, 6, 5, 2, C.goldLight, 0)
	line(arrow, 6, 5, 1, 9, 2, C.goldLight, 0)
	local topLine = create("Frame", {
		Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(0, 2),
		BackgroundColor3 = C.goldLight, BorderSizePixel = 0,
	}, strip)

	local btn = create("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5,
	}, card)

	local S = { hover = false, press = false }
	local scale, scaleV = 1, 0
	local rot, rotV = 0, 0
	local px, pxV = 0, 0
	local py, pyV = 0, 0
	local hk, spin = 0, 0
	local sx, sy = CW / 2, CH / 2
	local ax = 196

	local function shake() rotV = (rng:NextNumber() < 0.5 and -1 or 1) * 110 end

	table.insert(animators, function(t, dt)
		if not page.group.Visible then return end
		dt = math.min(dt, 1 / 30)
		local nx, ny = 0, 0
		if S.hover then
			local m = UserInputService:GetMouseLocation()
			local ap, as = card.AbsolutePosition, card.AbsoluteSize
			if as.X > 0 and as.Y > 0 then
				nx = math.clamp((m.X - ap.X) / as.X, 0, 1) - 0.5
				ny = math.clamp((m.Y - ap.Y) / as.Y, 0, 1) - 0.5
			end
		end
		local tScale = S.press and 0.97 or (S.hover and 1.045 or 1)
		scale, scaleV = spring(scale, scaleV, tScale, 220, 18, dt)
		rot, rotV = spring(rot, rotV, S.hover and nx * 5 or 0, 120, 14, dt)
		px, pxV = spring(px, pxV, S.hover and -nx * 12 or 0, 90, 13, dt)
		py, pyV = spring(py, pyV, S.hover and -ny * 8 or 0, 90, 13, dt)
		sc.Scale = scale
		card.Rotation = rot
		inner.Position = UDim2.fromOffset(px, py)

		hk += ((S.hover and 1 or 0) - hk) * math.min(1, dt * 9)
		spin += (35 + 150 * hk) * dt
		stG.Rotation = spin % 360
		st.Transparency = 0.45 - 0.4 * hk
		strip.BackgroundTransparency = 0.85 - 0.3 * hk
		topLine.Size = UDim2.fromOffset(CW * hk, 2)
		tl.TextColor3 = C.text:Lerp(C.goldLight, hk)

		sx += ((nx + 0.5) * CW - sx) * math.min(1, dt * 12)
		sy += ((ny + 0.5) * CH - sy) * math.min(1, dt * 12)
		spot.Position = UDim2.fromOffset(sx, sy)
		spot.BackgroundTransparency = 1 - 0.14 * hk

		ax += ((S.hover and 204 or 196) - ax) * math.min(1, dt * 12)
		arrow.Position = UDim2.fromOffset(ax, 12)

		for i = 1, bars do
			local w = 0.5 + 0.5 * math.sin(t * 2.4 - i * 0.8)
			barObjs[i].BackgroundColor3 = C.gold:Lerp(C.goldLight, math.clamp(0.7 * hk + 0.3 * w, 0, 1))
		end
	end)

	hook(btn, {
		enter = function() S.hover = true end,
		leave = function() S.hover = false; S.press = false end,
		down = function() S.press = true end,
		up = function() S.press = false end,
		click = function()
			if libBusy then return end
			local url = CONFIG.Links[key]
			if not url or url == "" then
				shake()
				notify("Aún no hay link para " .. title)
				return
			end
			libBusy = true
			scaleV += 1.2
			sl.Text = "CARGANDO"
			arrow.Visible = false
			tw(fill, 0.7, { Size = UDim2.fromOffset(CW, 34) }, ES.Quart, ED.InOut)
			for _, c in ipairs(libCards) do
				if c ~= card then tw(c, 0.4, { GroupTransparency = 0.75 }) end
			end
			task.wait(0.8)
			launch(key, title)
		end,
	})

	table.insert(page.reveals, function(delay)
		for i, b in ipairs(barObjs) do
			b.Size = UDim2.fromOffset(12, 0)
			b.Position = UDim2.fromOffset((i - 1) * 19, 40)
		end
		tl.Position = UDim2.fromOffset(0, 98); tl.TextTransparency = 1
		ol.Position = UDim2.fromOffset(0, 138); ol.TextTransparency = 1
		dl.Position = UDim2.fromOffset(24, 160); dl.TextTransparency = 1
		strip.Position = UDim2.fromOffset(0, CH)
		task.delay(delay, function()
			if not alive then return end
			for i, b in ipairs(barObjs) do
				task.delay((i - 1) * 0.09, function()
					if not alive then return end
					tw(b, 0.55, {
						Size = UDim2.fromOffset(12, heights[i]),
						Position = UDim2.fromOffset((i - 1) * 19, 40 - heights[i]),
					}, ES.Back)
				end)
			end
			tw(tl, 0.7, { Position = UDim2.fromOffset(0, 80), TextTransparency = 0 })
			task.delay(0.08, function()
				if alive then tw(ol, 0.7, { Position = UDim2.fromOffset(0, 122), TextTransparency = 0 }) end
			end)
			task.delay(0.16, function()
				if alive then tw(dl, 0.7, { Position = UDim2.fromOffset(24, 146), TextTransparency = 0 }) end
			end)
			task.delay(0.2, function()
				if alive then tw(strip, 0.6, { Position = UDim2.fromOffset(0, 196) }, ES.Back) end
			end)
		end)
	end)

	addItem(page, card, 0, 56, ES.Back)
end

buildCard(lib, 75, 106, "GAMA BAJA", 1, "Ligero y estable, pensado para dispositivos básicos.", "GamaBaja")
buildCard(lib, 405, 106, "GAMA ALTA", 3, "Máximo rendimiento y todas las funciones activadas.", "GamaAlta")

local cr = newPage("creator")
local crg = cr.group

local c1 = cg(crg, UDim2.fromOffset(0, 70), UDim2.fromOffset(W, 20))
label(c1, {
	Size = UDim2.fromScale(1, 1), Text = "C R E A D O   P O R", Font = Enum.Font.GothamBold, TextSize = 12,
	TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Center,
})
addItem(cr, c1, 0, -16)

local c2 = cg(crg, UDim2.fromOffset(0, 98), UDim2.fromOffset(W, 96))
local byLabel = label(c2, {
	Size = UDim2.fromScale(1, 1), Text = "By " .. CONFIG.Creator, Font = Enum.Font.Fantasy, TextSize = 76,
	TextColor3 = C.goldLight, TextXAlignment = Enum.TextXAlignment.Center,
})
deathText(byLabel, 2.6, true)
drips(c2, { 250, 304, 356, 412, 466, 514 }, 64)
addItem(cr, c2, 0, 24)

local c3 = cg(crg, UDim2.fromOffset(W / 2 - 160, 208), UDim2.fromOffset(320, 12))
local lineL = create("Frame", {
	Position = UDim2.fromOffset(0, 5), Size = UDim2.fromOffset(140, 1), BackgroundColor3 = C.gold, BorderSizePixel = 0,
}, c3)
create("UIGradient", { Transparency = NumberSequence.new({ NSK(0, 1), NSK(1, 0.1) }) }, lineL)
local lineR = create("Frame", {
	Position = UDim2.fromOffset(180, 5), Size = UDim2.fromOffset(140, 1), BackgroundColor3 = C.gold, BorderSizePixel = 0,
}, c3)
create("UIGradient", { Transparency = NumberSequence.new({ NSK(0, 0.1), NSK(1, 1) }) }, lineR)
local dia = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(160, 5.5), Size = UDim2.fromOffset(9, 9),
	BackgroundColor3 = C.goldLight, BorderSizePixel = 0, Rotation = 45,
}, c3)
table.insert(spinners, { obj = dia, speed = 40, rot = 45 })
addItem(cr, c3, 0, 16)

local c4 = cg(crg, UDim2.fromOffset(0, 236), UDim2.fromOffset(W, 22))
label(c4, {
	Size = UDim2.fromScale(1, 1), Text = "Open HUB  ·  " .. CONFIG.Version, Font = Enum.Font.GothamBold,
	TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Center,
})
addItem(cr, c4, 0, 16)
local c5 = cg(crg, UDim2.fromOffset(0, 262), UDim2.fromOffset(W, 20))
label(c5, {
	Size = UDim2.fromScale(1, 1), Text = "Gracias por usar Open HUB", TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Center,
})
addItem(cr, c5, 0, 16)

local glitchLayer = create("Frame", {
	Name = "Glitch", Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1,
	ClipsDescendants = true, ZIndex = 45, Active = false,
}, window)
local sweep = create("Frame", {
	Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, -30),
	BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.95, BorderSizePixel = 0, ZIndex = 45,
}, glitchLayer)
create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NSK(0, 1), NSK(0.5, 0), NSK(1, 1) }) }, sweep)

local glitchColors = { Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 170), C.gold }
local gNext, gUntil, gBars = 4, 0, {}
table.insert(animators, function(t)
	sweep.Position = UDim2.fromOffset(0, ((t * 55) % (H + 120)) - 60)

	local ready = window.GroupTransparency < 0.3 and not closing
	if ready and t >= gNext and t >= gUntil then
		local dur = rng:NextNumber(0.07, 0.16)
		gUntil = t + dur
		gNext = t + dur + rng:NextNumber(3, 7)
		for _ = 1, rng:NextInteger(2, 3) do
			local h = rng:NextInteger(2, 6)
			local w = rng:NextInteger(80, 260)
			local bar = create("Frame", {
				Position = UDim2.fromOffset(rng:NextInteger(0, W - w), rng:NextInteger(0, H - h)),
				Size = UDim2.fromOffset(w, h),
				BackgroundColor3 = glitchColors[rng:NextInteger(1, #glitchColors)],
				BackgroundTransparency = rng:NextNumber(0.55, 0.8),
				BorderSizePixel = 0, ZIndex = 45,
			}, glitchLayer)
			table.insert(gBars, bar)
		end
		window.Position = UDim2.new(0.5, rng:NextInteger(-2, 2), 0.5, rng:NextInteger(-1, 1))
	elseif #gBars > 0 and t >= gUntil then
		for _, b in ipairs(gBars) do b:Destroy() end
		table.clear(gBars)
		window.Position = UDim2.fromScale(0.5, 0.5)
	end
end)

local elapsed, frames, acc = 0, 0, 0
conns.hb = RunService.Heartbeat:Connect(function(dt)
	elapsed += dt

	local vis = pvVal.Value
	for i = #particles, 1, -1 do
		local p = particles[i]
		p.t += dt
		if p.ambient then
			p.y -= p.speed * dt
			if p.y < -0.05 then
				p.y = 1.05
				p.x = rng:NextNumber()
			end
			local px = p.x + math.sin(p.t * p.freq + p.phase) * p.sway
			p.f.Position = UDim2.fromScale(px, p.y)
			local edge = math.clamp(math.min(p.y, 1 - p.y) * 6, 0, 1)
			p.f.BackgroundTransparency = 1 - p.maxA * edge * vis
		else
			local drag = 1 - 1.6 * dt
			p.vx *= drag
			p.vy *= drag
			p.x += p.vx * dt
			p.y += p.vy * dt
			local k = p.t / p.max
			if k >= 1 then
				p.f:Destroy()
				table.remove(particles, i)
			else
				p.f.Position = UDim2.fromScale(p.x, p.y)
				p.f.BackgroundTransparency = 1 - p.maxA * (1 - k)
			end
		end
	end

	for i = #spinners, 1, -1 do
		local s = spinners[i]
		if s.obj.Parent then
			s.rot += s.speed * dt
			s.obj.Rotation = s.rot
		else
			table.remove(spinners, i)
		end
	end
	local pulse = 1 + 0.04 * math.sin(elapsed * 2)
	for _, ps in ipairs(pulses) do ps.Scale = pulse end
	for i = #animators, 1, -1 do
		local ok, err = pcall(animators[i], elapsed, dt)
		if not ok then
			warn("[Open HUB] animación desactivada: " .. tostring(err))
			table.remove(animators, i)
		end
	end

	frames += 1
	acc += dt
	if acc >= 0.5 then
		local fps = math.floor(frames / acc + 0.5)
		frames, acc = 0, 0
		local ping = "--"
		pcall(function()
			ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))
		end)
		statsLabel.Text = fps .. " FPS  ·  " .. ping .. " ms"
	end
end)

local function playIntro()
	local introBG = create("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 100,
	}, gui)
	local root = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(700, 400), BackgroundTransparency = 1, ZIndex = 101,
	}, gui)
	create("UIScale", { Scale = baseScale }, root)

	tw(backdrop, 1.5, { BackgroundTransparency = 0.05 })
	tw(blur, 1.5, { Size = 16 })
	tw(pvVal, 2.5, { Value = 1 })

	local r1 = ring(root, 10, 0, true, C.gold, 1.5, 1, 5)
	local r2 = ring(root, 10, 45, false, C.goldLight, 1.5, 1, -14)
	local r1s, r2s = r1:FindFirstChildOfClass("UIStroke"), r2:FindFirstChildOfClass("UIStroke")
	tw(r1, 1.2, { Size = UDim2.fromOffset(330, 330) }, ES.Back)
	tw(r2, 1.2, { Size = UDim2.fromOffset(230, 230) }, ES.Back)
	tw(r1s, 1.2, { Transparency = 0.35 })
	tw(r2s, 1.2, { Transparency = 0.5 })
	sfx(CONFIG.Sounds.Click, 0.5, 0.6)

	local titleRow = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(350, 200),
		Size = UDim2.fromOffset(500, 90), BackgroundTransparency = 1,
	}, root)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, titleRow)

	local letters = {}
	local word = "OPEN HUB"
	for i = 1, #word do
		local ch = word:sub(i, i)
		local holder = create("Frame", {
			Size = UDim2.fromOffset(ch == " " and 26 or 46, 90), BackgroundTransparency = 1, LayoutOrder = i,
		}, titleRow)
		if ch ~= " " then
			local l = label(holder, {
				Position = UDim2.fromOffset(0, 26), Size = UDim2.fromScale(1, 1), Text = ch,
				Font = Enum.Font.Fantasy, TextSize = 74, TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1,
			})
			local ls = stroke(l, Color3.fromRGB(34, 12, 44), 2.2, 1)
			local ds = {}
			table.insert(letters, { l = l, s = ls, drips = ds })
		end
	end

	local line = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(350, 262), Size = UDim2.fromOffset(0, 1),
		BackgroundColor3 = C.gold, BorderSizePixel = 0,
	}, root)
	create("UIGradient", { Transparency = NumberSequence.new({ NSK(0, 1), NSK(0.5, 0), NSK(1, 1) }) }, line)
	local sub = label(root, {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(350, 290), Size = UDim2.fromOffset(300, 20),
		Text = "B Y   " .. string.upper(CONFIG.Creator):gsub(".", "%0 "), Font = Enum.Font.GothamBold, TextSize = 12,
		TextColor3 = C.gold, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1,
	})

	task.wait(0.5)
	tw(line, 1, { Size = UDim2.fromOffset(460, 1) })
	for i, d in ipairs(letters) do
		tw(d.l, 0.55, { Position = UDim2.fromOffset(0, 0), TextTransparency = 0 }, ES.Back)
		tw(d.l, 0.9, { TextColor3 = Color3.fromRGB(234, 220, 202) })
		tw(d.s, 0.6, { Transparency = 0.1 })
		for _, dd in ipairs(d.drips) do
			task.delay(0.45, function()
				if alive then
					tw(dd.f, rng:NextNumber(1.2, 2.2), { Size = UDim2.fromOffset(dd.f.Size.X.Offset, dd.len) }, ES.Sine)
				end
			end)
		end
		sfx(CONFIG.Sounds.Hover, 0.25, 0.8 + i * 0.07)
		if i % 3 == 0 then burst(3, 0.5, 0.5) end
		task.wait(0.09)
	end
	tw(sub, 0.8, { TextTransparency = 0 })
	task.wait(0.8)

	burst(26, 0.5, 0.5)
	sfx(CONFIG.Sounds.Click, 0.7, 0.5)
	local flash = create("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.goldLight, BackgroundTransparency = 0.8,
		BorderSizePixel = 0, ZIndex = 103,
	}, gui)
	tw(flash, 0.7, { BackgroundTransparency = 1 })
	Debris:AddItem(flash, 1)

	for i, d in ipairs(letters) do
		task.delay(0.03 * i, function()
			if not alive then return end
			tw(d.l, 0.6, { Position = UDim2.fromOffset(0, -34), TextTransparency = 1 }, ES.Quint, ED.In)
			tw(d.s, 0.5, { Transparency = 1 })
			for _, dd in ipairs(d.drips) do tw(dd.f, 0.4, { BackgroundTransparency = 1 }) end
		end)
	end
	tw(sub, 0.4, { TextTransparency = 1 })
	tw(line, 0.5, { Size = UDim2.fromOffset(700, 1) })
	tw(r1, 0.8, { Size = UDim2.fromOffset(620, 620) }, ES.Quint, ED.In)
	tw(r2, 0.8, { Size = UDim2.fromOffset(460, 460) }, ES.Quint, ED.In)
	tw(r1s, 0.8, { Transparency = 1 })
	tw(r2s, 0.8, { Transparency = 1 })
	task.wait(0.55)

	tw(introBG, 1, { BackgroundTransparency = 1 })
	tw(window, 0.9, { GroupTransparency = 0 })
	tw(scaleVal, 0.9, { Value = 1 }, ES.Back)
	sfx(CONFIG.Sounds.Hover, 0.4, 0.7)
	task.wait(0.35)
	goTo("home")
	task.wait(0.8)
	root:Destroy()
	introBG:Destroy()
end

pcall(function()
	music:Play()
	tw(music, CONFIG.Music.FadeIn, { Volume = CONFIG.Music.Volume }, ES.Sine)
end)

task.spawn(function()
	local ok, err = pcall(playIntro)
	if not ok and alive then
		warn("[Open HUB] Error en la intro: " .. tostring(err))
		window.GroupTransparency = 0
		scaleVal.Value = 1
		backdrop.BackgroundTransparency = 0.05
		pvVal.Value = 1
		blur.Size = 16
		goTo("home")
	end
end)
