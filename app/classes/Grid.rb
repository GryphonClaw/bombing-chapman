class Grid
    attr_reader :cell_count_x, :cell_count_y
    attr_reader :draw_offset

    def initialize(args, cell_count_x, cell_count_y, offset = {x: 64, y: 64})
        @args = args
        @cell_count_x = cell_count_x
        @cell_count_y = cell_count_y

        @grid = []

        @explosions = []

        @draw_offset = offset

        init_grid(@cell_count_x, @cell_count_y)
    end

    def boundary_rect
        {x: @draw_offset.x + 32, y: @draw_offset.y + 32, w: (@cell_count_x - 1) * 32, h: (@cell_count_y - 2) * 32}
    end

    def tick
    end

    def should_draw_item_gfx
    end

    def draw
        items_to_draw = []
        @cell_count_x.times do | x |
            @cell_count_y.times do | y |
                if cell_occupied?(x, y)
                    items_to_draw << get_cell(x,y).draw()
                end
            end
        end

        items_to_draw = items_to_draw.reject_nil
        @args.outputs.primitives << items_to_draw
    end

    def cell_occupied?(x, y)
        return nil unless in_bounds(x, y)
        get_cell(x, y) != nil
    end

    def set_cell(x, y, value)
        return unless in_bounds(x, y)
        @grid[x][y] = value
    end

    def get_cell(x, y)
        return nil unless in_bounds(x, y)
        @grid[x][y]
    end

    def clear_cell(x, y)
        return unless in_bounds(x, y)
        @grid[x][y] = nil
    end

    def count(type)
        item_count = 0
        @cell_count_x.times do | x |
            @cell_count_y.times do | y |
                if cell_occupied?(x, y)
                    obj = get_cell(x, y)
                    if obj.type == type
                        item_count += 1
                    end
                end
            end
        end
        item_count
    end

    private
    def in_bounds(x, y)
        (x >= 0 && x < @cell_count_x) && (y >= 0 && y < @cell_count_y)
    end

    private
    def init_grid(cell_count_x, cell_count_y)
        cell_count_x.times do | x |
            @grid << []
            cell_count_y.times do | y |
                clear_cell(x, y)
            end
        end
    end

    private
    def validate_object(x, y, value)
        return unless value != nil
        has_tick = value.respond_to?(:tick)
        has_draw = value.respond_to?(:draw)
        if !has_tick
            puts "Object added to cell position #{x},#{y} does not respond to tick"
        end
        if !has_draw
            puts "Object added to cell position #{x},#{y} does not respond to draw"
        end
    end


    def objects
        list = []

        @cell_count_x.times do | x |
            @cell_count_y.times do | y |
                if cell_occupied?(x, y)
                    obj = get_cell(x, y)
                    list << obj.position.merge({w: 32, h: 32}).merge(object_rect_color(obj)).to_border
                end
            end
        end

        list
    end

    def object_rect_color(obj)
        case obj.type
        when :Powerup
            case obj.object.type
            when :BombUp
                Color::GREEN
            when :ExplosionUp
                Color::YELLOW
            when :SpeedUp
                Color::RED
            else
                Color::BLACK
            end
        else
            Color::GRAY
        end
    end

    def occupied_cells
        occupied = []
        @cell_count_x.times do | x |
            @cell_count_y.times do | y |
                if cell_occupied?(x, y)
                    occupied << get_cell(x, y)
                end
            end
        end
        occupied
    end

    def solid_objects
        solild_objs = occupied_cells

        #we now have a list of CellObject, loop over all and reject any that aren't solid
        solild_objs.reject! { | cell_object |
            !cell_object.solid
        }

        solild_objs
    end

    def clear_grid()
      @cell_count_x.times do | x |
        @cell_count_y.times do | y |
          clear_cell(x, y)
        end
      end
    end


end