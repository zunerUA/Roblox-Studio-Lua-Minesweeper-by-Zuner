export type Grid = {X: number, Y: number}
export type Array<T> = {[number]: T}
export type MinesweeperClass = {
    __index: MinesweeperClass,
    new: (size: Grid, mines: number, seed: number?) -> Minesweeper,
    revealAllMines: () -> (),
    restart: () -> (),
    tagMine: (Part) -> (),
    makeMove: (Part) -> (),
    _isWin: () -> (boolean),
    _countMines: (Part) -> (),
    _getDirections: (Part) -> (Array<Vector2>),
    _createBoard: () -> (),
    _placeMines: () -> (),
    _createCell: (Vector3, Vector2) -> (),
    _addLabel: (Part, number) -> ()
    
}
export type MinesweeperClassInstance = {
    gameOver: boolean,
    isWin: boolean,
    board: Folder,
    size: Grid,
    mines: number
}
export type Minesweeper = typeof(setmetatable({} :: MinesweeperClass, {} ::  MinesweeperClass))


local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = require(ReplicatedStorage.Configuration)

local Minesweeper = {} :: MinesweeperClass
Minesweeper.__index = Minesweeper
-- сonstructors
function Minesweeper.new(size, mines, seed)
    local self = setmetatable({}, Minesweeper)
    self.gameOver = false
    self.isWin = false
    self.board = Instance.new("Folder", workspace)
    self.board.Name = "Minesweeper"
    self.size = size
    self.mines = mines
    self.board:SetAttribute("size", Vector2.new(size.X, size.Y))
    if seed then
        math.randomseed(seed)
    end
    self:_createBoard()

    return self
end
-- public methods
function Minesweeper:revealAllMines()
    for _, mine: BasePart in CollectionService:GetTagged(Configuration.TAGS.MINE) do
        mine.Color = Configuration.COLORS.MINE
    end
end
function Minesweeper:restart()
    self.gameOver = false
    self.isWin = false
    self.board:ClearAllChildren()
    for _, tag: string in CollectionService:GetTags(self.board) do
        self.board:RemoveTag(tag)
    end
    self:_createBoard()
end
function Minesweeper:tagMine(cell)
    if cell:HasTag(Configuration.TAGS.REVEALED) then return end
    if self.gameOVer or self.isWin then return end
    
    if cell:HasTag(Configuration.TAGS.MINE_TAGGED) then
        cell:RemoveTag(Configuration.TAGS.MINE_TAGGED)
    else
        cell:AddTag(Configuration.TAGS.MINE_TAGGED)
    end
    cell.Color = cell:HasTag(Configuration.TAGS.MINE_TAGGED) and Configuration.COLORS.MINE_TAG or Configuration.COLORS.UNKNOWN
end
function Minesweeper:makeMove(cell)
    if self.isWin or self.gameOver then return end
    if not next(CollectionService:GetTagged(Configuration.TAGS.REVEALED)) then self:_placeMines(cell) end
    local position = cell:GetAttribute(Configuration.ATTRIBUTES.CELL_POSITION)
    local mines = self:_countMines(cell)
    if cell:HasTag(Configuration.TAGS.MINE) then
        self:revealAllMines()
        self.gameOver = true
        self.board:AddTag(Configuration.TAGS.GAME_OVER)
        
        task.delay(Configuration.RESTART_LOOP, function()
            self:restart()
        end)
        return
    end
    cell:AddTag(Configuration.TAGS.REVEALED)
    cell:RemoveTag(Configuration.TAGS.MINE_TAGGED)
    if mines > 0 then
        self:_addLabel(cell, mines)
    elseif mines == 0 then
        for _, direction in self:_getDirections(cell) do
            local nearCell: BasePart = self.board:FindFirstChild(direction.X .. direction.Y)
            if nearCell then
                if not nearCell:HasTag(Configuration.TAGS.REVEALED) and not nearCell:HasTag(Configuration.TAGS.MINE) then
                    self:makeMove(nearCell)
                end
            end
        end
    end
    if self:_isWin() then
        self.board:AddTag(Configuration.TAGS.WIN)
        self.isWin = true
        task.delay(Configuration.RESTART_LOOP, function()
            self:restart()
        end)
    end
    cell.Color = Configuration.COLORS.REVEALED
end
-- private methods
function Minesweeper:_createBoard()
    local offset = Configuration.POSITION
    for i = 1, self.size.X do
        local yOffset = offset
        for j = 1, self.size.Y do
            self:_createCell(yOffset, Vector2.new(i, j))
            yOffset += Vector3.new(0, 0, Configuration.CELL_SIZE.Z+Configuration.PADDING)
        end
        offset += Vector3.new(Configuration.CELL_SIZE.X+Configuration.PADDING, 0, 0)
    end
end
function Minesweeper:_isWin()
    return (#CollectionService:GetTagged(Configuration.TAGS.MINE) + #CollectionService:GetTagged(Configuration.TAGS.REVEALED)) == self.size.X * self.size.Y
end
function Minesweeper:_countMines(cell)
    local mines = 0
    for _, direction: Vector2 in self:_getDirections(cell) do
        local nearCell: BasePart = self.board:FindFirstChild(direction.X .. direction.Y)
        if nearCell and nearCell:HasTag(Configuration.TAGS.MINE) then
            mines += 1
        end
    end
    return mines
end
function Minesweeper:_getDirections(cell)
    local position = cell:GetAttribute(Configuration.ATTRIBUTES.CELL_POSITION)
    local directions = {
        Vector2.new(position.X+1, position.Y),
        Vector2.new(position.X-1, position.Y),
        Vector2.new(position.X, position.Y+1),
        Vector2.new(position.X, position.Y-1),
        Vector2.new(position.X-1, position.Y+1),
        Vector2.new(position.X+1, position.Y-1),
        Vector2.new(position.X+1, position.Y+1),
        Vector2.new(position.X-1, position.Y-1),
    }
    return directions
end
function Minesweeper:_placeMines(startingCell)
    local mines = 1
    while mines <= self.mines do
        local rX, rY = math.random(1, self.size.X), math.random(1, self.size.Y)
        local cell: Part = self.board:FindFirstChild(rX .. rY)
        
        if cell == startingCell then continue end
        if cell:HasTag(Configuration.TAGS.MINE) then continue end
        cell:AddTag(Configuration.TAGS.MINE)

        mines += 1
    end
end
function Minesweeper:_addLabel(cell, number)
    local SurfaceGui = Instance.new("SurfaceGui", cell)
    SurfaceGui.Face = Enum.NormalId.Top

    local TextLabel = Instance.new("TextLabel", SurfaceGui)
    TextLabel.Rotation = 90
    TextLabel.FontFace = Font.fromName("PressStart2P")
    TextLabel.Size = UDim2.fromScale(1, 1)
    TextLabel.BackgroundTransparency = 1
    TextLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.RichText = true
    TextLabel.TextScaled = true
    TextLabel.Text = `<stroke color="#000000" thickness="3">{number}</stroke>`
end
function Minesweeper:_createCell(position, gridPosition)
    local part = Instance.new("Part", self.board)

    part:SetAttribute(Configuration.ATTRIBUTES.CELL_POSITION, gridPosition)
    part.Name = gridPosition.X .. gridPosition.Y
    part.Color = Configuration.COLORS.UNKNOWN
    part.Size = Configuration.CELL_SIZE
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.CastShadow = false
end
return Minesweeper
