class Player
    attr_accessor :x, :y
    attr_accessor :delta
  
    attr_reader :sprite, :direction
    attr_reader :speed_multiplier
    attr_reader :max_bombs

    attr_rect
    attr_reader :x, :y, :w, :h

    def initialize(args, x, y, width, height, init_direction = "Down")
      @args = args

      @draw_debug_info = true

      @x = x
      @y = y
      @w = width
      @h = height
      
      @direction = init_direction
  
      # @sprite = "sprites/bomberman2.png"
      @sprite = "sprites/ned.png"

      @speed_multiplier = 0.1

      @max_bombs = 1

      @settings = @args.state.settings

      @delta = {x: 0, y: 0}

      @draw_size = {w: 64, h: 64}
    end
  
    def draw()
      if @draw_debug_info
        @args.outputs.primitives << debug_info_label().to_label
      end
      sprite_info = properties_for_direction()
      sprite_info[direction.to_sym]
    end

    def process_input()
      if @args.keyboard.key_held.left
        @direction = "Left"
      elsif @args.keyboard.key_held.right
        @direction = "Right"
      end
    
      if @args.keyboard.key_held.up
        @direction = "Up"
      elsif @args.keyboard.key_held.down
        @direction = "Down"
      elsif @args.keyboard.key_held.s
        @direction = "YES!!!"
      end
    end

    def direction=
      @direction = direction
    end

    def debug_info_label()
      {x: @x + 16, y: @y, text: @direction, alignment_enum: 1, **Color::WHITE}
    end

    def position()
      {x: @x, y: @y}
    end

    def increase_max_bombs(amount)
      @max_bombs += amount
    end
    def speed_up(modifier = 0.1)
      @speed_multiplier += modifier
    end

    def collision_rect
      # {x: @x + 6, y: @y + 12, w: 24, h: 24}
      {x: @x, y: @y, w: 24, h: 24}
    end

    
    def properties_for_direction()
      {
        "Up": {
          **draw_position,
          **@draw_size,
          tile_x: 0, tile_y: 0, **tile_size,
          path: @sprite
        },
        "Right": {
          **draw_position,
          **@draw_size,
          tile_x: 0, tile_y: 64 * 3, **tile_size,
          path: @sprite
        },
        "Down": {
          **draw_position,
          **@draw_size,
          tile_x: 0, tile_y: 64 * 2, **tile_size,
          path: @sprite
        },
        "Left": {
          **draw_position,
          **@draw_size,
          tile_x: 0, tile_y: 64, **tile_size,
          path: @sprite
        },
        # "YES!!!": {
        #   **draw_position,
        #   **@draw_size,
        #   tile_x: 0, tile_y: 4*32, **tile_size,
        #   path: @sprite
        # }
      }
    end

    def movement_speed
      {x: 2 + @speed_multiplier, y: 2 + @speed_multiplier}
    end

    private
    def tile_size
      {tile_w: 64, tile_h: 64}
    end

    def draw_position
      {x: @x - 16, y: @y}
    end
  end