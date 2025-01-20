class ObjectDisplay
    def initialize(args, x, y)
        @args = args
        @x = x
        @y = y

        @tile_size = 64

        init_selected_tile()

        # @tile_grid = []
        init_tile_grid()

    end

    private
    def init_selected_tile
        @selected_tile = @args.state.new_entity(:selected_tile)
        @selected_tile.value = nil
        @selected_tile.gui.position = {x: 0, y: 0}
        @selected_tile.gui.overlay_border = {w: @tile_size, h: @tile_size, **Color::WHITE, primitive_marker: :border}
        @selected_tile.gui.overlay = {w: @tile_size, h: @tile_size, **Color::BLACK, a: 75, primitive_marker: :solid}
        @selected_tile.gui.selected.overlay_border = {w: @tile_size, h: @tile_size, **Color::WHITE, primitive_marker: :border}
        @selected_tile.gui.selected.overlay = {w: @tile_size, h: @tile_size, **Color::MAROON, a: 75, primitive_marker: :solid}
        @selected_tile.gui.selected.locked = false
    end

    private
    def init_tile_grid
        @tile_grid = [
            [nil, "Player", nil],
            ["Block:Explodable", ValidTiles::SOLID_BLOCK, nil],
            ["Powerup:SpeedUp", "Powerup:FlameUp", "Powerup:BombUp"],
            # [nil, nil, nil],
            ["Brick:Yellow", nil, nil],
            ["Brick:Red", "Brick:Green", "Brick:Blue"]
        ]
        @tile_grid.reverse!

    end

    def tick
        if @args.inputs.mouse.inside_rect?(check_rect)
            cell_x = (@args.inputs.mouse.x - @x).idiv(@tile_size)
            cell_y = (@args.inputs.mouse.y - @y).idiv(@tile_size)

            tile = @tile_grid[cell_y][cell_x]
            if !tile.nil?
                @selected_tile.gui.position = {x: @x + (cell_x * @tile_size), y: @y + (cell_y * @tile_size)}
            else
                @selected_tile.gui.position = {x: -128, y: -128}
            end
            if @args.inputs.mouse.button_left and tile
                # return unless !@tile_grid[cell_y][cell_x].nil?
                @selected_tile.gui.selected.locked = true

                #update the selected tile if it's not he same as the currently selected tile
                if @selected_tile.value != @tile_grid[cell_y][cell_x]
                    @selected_tile.value = tile
                end

                @selected_tile.gui.selected.overlay.merge!(@selected_tile.gui.position)
                @selected_tile.gui.selected.overlay_border.merge!(@selected_tile.gui.position)
            end
        else
            @selected_tile.gui.position = {x: -128, y: -128}

        end
    end

    def draw
        items_to_draw = []

        items_to_draw << background
        items_to_draw << tiles_to_draw

        items_to_draw << border_rect

        items_to_draw << @selected_tile.gui.overlay.merge({**@selected_tile.gui.position, primitive_marker: :solid})
        items_to_draw << @selected_tile.gui.overlay_border.merge({**@selected_tile.gui.position, primitive_marker: :border})
        
        if @selected_tile.gui.selected.locked
            items_to_draw << @selected_tile.gui.selected.overlay.to_solid
            items_to_draw << selected_overlay_border
        end

        @args.outputs.primitives << items_to_draw
    end

    def selected_tile
        @selected_tile.value
    end

    private
    def selected_overlay_border
        border_items = []

        border = @selected_tile.gui.selected.overlay_border
        selected = {x: border.x, y: border.y}

        border_items << @selected_tile.gui.selected.overlay_border.to_border
        border_items << @selected_tile.gui.selected.overlay_border.merge({x: selected.x + 1, y: selected.y + 1, w: border.w - 2, h: border.h - 2, primitive_marker: :border})
        border_items << @selected_tile.gui.selected.overlay_border.merge({x: selected.x + 2, y: selected.y + 2, w: border.w - 4, h: border.h - 4, primitive_marker: :border})


        border_items
    end

    private
    def border_rect
        width = @tile_size * @tile_grid[0].length
        height = @tile_size * @tile_grid.length
        {x: @x, y: @y, w: width, h: height, **Color::WHITE, primitive_marker: :border}
    end

    private
    def check_rect
        rect = border_rect
        rect.x = rect.x - 1
        rect.y = rect.y - 1
        rect.w = rect.w - 2
        rect.h = rect.h - 2

        {**rect, **Color::GREENYELLOW, primitive_marker: :border}
    end

    private
    def background
        {x: @x, y: @y, w: @tile_size * 3, h: @tile_size * 5, **Color::ORANGE, primitive_marker: :solid}
    end

    private
    def tile_gfx_for_name tile
        case tile
        when "Block:Explodable"
            {w: @tile_size, h: @tile_size, path: "sprites/block_explodable.png", primitive_marker: :sprite}
        when "Block:Solid"
            {w: @tile_size, h: @tile_size, path: "sprites/block_solid.png", primitive_marker: :sprite}
        when "Powerup:SpeedUp"
            {w: @tile_size, h: @tile_size, path: "sprites/speed_up.png", primitive_marker: :sprite}
        when "Powerup:FlameUp"
            {w: @tile_size, h: @tile_size, path: "sprites/explosion_up.png", primitive_marker: :sprite}
        when "Powerup:BombUp"
            {w: @tile_size, h: @tile_size, path: "sprites/bomb_capacity_up.png", primitive_marker: :sprite}
        when "Bomb"
            {w: @tile_size, h: @tile_size, tile_x: 0, tile_y: 0, tile_w: 32, tile_h: 32, path: "sprites/bomb.png", primitive_marker: :sprite}
        when "Brick:Green"
            {w: @tile_size, h: @tile_size, path: "sprites/brick.png", **Color::GREEN, primitive_marker: :sprite}
        when "Brick:Yellow"
            {w: @tile_size, h: @tile_size, path: "sprites/brick.png", **Color::YELLOW, primitive_marker: :sprite}
        when "Brick:Red"
            {w: @tile_size, h: @tile_size, path: "sprites/brick.png", **Color::RED, primitive_marker: :sprite}
        when "Brick:Blue"
            {w: @tile_size, h: @tile_size, path: "sprites/brick.png", **Color::BLUE, primitive_marker: :sprite}
        when "Player"
            {w: @tile_size, h: @tile_size, tile_x: 0, tile_y: 64, tile_w: 32, tile_h: 32, path: "sprites/bomberman2.png", primitive_marker: :sprite}
        else
            {w: @tile_size, h: @tile_size, **Color::BROWN, primitive_marker: :solid}
        end
    end

    private
    def tiles_to_draw
        tiles = []
        row_num = 0
        @tile_grid.each do | row |
            col_num = 0
            row.each do | tile |
                sprite = tile_gfx_for_name(tile)
                if sprite
                    draw_x = @x + (col_num * @tile_size)
                    draw_y = @y + (row_num * @tile_size)
                    tiles << sprite.merge({x: draw_x, y: draw_y })
                end
                col_num += 1
            end
            row_num += 1
        end
        tiles
    end

    def tile_graphic
        tile_gfx_for_name @selected_tile.value
    end

    def name_to_class name
        case name
        when "BombUp"
            Powerup.class
        when "Brick"
            Brick.class
        end

    end
end