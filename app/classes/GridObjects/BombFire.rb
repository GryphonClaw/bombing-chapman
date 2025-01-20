class BombFire < GridObject
    
  attr_reader :solid
  attr_reader :should_die
  attr_reader :invalidated

  def initialize(args, x, y, meta_data = {})
    super(args, x, y, 32, 32, meta_data)

    @sprite_path = "sprites/flame/flame_f00.png"
    @solid = true
    @type = :BombFire
    @frames = []
    (0..4).each do | index |
      @frames << "sprites/flame/flame_f#{"%02d" % index}.png"
    end
        
    @animation = {
        hold: 4,
        start_at: 0,
        loops: true,
        frame_count: 5
    }
    @ttl = 30
    @should_die = false
    @current_frame = 0
    @sprite_settings = {w: 32, h: 32, tile_x: 0, tile_y: 0, tile_w: 48, tile_h: 48, primitive_marker: :sprite}
  end

    def rect
        {x: @x, y: @y, w: @w, h: @h}
    end

    def can_die
        true
    end

    def tick
        @current_frame = @animation[:start_at].frame_index(
            @animation[:frame_count],
            @animation[:hold],
            @animation[:loops]
        )

        @current_frame ||= 0

        @sprite_path = @frames[@current_frame]
        if @ttl > 0
            @ttl -= 1
        end
        if @ttl <= 0
            @should_die = true
        end
    end

    def serialize
        {x: @x, y: @y, solid: @solid, name: "BombFire", type: @type, meta: @meta_data}
    end

    def inspect
        serialize.to_s
    end
    def to_s
        serialize.to_s
    end

    def draw()
        sprite = position.merge({path: @sprite_path, **@sprite_settings})
        debug = {x: @x + 12, y: @y + 20, text: "#{(@ttl/60).to_i}", alignment_enum: 1, **Color::BLUE}

        sprite
    end

    def position
        {x: @x, y: @y}
    end

    def can_contain_powerup
      true
    end

    def has_powerup
      return false unless @meta_data
      @meta_data.key?(:powerup)
    end
end