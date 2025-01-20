class Brick < GridObject

    def initialize args, x, y, tint = Color::RED
        super(args, x, y, 32, 32)

        @sprite_path = "sprites/brick.png"

        @color_tint = tint

        @solid = true
    end

    def tick
    end

    def draw
        output = []
        output << rect.merge({**@color_tint, path: @sprite_path, primitive_marker: :sprite})
        #only add thiis to the output if we are in the editor
        if in_editor()
            #only add to output if in editor and has a power up
            if has_powerup()
                output << embeded_powerup_graphic()
            end
        end
        output
    end

    def type
        :Brick
    end

    def can_die
        true
    end

    def serialize
        {x: @x, y: @y, w: @w, h: @h, type: type, meta_data: @meta_data}
    end

    def to_s
        serialize.to_s
    end

    def editor_description
        "Brick"
    end

    def can_contain_powerup
        true
    end

    def has_powerup
        @meta_data.key?(:powerup)
    end

    def set_powerup(type)

        @meta_data[:powerup] = type

    end

end