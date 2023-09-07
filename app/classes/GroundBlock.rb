class GroundBlock
    @@colors = {
        Red: {r: 128, g: 0, b: 0},
        Green: {r: 0, g: 128, b: 0},
        Blue: {r: 0, g: 0, b: 128},
        White: {r: 255, g: 255, b: 255},
        Gray: {r: 128, g: 128, b: 128},
        Black: {r: 0, g: 0, b: 0}
    }

    def self.colors
        @@colors
    end

    attr_reader :solid

    attr_rect
    attr_reader :x, :y, :w, :h

    def initialize(args, x, y, color, solid = false)
        @args = args
        @x = x
        @y = y
        @w = 32
        @h = 32
        @color = color
        @solid = solid
        @hide_solid = false
        @path = "sprites/block.png"
    end

    def rect
        {x: @x, y: @y, w: @w, h: @h}
    end

    def tick
    end

    def serialize
        {x: @x, y: @y, type: @type}
    end

    def inspect
        serialize.to_s
    end
    def to_s
        serialize.to_s
    end

    def toggle_hide_solid()
        @hide_solid = !@hide_solid
    end

    def draw()
        x, y = (@x * 32) + 64, (@y * 32) + 64
        output = { x: x, y: y, w: 32, h: 32,
            tile_x: 0, tile_y: 0, tile_w: 32, tile_h: 32,
            path: @path
        }.merge(GroundBlock.colors[@color])
        output.to_sprite
    end

    def position
        {x: @x, y: y }
    end
end