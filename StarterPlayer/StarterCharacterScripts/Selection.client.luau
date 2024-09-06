local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CellSelection = ReplicatedStorage:WaitForChild("CellSelection")

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local ScreenGui = playerGui:WaitForChild("ScreenGui")

local mouse = player:GetMouse()

local Configuration = require(ReplicatedStorage.Configuration)

local mines = Configuration.MINES
local cell

RunService.RenderStepped:Connect(function(deltaTime: number) 
    local target = mouse.Target
    local board = workspace:FindFirstChild("Minesweeper")
    
    if not board then return end
    if not target or not target:IsDescendantOf(board) then cell = nil return end
    if target:HasTag(Configuration.TAGS.REVEALED) then cell = nil return end
    
    
    cell = target
end)
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
    if gameProcessedEvent or not cell then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        CellSelection:Fire(cell, true)
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        local minesweeper = workspace:WaitForChild("Minesweeper")
        
        if not minesweeper or minesweeper:HasTag(Configuration.TAGS.WIN) or minesweeper:HasTag(Configuration.TAGS.GAME_OVER) then return end
        
        CellSelection:Fire(cell, false)
        
        local mines do
            local s = ScreenGui.Mines.Text
            local i, j = string.find(s, "%d+")
            
            mines = tonumber(string.sub(s, i, j))
        end
        
        
        if cell:HasTag("TaggedMine") then
            mines += 1
        else
            mines -= 1
        end
        
        ScreenGui.Mines.Text = `Mines: {mines}`
    end
end)
