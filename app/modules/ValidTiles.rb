module ValidTiles
  GREEN_BRICK = "Brick:Green"
  RED_BRICK = "Brick:Red"
  YELLOW_BRICK = "Brick:Yellow"
  BLUE_BRICK = "Brick:Blue"

  EXPLODABLE_BLOCK = "Block:Explodable"
  SOLID_BLOCK = "Block:Solid"

  SPEED_UP = "Powerup:SpeedUp"
  FLAME_UP = "Powerup:FlameUp"
  BOMB_UP = "Powerup:BombUp"

  ALL_TILES = [
    GREEN_BRICK,
    RED_BRICK,
    YELLOW_BRICK,
    BLUE_BRICK,
    EXPLODABLE_BLOCK,
    SOLID_BLOCK,
    SPEED_UP,
    FLAME_UP,
    BOMB_UP
  ].freeze

  EMBEDABLE = [
    SPEED_UP,
    FLAME_UP,
    BOMB_UP
  ].freeze

  EXPLODABLE = [
    RED_BRICK,
    GREEN_BRICK,
    BLUE_BRICK,
    YELLOW_BRICK,

    EXPLODABLE_BLOCK
  ].freeze
end
