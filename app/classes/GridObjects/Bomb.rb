class Bomb < GridObject
    
    @@frames = [
        {x: 0, y: 0, w: 32, h: 32, tile_x: 0, tile_y: 0, tile_w: 32, tile_h: 32, r: 255, g: 255, b: 255},
        {x: 0, y: 0, w: 32, h: 32, tile_x: 32, tile_y: 0, tile_w: 32, tile_h: 32, r: 255, g: 255, b: 255},
        {x: 0, y: 0, w: 32, h: 32, tile_x: 64, tile_y: 0, tile_w: 32, tile_h: 32, r: 255, g: 255, b: 255}
    ]

    def self.frames
        @@frames
    end

    def initialize(args, x, y, time_to_live = 0, explode_by_remote = false)
        super(args, x, y)
        @solid = false
        @sprite_path = "sprites/bomb_2.png"
        @current_frame = 0
        @max_frames = Bomb.frames.length
        @hold_time = 20

        @type = :Bomb

        @can_die = true
        @should_die = false
        start = rand(@max_frames-1)
        @animation = {
            hold: 10,
            start_at: start,
            loops: true,
            frame_count: @max_frames
        }

        @ttl = time_to_live
        @exploded = false
    end

    def rect
        {x: @x, y: @y, w: @w, h: @h}
    end


    def tick
        @current_frame = @animation[:start_at].frame_index(
            @animation[:frame_count],
            @animation[:hold],
            @animation[:loops]
        )
        if @ttl > 0
            @ttl -= 1
        end
        if @ttl <= 0
            @should_die = true
        end
    end

    def serialize
        {x: @x, y: @y, solid: @solid, ttl: @ttl, type: @type}
    end

    def inspect
        serialize.to_s
    end
    def to_s
        serialize.to_s
    end

    def draw()
        x, y = @x, @y
        output = {
            x: x, y: y,
            w: 32, h: 32,
            tile_x: @current_frame * 32, tile_y: 0, tile_w: 32, tile_h: 32,
            path: @sprite_path
        }

        ttl = (@ttl/60).round
        ttl_str = ttl > 0 ? "#{ttl}" : "BOOM"
        count_down_timer_display = {
            x: x + 16, y: y + 16, text: "#{ttl_str}",
            **Color::WHITE, alignment_enum: 1
        }.to_label
        [output.to_sprite,
            count_down_timer_display]
    end

    def position
        {x: @x, y: @y}
    end


    def can_die
        @can_die
    end

    def invalidated
        @ttl <= 0
    end
end