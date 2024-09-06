local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local CellSelection = ReplicatedStorage:WaitForChild("CellSelection")

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local ScreenGui = playerGui:WaitForChild("ScreenGui")

local mouse = player:GetMouse()

local Configuration = require(ReplicatedStorage.Configuration)
local cell

RunService.RenderStepped:Connect(function(deltaTime: number) 
    local target = mouse.Target
    local board = workspace:FindFirstChild("Minesweeper")
    local mines = Configuration.MINES-#CollectionService:GetTagged(Configuration.TAGS.MINE_TAGGED)
    
    ScreenGui.Mines.Text = `Mines: {mines}`
    
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
        if not minesweeper then return end
        if minesweeper:HasTag(Configuration.TAGS.WIN) or minesweeper:HasTag(Configuration.TAGS.GAME_OVER) then mines = Configuration.MINES return end
        
        local mines = Configuration.MINES-#CollectionService:GetTagged(Configuration.TAGS.MINE_TAGGED)
        
        if mines == 0 then return end
        
        CellSelection:Fire(cell, false)
    end
end)
