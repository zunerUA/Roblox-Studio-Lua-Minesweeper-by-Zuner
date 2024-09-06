local Configuration = {}

-- amount of mines generated 
Configuration.MINES = 50
-- not reccomened to put more than 
Configuration.GRID_SIZE = Vector2.new(9, 9)
-- tags, doesn't affect the gameplay
Configuration.TAGS = {
    MINE_TAGGED = "TaggedMine",
    MINE = "Mine",
    REVEALED = "Revealed",
    GAME_OVER = "GameOver",
    WIN = "WIN"
}
-- attributes also doesn't affect the gameplay
Configuration.ATTRIBUTES = {
    CELL_POSITION = "position"
}
-- colors
Configuration.COLORS = {
    -- default cell color
    UNKNOWN = Color3.new(.3, .3, .3),
    -- mine tagged
    MINE_TAG = Color3.new(1, .5, 0),
    -- revealed
    REVEALED = Color3.new(1, 1, 1),
    -- mine revealed
    MINE = Color3.new(1, 0, 0)
}
-- board position offset
Configuration.POSITION = Vector3.new(5, 5, 5)
-- cell size
Configuration.CELL_SIZE = Vector3.new(3, 1, 3)
-- padding between cells
Configuration.PADDING = .3
-- time between game resets
Configuration.RESTART_LOOP = 3

table.freeze(Configuration)
return Configuration
