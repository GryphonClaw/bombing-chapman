class Powerup < GridObject
    
    #class vars
    @@types = {
        BombUp: {w: 32, h: 32, path: "sprites/bomb_capacity_up.png"},
        # BombDown: {w: 32, h: 32, path: "sprites/bomb_capacity_down.png"},
        SpeedUp: {w: 32, h: 32, path: "sprites/speed_up.png"},
        # SpeedDown: {w: 32, h: 32, path: "sprites/speed_down.png"},
        ExplosionUp: {w: 32, h: 32, path: "sprites/explosion_up.png"},
        # ExplosionDown: {w: 32, h: 32, path: "sprites/explosion_down.png"}
    }

    def self.types
       @@types.keys
    end
    #end class vars

    def initialize(args, x, y, type)
        raise "Error: #{type} is not a valid Powerup type" unless @@types.key?(type) 
        super(args, x, y)
        @solid = false
        @type = type

        @sprite_path = @@types[@type]

    end

    def rect
        {x: @x, y: @y, w: @w, h: @h}
    end

    def editor_description
        "Powerup: #{type}"
    end

    def tick
    end

    def serialize
        {x: @x, y: @y, solid: @solid, cellTYpe: "Powerup", type: @type}
    end
    def inspect
        serialize.to_s
    end
    def to_s
        serialize.to_s
    end

    def draw
        position.merge({**@@types[@type], primitive_marker: :sprite})
    end

    def position
        {x: @x, y: @y}
    end

    def can_die
        true
    end
end