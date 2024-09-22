--[[// YTeber112's Engine]]

local _tCore = {}
local _tEngine = {}
local V3Zero = Vector3.new(0,0,0)
local FRAME_SPEED = 1 / 60
local script = script
local version = "1"

warn("tEngine, Version: ".. version)

if not game:IsLoaded() then
    repeat
        task.wait(0.2)
    until game:IsLoaded()
end
ArtificialHB = Instance.new("BindableEvent", script)
ArtificialHB.Name = "ArtificialHB"

script:WaitForChild("ArtificialHB")

frame = FRAME_SPEED
tf = 0
allowframeloss = false
tossremainder = false
lastframe = tick()
script.ArtificialHB:Fire()

game:GetService("RunService").Heartbeat:connect(function(s, p)
    tf = tf + s
    if tf >= frame then
        if allowframeloss then
            ArtificialHB:Fire()
            lastframe = tick()
        else
            for i = 1, math.floor(tf / frame) do
                ArtificialHB:Fire()
            end
            lastframe = tick()
        end
        if tossremainder then
            tf = 0
        else
            tf = tf - frame * math.floor(tf / frame)
        end
    end
end)

_tCore.ch = function(func: _function) --[[// Cache func]]
    return setmetatable({}, {
        __index = function(self, key)
            local success, value = xpcall(function()
                return func(key)
            end, function()
            warn("ERROR (cache): A Critical error happened at tcore cache.")
            return
            end)

            if success then
                self[key] = value
                return value
            else warn("ERROR (cache): A Critical error happened at tcore cache.") return end
        end
    })
end

_tCore.type_check = function(argument_position: number, value: any, allowed_types: {any}, optional: boolean?)
	local formatted_arguments = table.concat(allowed_types, " or ")

	if value == nil and not optional and not table.find(allowed_types, "nil") then
		error(("ERROR: missing argument #%d (expected %s)"):format(argument_position, formatted_arguments), 0)
	elseif value == nil and optional == true then
		return value
	end

	if not (table.find(allowed_types, typeof(value)) or table.find(allowed_types, type(value)) or table.find(allowed_types, value)) and not table.find(allowed_types, "any") then
		error(("ERROR: invalid argument #%d (expected %s, got %s)"):format(argument_position, formatted_arguments, typeof(value)), 0)
	end

	return value
end

_tCore.newFunction = function(name: {string}, value: any)
    _tCore.type_check(1, name, {"string"})
    _tEngine[name] = value
end

_tEngine.srv = _tCore.ch(function(srv_name: string) --[[// js Get Service]]
    _tCore.type_check(1, srv_name, {"string"})
    success = xpcall(function()
        cloneref(game:GetService(srv_name))
    end, function()
    warn("ERROR (service): Error while trying get this service: "..srv_name)
    return
    end)
    if success then return cloneref(game:GetService(srv_name)) else warn("ERROR (service): Error while trying get this service: "..srv_name) return end
end)

_tCore.newFunction("netless", function(block: Instance | any, vel: bool) --[[// netless, just changing some properties]]
    _tCore.type_check(1, block, {"Instance"}, false)
    _tCore.type_check(2, vel, {"bool"}, true)
    if vel then
    block:ApplyAngularImpulse(Vector3.new())
    block:ApplyImpulse(Vector3.new(0,0,-25.8))
    end
    block.RootPriority = 127
    block.CanCollide = false
    block.Massless = true
    block.CanTouch = false
    block.CanQuery = false
    block.CastShadow = false
    block.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0.001, 0.001, 0.001, 0.001)
    if sethiddenproperty then sethiddenproperty(block, "NetworkIsSleeping", false) end
    if vel then block.Velocity = V3Zero end
    return
end)

_tCore.newFunction("clrforces", function(block: Instance | any, vel: bool) --[[// clear all forces, BodyForce, BodyGyro, etc...]]
    _tCore.type_check(1, block, {"Instance"}, false)
    _tCore.type_check(2, vel, {"bool"}, true)
    for _, v in pairs(block:GetChildren()) do if v:IsA("BodyAngularVelocity") or v:IsA("BodyLinearVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("BodyGyro") or v:IsA("SpringConstraint") or v:IsA("HingeConstraint") or v:IsA("BodyPosition") or v:IsA("BodyThrust") or v:IsA("RodConstraint") or v:IsA("BodyVelocity") or v:IsA("RocketPropulsion") or v:IsA("AlignPosition") or v:IsA("AlignOrientation") or v:IsA("Attachment") then v:Destroy() end end
    if vel then
        block.AssemblyAngularVelocity = V3Zero
        block.AssemblyLinearVelocity = V3Zero
    end
    return
end)

_tCore.newFunction("getRoot", function(CHAR: Character) 
    _tCore.type_check(1, CHAR, {"Instance"})
	return CHAR:WaitForChild('HumanoidRootPart') or CHAR:WaitForChild('Torso') or CHAR:WaitForChild('UpperTorso')
end)

_tCore.newFunction("getCharacter", function(PLR: Player)
    _tCore.type_check(1, PLR, {"Instance"})
    return PLR.Character or PLR.CharacterAdded:Wait()
end)

_tCore.newFunction("FEToolgrip", function(tool: string | nil, grip: any) --[[// Changes the toolgrip of the tool (NOISE WARNING LOL).]]
    _tCore.type_check(1, tool, {"string", "nil"})
    _tCore.type_check(2, grip, {"Vector3"})
    lp = _tEngine.srv.Players.LocalPlayer
    if tool then
    for _, v in pairs(_tEngine.getCharacter(lp):GetChildren()) do
        if v:IsA("Tool") and v.Name == tool then
            v.Parent = lp.Backpack
            v.GripPos = grip
            v.Parent = lp.Character
        end
    end
    for _, v in pairs(lp.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name == tool then
            v.GripPos = grip
            v.Parent = lp.Character
        end
    end
    else
        for _, v in pairs(_tEngine.getCharacter(lp):GetChildren()) do
            if v:IsA("Tool") then
                v.Parent = lp.Backpack
                v.GripPos = grip
                v.Parent = lp.Character
            end
        end
        for _, v in pairs(lp.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                v.GripPos = grip
                v.Parent = lp.Character
            end
        end
    end
end)

_tCore.newFunction("Swait", function(NUMBER: float | nil) --[[// Classic artificialHeartbeat wait.]]
    _tCore.type_check(1, NUMBER, {"number", "nil"})
    if NUMBER == 0 or NUMBER == nil then
		ArtificialHB.Event:wait()
	else
		for i = 1, NUMBER do
			ArtificialHB.Event:wait()
		end
	end
end)

_tCore.newFunction("isTools", function(PLR: Player) --[[// Check if there is tools in the player]]
    _tCore.type_check(1, PLR, {"Instance"})
    for _, v in pairs(_tEngine.getCharacter(PLR):GetChildren()) do
        if v:IsA("Tool") then
            return true
        end
    end
    for _, v in pairs(PLR.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            return true
        end
    end
    return false
end)

_tCore.newFunction("equipTools", function(AMMOUNT: int) --[[// Equip AMMOUNT of tools in the player.]]
    _tCore.type_check(1, AMMOUNT, {"number"})
    count = 0
    for _, v in pairs(_tEngine.srv.Players.LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = _tEngine.getCharacter()
            count += 1
            if count >= AMMOUNT then
                break
            end
        end
    end
end)

_tCore.newFunction("getMotors6Ds", function() --[[// Get motors6Ds, useful for desired angle reanimations.]]
    motors = {}
    for _, motor in pairs(_tEngine.getCharacter(_tEngine.srv.Players.LocalPlayer):GetChildren()) do
        if motor:IsA("Motor6D") then
            motors[motor] = 0
        end
    end
    return motors
end)

_tCore.newFunction("Ping", function() --[[// just ping]]
    return _tEngine.srv.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end)

_tCore.newFunction("Prevision", function(POSITION: Position, VELOCITY: Position) --[[// Prevision, useful for Teleports.]]
    ping = _tEngine.Ping() / 750
    return POSITION + VELOCITY * (ping * 3)
end)

return _tEngine
--[[//Credits to xAPI Project (_Exploit Simulator for roblox studio)]]
