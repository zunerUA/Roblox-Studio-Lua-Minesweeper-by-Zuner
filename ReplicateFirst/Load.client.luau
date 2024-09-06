if not game:IsLoaded() then game.Loaded:Wait() end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Minesweeper = require(ReplicatedStorage.Minesweeper)
local Configuration = require(ReplicatedStorage.Configuration)

local CellSelection = ReplicatedStorage:WaitForChild("CellSelection")

local board = Minesweeper.new(Configuration.GRID_SIZE, Configuration.MINES)


CellSelection.Event:Connect(function(cell: BasePart, isMouseButton1Down: boolean)
    if isMouseButton1Down then
        board:makeMove(cell)
    else
        board:tagMine(cell)
    end
end)
