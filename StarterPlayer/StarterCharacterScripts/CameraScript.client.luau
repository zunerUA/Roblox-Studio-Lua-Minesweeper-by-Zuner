local RunService = game:GetService("RunService")

local function calculateBoundingBox(parts: {[number]: BasePart}): CFrame
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

    for _, part in parts do
        if part:IsA("BasePart") then
            local cframe = part.CFrame
            local size = part.Size / 2
            local corners = {
                cframe * Vector3.new(size.X, size.Y, size.Z),
                cframe * Vector3.new(-size.X, size.Y, size.Z),
                cframe * Vector3.new(size.X, -size.Y, size.Z),
                cframe * Vector3.new(size.X, size.Y, -size.Z),
                cframe * Vector3.new(-size.X, -size.Y, size.Z),
                cframe * Vector3.new(size.X, -size.Y, -size.Z),
                cframe * Vector3.new(-size.X, size.Y, -size.Z),
                cframe * Vector3.new(-size.X, -size.Y, -size.Z),
            }
            for _, corner in corners do
                minX = math.min(minX, corner.X)
                minY = math.min(minY, corner.Y)
                minZ = math.min(minZ, corner.Z)

                maxX = math.max(maxX, corner.X)
                maxY = math.max(maxY, corner.Y)
                maxZ = math.max(maxZ, corner.Z)
            end
        end
    end

    local center = Vector3.new((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2)

    local size = Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)

    return CFrame.new(center), size
end

local camera = workspace.CurrentCamera
local rotation = CFrame.Angles(math.rad(-90), 0, 0)

local Configuration = require(game.ReplicatedStorage.Configuration)

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local ScreenGui = playerGui:WaitForChild("ScreenGui")
local WinScreen = playerGui:WaitForChild("WinScreen")

local isWin = false

local timePlaying

camera.CameraType = Enum.CameraType.Scriptable

local function updateMinesTitle()
    ScreenGui.Mines.Text = `Mines: {Configuration.MINES}`
end
updateMinesTitle()

local function hide()
    task.delay(Configuration.RESTART_LOOP, function()
        WinScreen.Enabled = false
        updateMinesTitle()
    end)
end

RunService.RenderStepped:Connect(function(deltaTime: number) 
    if not workspace:FindFirstChild("Minesweeper") then isWin = false return end
    
    local Minesweeper = workspace:FindFirstChild("Minesweeper")
    
    local size: Vector2 = Minesweeper:GetAttribute("size")
    
    if not timePlaying then
        timePlaying = tick()
    end
    
    if Minesweeper:HasTag(Configuration.TAGS.WIN) then
        if not isWin then
            isWin = true
            
            WinScreen.Enabled = true
            
            local duration = tick() - timePlaying
            local seconds = duration % 60
            
            local seconds = duration % 60
            local minutes = (duration/60)%60
            local hours = (duration/3600) % 12
            
            WinScreen.Time.Text = "Time played: " .. string.format("%02dh:%02dm:%02ds", hours, minutes, seconds)
            hide()
        end
    elseif Minesweeper:HasTag(Configuration.TAGS.GAME_OVER) then
        ScreenGui.Mines.Text = `Mines: {Configuration.MINES}`
    end
    
    local part1, part2 = Minesweeper:FindFirstChild("11"), Minesweeper:FindFirstChild(size.X .. size.Y)
    
    local boundingBox = calculateBoundingBox({part1, part2})
    
    camera.CFrame = camera.CFrame:Lerp( boundingBox * rotation, 0.1) + Vector3.new(0, #Minesweeper:GetChildren()/boundingBox.Position.Magnitude, 0)
end)
