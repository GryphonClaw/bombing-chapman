class Block < GridObject
    def initialize(args, x, y, explodable)
        super args, x, y
        @solid = true


        @explodable = explodable
        if @explodable
            @sprite_path = "sprites/block_explodable.png"
        else
            @sprite_path = "sprites/block_solid.png"
        end
    end

    def editor_description
        "Block#{@explodable ? " (Explodable)" : " (Solid)"}"
    end

    def can_die
        @explodable
    end

    def can_contain_powerup
        @explodable
    end

    def tick
    end

    def set_powerup(type)

        @meta_data[:powerup] = type

        puts "Block::set_powerup: #{@meta_data[:powerup]}"
    end

    def draw
        output = []
        output << {x: @x, y: @y, w: 32, h: 32, path: @sprite_path, primitive_marker: :sprite}
        if in_editor()
            #only add to output if in editor and has a power up
            if has_powerup()
              output << embeded_powerup_graphic()
            end
        end
        output
    end

    def has_powerup
        @meta_data.key?(:powerup)
    end

  def serialize
    {x: @x, y: @y, solid: @solid, cellTYpe: "Block", explodable: @explodable}
  end
  def inspect
    serialize.to_s
  end
  def to_s
    serialize.to_s
  end
end