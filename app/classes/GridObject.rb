class GridObject
  attr_reader :solid
  attr_reader :should_die
  attr_reader :type

  attr_reader :x, :y, :w, :h

  attr_accessor :invalidated
  attr_reader :explodable
  
  attr_reader :meta_data

  def initialize(args, x, y, w = 32, h = 32, meta_data = {})
    @args = args

    @x = x
    @y = y
    @w = w
    @h = h

    @meta_data = meta_data

    @path = "sprites/block.png"
    @color_tint = {r: 255, g: 255, b: 255}

    @should_die = false
    @solid = false

    @explodable = true
  end

  def editor_description
    "Customize me"
  end
  def can_die
    false
  end

  def invalidated
    false
  end

  def tick
    puts "GridObject::tick - Override me for custom tick actions"
  end

  def draw
    puts "GridObject::draw - Override me for custom drawing."
    output = {x: @x, y: @y, w: 32, h: 32, path: @path, **@color_tint.to_sprite}
    output
  end

  def rect
    {x: @x, y: @y, w: @w, h: @h}
  end
  def position
    {x: @x, y: @y}
  end

  def collision_rect
    # puts "GridObject::collision_rect - Override me for custom collision rect"
    rect
  end

  def can_die
    puts "GridObject:can_die - Override me"
    false
  end

  def object_type
    "#{name}#{variation ? ":#{variation}" : ""}"
  end

  def can_contain_powerup
    false
  end

  def in_editor()
    @args.state.game.mode_edit
  end

  def has_metadata
    return false unless @meta_data
    not @meta_data.empty?
  end

  private
  def embeded_powerup_graphic
    output = []
    powerup = @meta_data[:powerup]
    case powerup
    when "Powerup:BombUp"
      powerup = "sprites/bomb_capacity_up.png"
    when "Powerup:FlameUp"
      powerup = "sprites/explosion_up.png"
    when "Powerup:SpeedUp"
      powerup = "sprites/speed_up.png"
    end
    if powerup
      case @args.state.settings.tile_embed_type
      when :centered
        output << {x: @x + 4, y: @y + 4, w: 24, h: 24, path: powerup, a: 128}.to_sprite
      when :full
        output << {x: @x, y: @y, w: 32, h: 32, path: powerup, a: 128}.to_sprite
      when :quarter_bl
        output << {x: @x, y: @y, w: 16, h: 16, path: powerup, a: 128}.to_sprite
      when :quarter_br
        output << {x: @x + 16, y: @y, w: 16, h: 16, path: powerup, a: 128}.to_sprite
      when :quarter_tl
        output << {x: @x, y: @y + 16, w: 16, h: 16, path: powerup, a: 128}.to_sprite
      when :quarter_tr
        output << {x: @x + 16, y: @y +16, w: 16, h: 16, path: powerup, a: 128}.to_sprite
      else
        output << {x: @x, y: @y, w: 32, h: 32, path: powerup, a: 128}.to_sprite
      end
    end
    output
  end
end