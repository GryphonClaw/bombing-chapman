class BombermanGame
  attr_reader :the_player
  def initialize args
    @args = args
    @args.state.player.x = 64 + (5 * 32)
    @args.state.player.y = 64 + (5 * 32)
    @args.state.player.direction = "Down"

    @args.state.explosion_size = 1

    @offset_x = 64
    @offset_y = 64

    @grid = Grid.new(@args, 26, 20)

    generate_power_ups()

    @the_player = Player.new(@args, args.state.player.x, args.state.player.y, 64, 64, args.state.player.direction)

    @ground = Ground.new( @offset_x, @offset_y, 32*25, 32*18, 0, 0, 64)

    init_floor_blocks(args)

    @max_bombs = 1

    @bombs = {placed: 0, max: @max_bombs}

    @settings = args.state.settings

    @editor = args.state.new_entity(:editor)
    @editor.gui.tile_selector = ObjectDisplay.new(args, 950, 382)
    @editor.gui.buttons = init_editor_buttons(args)
    @editor.gui.sub_clear_buttons = init_sub_clear_buttons()
    @editor.gui.template_buttons = init_sub_template_buttons()
    @editor.gui.show_sub_buttons = false
    @editor.gui.show_template_buttons = false

    @editor.gui.templates_warning = Label.new(x: 128, y: 128, text: "Warning: Be sure you want the template you click.")
    @editor.gui.templates_warning2 = Label.new(x: 128, y: 105, text: "This action cannot be undone.")

    @mode = :Playing

    @valid_modes = [:Playing, :Editing]
    @next_mode = nil

    @editor.previous_click = nil

    make_blocks()
  end
  
  def init_editor_buttons(args)
    @editor.gui.buttons = []

    clear_button = Button.new(args, 950, 350, 100, 25, "Clear", true, -> { toggle_sub_clear_buttons()})
    template_button = Button.new(args, 950, 315, 100, 25, "Templates", true, -> { toggle_templates() })
    @editor.gui.buttons << clear_button
    @editor.gui.buttons << template_button
  end

  def toggle_sub_clear_buttons()
    @editor.gui.show_sub_buttons = !@editor.gui.show_sub_buttons
    @editor.gui.show_template_buttons = false
  end

  def toggle_templates()
    @editor.gui.show_sub_buttons = false
    @editor.gui.show_template_buttons = !@editor.gui.show_template_buttons
  end

  #shows additional buttons if they are toggled on
  def init_sub_clear_buttons
    sub_clear = []
    sub_clear << Button.new(@args, 1075, 350, 150, 25, "Power Ups", true, -> { editor_clear_power_ups()})
    sub_clear << Button.new(@args, 1075, 320, 150, 25, "Clear Grid", true, -> { clear_grid_button_action()})
    return sub_clear
  end

  def init_sub_template_buttons
    sub_templates = []
    sub_templates << ImageButton.new(@args, 224, 384, 1726 * 0.1, 1278 * 0.1, "", "sprites/level_template_preview/solid_blocks_with_paths.png", true, -> { editor_template_level(:solid_blocks)})
    sub_templates << ImageButton.new(@args, 576, 384, 1726 * 0.1, 1278 * 0.1, "", "sprites/level_template_preview/explodable_blocks_with_paths.png", true, -> { editor_template_level(:explodable_blocks)})

    sub_templates
  end

  def clear_grid_button_action
    puts "toggle clear sub buttons"
    clear_grid()
  end

  def editor_template_level(template)
    clear_grid()

    case template
    when :explodable_blocks
      1.step(25, 3) do | x |
        1.step(18, 3) do | y |
          draw_position = {x: (x * 32) + @offset_x, y: (y * 32) + @offset_y}
          block = Block.new(@args, draw_position.x, draw_position.y, true)
          @grid.set_cell(x, y, block)
        end
      end
    when :solid_blocks
      1.step(25, 3) do | x |
        1.step(18, 3) do | y |
          should_explode = [true, false].sample
          draw_position = {x: (x * 32) + @offset_x, y: (y * 32) + @offset_y}
          # puts draw_position
          block = Block.new(@args, draw_position.x, draw_position.y, false)
          @grid.set_cell(x, y, block)
        end
      end
    end
    puts "Set level using template #{template}"
    @editor.gui.show_template_buttons = false

  end

  def editor_clear_power_ups
    (1..27).each do | x |
      (1..19).each do | y|
        cell_obj = @grid.get_cell(x, y)
        if cell_obj #ok we have an object, lets make sure it's the type we want to get rid of
          should_clear = false
          type = cell_obj.type
          case type
          when :ExplosionUp, :SpeedUp, :BombUp
            should_clear = true#@grid.clear_cell(x, y)
          end

          if !should_clear
            if cell_obj.can_contain_powerup
              cell_obj.set_powerup(nil)
            end
          end

          if should_clear
            @grid.clear_cell(x, y)
          end
        end
      end
    end
  end

  def clear_grid
    @grid.clear_grid()
  end

  def init_floor_blocks(args)
    @blocks = []
    for x in 0..26 do
      @blocks << []
      for y in 0..19 do
        @blocks[x] << GroundBlock.new(args, x, y, :Gray, true)
      end
    end

    for x in 0..26 do
      @blocks[x][0] = GroundBlock.new(args, x, 0, :Green, true)
      @blocks[x][19] = GroundBlock.new(args, x, 19, :Green, true)
    end
    for y in 1..19 do
      @blocks[0][y] = GroundBlock.new(args, 0, y, :Green, true)
      @blocks[26][y] = GroundBlock.new(args, 26, y, :Green, true)
    end

    floor_blocks = []
    27.times do | x |
      20.times do | y |
        floor_blocks << @blocks[x][y].draw()
      end
    end

    args.outputs.static_sprites << floor_blocks
  end

  def toggle_mode
    case @mode
    when :Playing
      @next_mode = :Editing
    when :Editing
      @next_mode = :Playing
    end
  end

  def get_random_block_color()
    Block.colors.keys()[rand(Block.colors.keys.length)]
  end
  
  def is_mode(the_mode)
    @mode == the_mode
  end

  def mode_edit
    is_mode(:Editing)
  end

  def mode_play
    is_mode(:Playing)
  end

  def tick
    #do input processing for all modes
    current_mode = @mode

    process_input()

    draw_ground()

    #things to do in any mode
    grid_draw()

    if current_mode != @mode
      raise "Mode not changed correctly. Modify @next_mode instead."
    end

    #mode specific tick
    mode_tick()

    #mode specific draw
    mode_draw()



    if @next_mode
        @mode = @next_mode
        @next_mode = nil
    end
  end

  def mode_tick
    case @mode
    when :Playing
      process_playing_mode_input()
      grid_tick()
    when :Editing
      process_edit_mode_input()
      @editor.gui.tile_selector.tick
    end
  end

  def mode_draw()
    case @mode
    when :Playing
      process_playing_mode_input()
      draw_hud()
    when :Editing
      draw_template_backdrop()
      draw_edit_mode_gui()
    end
  end

  def draw_template_backdrop
    return unless @editor.gui.show_template_buttons
    @args.outputs.primitives << {x: 64, y: 64, w: 864, h: 640, **Color::BLUE, a: 32, primitive_marker: :solid}
  end

  def draw_edit_mode_gui
    @editor.gui.tile_selector.draw()
    @editor.gui.buttons.each do | button |
      button.draw()
    end
    if @editor.gui.show_sub_buttons
      @editor.gui.sub_clear_buttons.each do | button |
        button.draw()
      end
    end
    if @editor.gui.show_template_buttons
      @editor.gui.template_buttons.each do | button |
        button.draw()
      end

      @args.outputs.primitives << {x: 96, y: 96, w: 32*25, h: 96, **Color::BLACK, a: 128, primitive_marker: :solid}
      @args.outputs.primitives << @editor.gui.templates_warning
      @args.outputs.primitives << @editor.gui.templates_warning2
    end
  end

  def get_mode_string()
    case @mode
    when :Playing
      "Playing"
    when :Editing
      "Editing"
    else
      "Unknown or Mode Not set (#{@mode})"
    end
  end

  def show_mode()
    mode_string = get_mode_string()
    mode_label = {x: 15, y: 720 - 10, text: mode_string, size_enum: -4, **Color::WHITE, primitive_marker: :label}
    @args.outputs.labels << mode_label
  end

  def draw_debug_rects()
    @args.outputs.primitives << @grid.boundary_rect.merge({**Color::WHITE, primitive_marker: :border})
    @args.outputs.primitives << @the_player.collision_rect.merge({**Color::WHITE, primitive_marker: :border})

    @args.outputs.primitives << @grid.objects
  end

    #draws the player stats info
  def draw_hud()
    hud_labels = []

    hud_labels << {x: 950, y: 700, text: "Placed Bombs : #{@bombs.placed}", **Color::WHITE}
    hud_labels << {x: 950, y: 675, text: "Maximum Bombs: #{@the_player.max_bombs}", **Color::WHITE}
    hud_labels << {x: 950, y: 650, text: "Speed Multiplier: #{(@the_player.speed_multiplier * 10).to_i}", **Color::WHITE}
    hud_labels << {x: 950, y: 625, text: "Explosion Size: #{@args.state.explosion_size}", **Color::WHITE}


    def get_fps_color(the_fps)
      fps_color = Color::WHITE
      case the_fps
      when 30..60
        fps_color = Color::GREEN
      when 15..29
        fps_color = Color::YELLOW
      else
        fps_color = Color::RED
      end
      fps_color
    end

    fps = @args.gtk.current_framerate
    fps_str = fps.to_sf
    hud_labels << { x: 1200, y: 715, text: "FPS #{fps_str}", size_enum: -2, **get_fps_color(fps) }

    @args.outputs.labels << hud_labels

    def get_sound_image
        @args.state.settings.play_sounds ? "sounds_on4" : "sounds_off4"
    end
    @args.outputs.primitives << {x: 950, y: 64, w: 64, h: 64, **Color::GREEN, path: "sprites/#{get_sound_image()}.png", primitive_marker: :sprite}

    show_mode()
  end

  def grid_draw()
    @grid.draw()
  end

  def draw_ground
    @args.outputs.solids << @ground.draw()
  end

  
  def process_playing_mode_input()
    if @args.inputs.keyboard.key_down.two
      puts "BombermanGame - process_input:Key Down::Two"
      puts "  Toggle Draw Blocks"
      @settings.should_draw_blocks = @settings.should_draw_blocks
    end

    process_player_input_2()

    if @args.keyboard.key_down.space
      drop_bomb()
    end

    check_item_collisions()
    @args.outputs.primitives << @the_player.draw().to_sprite
    draw_debug_rects()
  end


  def process_input()
    if @args.inputs.keyboard.key_down.tab
      puts "BombermanGame - process_input:Key Down::Tab"
      puts "  Toggle Mode"
      toggle_mode()
    end
  end

  def process_edit_mode_input()
    process_edit_mode_keyboard()
    process_edit_mode_mouse()
    process_edit_mode_button_clicks()
  end

  def process_edit_mode_button_clicks()
    buttons = @editor.gui.buttons
    buttons.each do | button |
      button.tick
    end

    if @editor.gui.show_sub_buttons
      buttons = @editor.gui.sub_clear_buttons
      buttons.each do | button |
        button.tick
      end
    end

    if @editor.gui.show_template_buttons
      buttons = @editor.gui.template_buttons
      buttons.each do | button |
        button.tick
      end
    end
  end

  def process_edit_mode_keyboard()
    kb = @args.inputs.keyboard
    if kb.key_down.one
      puts "select tile"
    elsif kb.key_down.two
      puts "select item"
    end

    if kb.key_down.t
      case @settings.tile_embed_type
      when :centered
        @settings.tile_embed_type = :full
      when :full
        @settings.tile_embed_type = :quarter_bl
      when :quarter_bl
        @settings.tile_embed_type = :quarter_br
      when :quarter_br
        @settings.tile_embed_type = :quarter_tl
      when :quarter_tl
        @settings.tile_embed_type = :quarter_tr
      when :quarter_tr
        @settings.tile_embed_type = :centered
      else
      end
    end
  end

  def process_edit_mode_mouse()
    return unless !@editor.gui.show_template_buttons
    tile = @editor.gui.tile_selector.selected_tile
    if tile
      mouse = @args.inputs.mouse
      if mouse.inside_rect?(@grid.boundary_rect)
        grid_x = ((mouse.x - @offset_x).idiv(32))
        grid_y = ((mouse.y - @offset_y).idiv(32))

        edit_mode_create_tile_info_window(mouse, grid_x, grid_y)

        if grid_x != @editor.previous_grid_x or grid_y != @editor.previous_grid_y
          @editor.previous_click = nil
        end
        return unless @editor.previous_click.nil?

        if mouse.button_left
          obj = create_object(grid_x, grid_y, @editor.gui.tile_selector.selected_tile)
          if obj
            @grid.set_cell(grid_x, grid_y, obj)
          end
        elsif mouse.button_right
          cell_value = @grid.get_cell(grid_x, grid_y)
          if cell_value
            @grid.clear_cell(grid_x, grid_y)
          end
        end

        @editor.previous_grid_x = grid_x
        @editor.previous_grid_y = grid_y
        @editor.previous_click = {x: grid_x, y: grid_y}
      end
    end
  end

  def create_object(x, y, object_type)
    return unless @grid.in_bounds(x, y)
    valid_tiles = ValidTiles::ALL_TILES
    return unless valid_tiles.include?(object_type)

    the_object = nil

    draw_position = {x: (x * 32) + @offset_x, y: (y * 32) + @offset_y}

    cell_object = @grid.get_cell(x, y)
    should_hide_item = false
    case object_type
    when ValidTiles::GREEN_BRICK
      the_object = Brick.new(@args, draw_position.x, draw_position.y, Color::GREEN)
    when ValidTiles::RED_BRICK
      the_object = Brick.new(@args, draw_position.x, draw_position.y, Color::RED)
    when ValidTiles::YELLOW_BRICK
      the_object = Brick.new(@args, draw_position.x, draw_position.y, Color::YELLOW)
    when ValidTiles::BLUE_BRICK
      the_object = Brick.new(@args, draw_position.x, draw_position.y, Color::BLUE)
    when ValidTiles::EXPLODABLE_BLOCK
      the_object = Block.new(@args, draw_position.x, draw_position.y, true)
      should_hide_item = true
    when ValidTiles::SOLID_BLOCK
      the_object = Block.new(@args, draw_position.x, draw_position.y, false)
    when ValidTiles::SPEED_UP
      the_object = Powerup.new(@args, draw_position.x, draw_position.y, :SpeedUp)
      should_hide_item = true
    when ValidTiles::FLAME_UP
      the_object = Powerup.new(@args, draw_position.x, draw_position.y, :ExplosionUp)
      should_hide_item = true
    when ValidTiles::BOMB_UP
      the_object = Powerup.new(@args, draw_position.x, draw_position.y, :BombUp)
      should_hide_item = true
    else
      puts "Couldn't find \"#{object_type}\" in valid tiles"
    end
    if cell_object and cell_object.can_contain_powerup() and should_hide_item
      cell_object.set_powerup(object_type)
      return cell_object
    end
    the_object
  end

  def edit_mode_create_tile_info_window mouse, grid_x, grid_y
    return unless mouse.has_focus
    overlay = {r: 255, g: 255, b: 255, a: 128}

    grid_position_label = {x: @offset_x, y: 30, text: "#{grid_x}, #{grid_y}", size_enum: -3, **Color::WHITE, primitive_marker: :label}
    
    position = {
      x: ((mouse.x).idiv(32) * 32),
      y: ((mouse.y).idiv(32) * 32)
    }

    position_text = "#{grid_x}, #{grid_y}"
    position_text_w, position_text_h = @args.gtk.calcstringbox(position_text, -3)

    info_title_text = "TILE INFO"

    cell_obj = @grid.get_cell(grid_x, grid_y)
    
    cell_info_text = "#{cell_obj ? cell_obj.editor_description : "Empty"}"
    cell_info_w, cell_info_h = @args.gtk.calcstringbox(cell_info_text, -3)
    info_title_w, info_title_h = @args.gtk.calcstringbox(info_title_text, -2)

    info_background_w = (info_title_w > cell_info_w) ? (info_title_w + 10) : (cell_info_w + 10)
    info_background_h = 60
    
    hover_tile_info = {x: mouse.x + 16, y: mouse.y - 12, text: cell_info_text, size_enum: -3, **Color::WHITE, primitive_marker: :label}
    position_info_label = {x: mouse.x + 16, y: mouse.y - 28 , text: position_text, size_enum: -3, **Color::WHITE, primitive_marker: :label}
    
    position_info_label_background = {x: mouse.x + 12, y: mouse.y - 50, w: info_background_w, h: info_background_h, **Color::LIGHTSLATEGREY, primitive_marker: :solid}
    info_line = {x: mouse.x + 16, y: mouse.y - 8, x2: mouse.x + info_background_w + 8, y2: mouse.y - 8, **Color::WHITE, primitive_marker: :line}
    graphic = @editor.gui.tile_graphic.merge({w: 32, h: 32})
    ghost_tile = {**position, **graphic, **overlay}#position.merge(graphic).merge(overlay)
    info_title = {x: mouse.x + 16, y: mouse.y + 8, text: info_title_text, size_enum: -2, **Color::WHITE}

    editor_primitives = [
      ghost_tile.to_sprite, grid_position_label,
      position_info_label_background,
      info_title,
      info_line,
      hover_tile_info, position_info_label
    ]
    @args.outputs.primitives << editor_primitives
  end

  def process_player_input_2()
    kb = @args.inputs.keyboard

    rects = []
    @grid.solid_objects.map do | solid |
      rects << solid.collision_rect
    end
    delta = {x: 0, y: 0}
    delta.x = kb.left_right * @the_player.movement_speed.x
    delta.y = kb.up_down * @the_player.movement_speed.y
    
    @the_player.x += delta.x

    collision = rects.find { | r | r.intersect_rect? @the_player.collision_rect}
    if collision
      if delta.x > 0
        @the_player.x = collision.x - @the_player.collision_rect.w
      elsif delta.x < 0
        @the_player.x = collision.x + collision.w
      end
      # @the_player.delta.x = 0
    end
    
    @the_player.y += delta.y
    collision = rects.find { | r | r.intersect_rect? @the_player.collision_rect}
    if collision
      if delta.y > 0
        @the_player.y = collision.y - @the_player.collision_rect.h
      elsif delta.y < 0
        @the_player.y = collision.y + collision.h
      end
      # @the_player.delta.y = 0
    end
  end

  def check_aabb_rect x, y
    rects = []
    @grid.solid_objects.map do | solid |
      rects << solid.collision_rect
    end

    collision = rects.find { | r | r.intersect_rect? @the_player.collision_rect}
    if collision
      if x > 0
        @the_player.x = collision.x - @the_player.collision_rect.w
      elsif x < 0
        @the_player.x = collision.x + collision.w
      end
      @the_player.delta.x = 0
    end
    
    collision = rects.find { | r | r.intersect_rect? @the_player.collision_rect}
    if collision
      if y > 0
        @the_player.y = collision.y - @the_player.collision_rect.h
      elsif y < 0
        @the_player.y = collision.y + collision.h
      end
    end

    @the_player.delta.y = 0
  end

  def process_player_input_1()
    kb = @args.inputs.keyboard

    check_collision_rect -1,  0 if kb.left # x position decreases by 1 if left key is pressed
    check_collision_rect  1,  0 if kb.right # x position increases by 1 if right key is pressed
    check_collision_rect  0,  1 if kb.up # y position increases by 1 if up is pressed
    check_collision_rect  0, -1 if kb.down # y position decreases by 1 if down is pressed
  end

  def check_collision_rect x, y
    potential_rect = @the_player.collision_rect.shift_rect(x, 
                                                           y) # box is able to move at an angle
    rects = []
    @grid.solid_objects.map do | solid |
      rects << solid.collision_rect
    end

    # If the player's box hits a wall, it is not able to move further in that direction
    return if rects.any_intersect_rect?(potential_rect)

    # Player's box is able to move at angles (not just the four general directions) fast
    @the_player.x += x * @the_player.movement_speed.x
    @the_player.y += y * @the_player.movement_speed.y
  end

  def process_player_input()
    x, y = @the_player.collision_rect.x, @the_player.collision_rect.y
    kb =  @args.inputs.keyboard
    collided = false
    grid_boundary = @grid.boundary_rect

    x_dir = 0
    x_dir = -1 if kb.left 
    x_dir = 1  if kb.right

    y_dir = 0
    y_dir = 1  if kb.up 
    y_dir = -1 if kb.down

    potential_position = @the_player.collision_rect.merge({x: x, y: y})
    potential_position.x += @the_player.movement_speed.x * x_dir
    potential_position.y += @the_player.movement_speed.y * y_dir

    potentail_grid_pos = {x: potential_position.x.idiv(32) - 2,y: potential_position.y.idiv(32) - 2}

    cell = @grid.get_cell(potentail_grid_pos.x, potentail_grid_pos.y)
    if cell
      if cell.solid
        collided = true
      end
    end

    if !potential_position.inside_rect?(grid_boundary)
      collided = true
    end
    @the_player.process_input()#for addtional stuff such as debug info to display etc....

    if not collided
      @the_player.x = potential_position.x
      @the_player.y = potential_position.y
    end
  end

  def process_player_input_1()
    x, y = @the_player.collision_rect.x, @the_player.collision_rect.y

    @the_player.process_input()#for addtional stuff such as debug info to display etc....
    
    #check game grid for valid movement (make sure the potential new position
    #isnt filled with a solid CellObject)

    grid_pos = {x: ((x - @grid.draw_offset.x).idiv(32)), y: ((y - @grid.draw_offset.y).idiv(32))}

    grid_items = ((grid_pos.x - 1..grid_pos.x + 1)).map do | x_pos |
      ((grid_pos.y - 1..grid_pos.y + 1)).map do | y_pos |
        @grid.get_cell(x_pos, y_pos)
      end
    end
    
    if @settings.show_debug_collision_rects
      show_debug_collision_rects(grid_pos.x, grid_pos.y)
    end        
    
    kb =  @args.inputs.keyboard
    x_dir = 0
    x_dir = -1 if kb.left 
    x_dir = 1  if kb.right

    y_dir = 0
    y_dir = 1  if kb.up 
    y_dir = -1 if kb.down

    #check if the potential x, y is within the game grid rect
    potential_position = @the_player.collision_rect.merge({x: x, y: y})
    potential_position.x += @the_player.movement_speed.x * x_dir
    potential_position.y += @the_player.movement_speed.y * y_dir

    if !potential_position.inside_rect?(@grid.boundary_rect)
      return
    end
    #if everything passes, check movement on individiual axes to allow holding
    #down and right, but allow moving right if no collision is detected

    move_player -1,  0, grid_items[0][1] if kb.left # x position decreases by 1 if left key is pressed
    move_player  1,  0, grid_items[2][1] if kb.right # x position increases by 1 if right key is pressed
    move_player  0,  1, grid_items[1][0] if kb.up # y position increases by 1 if up is pressed
    move_player  0, -1, grid_items[1][2] if kb.down # y position decreases by 1 if down is pressed
  end

  def move_player x, y, grid_item
    potential_pos = {x: (@the_player.x + @the_player.movement_speed.x), y: (@the_player.y + @the_player.movement_speed.y)}
    box = { x: potential_pos.x, y: potential_pos.y, w: 32, h: 32 }

    if @settings.show_collision_move_player_debug_output
      puts grid_item
      puts "potential box #{box}"
      puts "grid item #{grid_item}"

      case [x, y]
      when [-1, 0]
        puts "Left"
      when [1, 0]
        puts "Right"
      when [0, -1]
        puts "Down"
      when [0, 1]
        puts "Up"
      end
    end

    if grid_item != nil and grid_item.solid
      if @settings.show_collision_move_player_debug_output
        puts "we have a grid object"
        puts grid_item
        puts grid_item.rect
        puts "grid obj is solid: #{grid_item.solid}"
      end

      if box.intersect_rect?(grid_item.rect)
        if @settings.show_collision_move_player_debug_output
          puts "failed collision test #{x} #{y}"
        end

        return
      end
    end
  
    #passed all other checks, allow the movement
    @the_player.x += x * @the_player.movement_speed.x.to_i
    @the_player.y += y * @the_player.movement_speed.y.to_i
  end

  def bricks_toggle_hide_solid2()
    for x in 0..26
      for y in 0..19
        @blocks[x][y].toggle_hide_solid()
      end
    end
  end

  def show_debug_collision_rects x, y
    debug_rects = []
    alpha = 64
    ((x - 1)..(x + 1)).each do | x_pos |
      ((y - 1)..(y + 1)).each do | y_pos |
        cell_obj = @grid.get_cell(x_pos, y_pos)
        rect_color = cell_obj != nil ? Color::BLACK.merge({a: alpha}) : Color::RED.merge({a: alpha})
        draw_pos = {x: (x_pos * 32) + @grid.draw_offset.x , y: (y_pos * 32) + @grid.draw_offset.y}
        debug_rects <<  {**draw_pos, w: 32, h: 32, r: 255, **rect_color, primitive_marker: :solid}
      end
    end
    @args.outputs.primitives << debug_rects
  end

  def drop_bomb()
    return unless @bombs.placed < @the_player.max_bombs

    x = @the_player.x - @offset_x
    y = @the_player.y - @offset_y
    cell_x = (x / 32).floor
    cell_y = (y / 32).floor

    draw_x = (cell_x * 32) + @offset_x
    draw_y = (cell_y * 32) + @offset_y

    if !@grid.get_cell(x, y)
      new_bomb = Bomb.new(@args, draw_x, draw_y, 4 * 60)
      @grid.set_cell(cell_x, cell_y, new_bomb)
    end

    @bombs.placed += 1
  end

  def check_item_collisions()
    player_pos = @the_player.position
    grid_x = (((player_pos.x - @offset_x) / 32)).round
    grid_y = (((player_pos.y - @offset_y) / 32)).round


    obj = @grid.get_cell(grid_x, grid_y)

    if obj != nil
      should_clear_item = false
      #clear the grid of the item first
      #now check which type we picked up
      case obj.type
      when :BombUp
        should_clear_item = true
        play_sound(:BombUp)
        @the_player.increase_max_bombs(1)
      when :SpeedUp
        should_clear_item = true
        play_sound(:SpeedUp)
        @the_player.speed_up()
      when :ExplosionUp
        should_clear_item = true
        # play_sound("flame on")
        play_sound(:ExplosionUp)
        @args.state.explosion_size += 1
        @args.state.explosion_size = @args.state.explosion_size.clamp(1, 5)
      end
      if should_clear_item
        @grid.clear_cell(grid_x, grid_y)
      end
    end
  end

  #loads the different powerups in the Powerups class
  #loops over the powerup types, grabs a random power up
  #up to a maximum amount per type. Inserts the selected
  #type into the grid. Rinse. Repeat until the  maximum number
  #of powerups are reached.
  def generate_power_ups()
    powerups = Powerup.types
    max_item_powerup = { BombUp: 10, SpeedUp: 10, ExplosionUp: 5 }
    type_count = {BombUp: 0, SpeedUp: 0, ExplosionUp: 0 }

    max_powerup_count = 40
    powerup_count = 0

    while powerup_count < max_powerup_count
      for i in 1..max_powerup_count
        x = rand(@grid.cell_count_x - 2) + 1
        y = rand(@grid.cell_count_y - 2) + 1
        
        return unless not powerups.empty?
        draw_x = x * 32 + @offset_x
        draw_y = y * 32 + @offset_y

        which = powerups[rand(powerups.length)]

        powerup = Powerup.new(@args, draw_x , draw_y, which)
        @grid.set_cell(x, y, powerup)

        powerup_count += 1
        type_count[which] += 1
        max_count = max_item_powerup[which]
        if type_count[which] >= max_count
          powerups.delete_if { | item | item == which } 
        end
      end
    end

    powerup_count = @grid.count(:Powerup)
  end

  def grid_tick
    @grid.tick()
    @bombs.placed = @grid.count(:Bomb)
    # puts "other grid tick"
    cell_x, cell_y = @grid.cell_count_x, @grid.cell_count_y
    cell_x.times do | x |
      cell_y.times do | y |
        next unless @grid.cell_occupied?(x, y)
        object = @grid.get_cell(x, y)
        object.tick

        if object.can_die && object.should_die
          object.invalidated = true

          case object.type
          when :Bomb
            play_sound('boom')
            grid_add_explosion_origin({x: x, y: y})
          when :BombFlame

          end
        end
      end
    end

    #now loop over the grid to see if things need to be changed
    clear_invalid_objects()
  end

  def grid_set_cell(x, y, value, type = :none, check_occupied = true)
    if value != nil
      cell_object = @grid.get_cell(x, y)
      if cell_object and cell_object.type == :Bomb and type == :BombFire
        replaced_bomb = true
      end
    end

    @grid.set_cell(x, y, value)

    if replaced_bomb
      grid_add_explosion_origin({x: x, y: y})
    end
  end

  #coordinates are x/y of the cell, not pixels
  def grid_add_explosion_origin(coordinates)
    explosion_size = @args.state.explosion_size
    #              left        , right       , up           , down
    directions = [{x: -1, y: 0}, {x: 1, y: 0}, {x: 0, y: -1}, {x: 0, y: 1}, {x: 0, y: 0}]
    directions.each do | direction |
      count = (1..explosion_size).to_a
        count.each do | position_offset |
        grid_x = (coordinates.x + (position_offset * direction.x))
        grid_y = (coordinates.y + (position_offset * direction.y))
        grid_object = @grid.get_cell(grid_x, grid_y)

        powerup_meta_data = nil
        if (grid_object and grid_object.can_contain_powerup)
          if grid_object.has_powerup
            powerup_meta_data = grid_object.meta_data
          end
        end
        if !grid_object or (grid_object.explodable or grid_object.type == :BombFire)
                
          draw_x = (grid_x * 32) + @offset_x
          draw_y = (grid_y * 32) + @offset_x
                

          flame = BombFire.new(@args, draw_x, draw_y, powerup_meta_data)
          grid_set_cell(grid_x, grid_y, flame, :BombFire, false)

        elsif (grid_object and !grid_object.explodable)
          break
        end
      end
    end
  end

  def clear_invalid_objects()
    cell_x, cell_y = @grid.cell_count_x, @grid.cell_count_y

    cell_x.times do | x |
      cell_y.times do | y |
        if @grid.cell_occupied?(x, y) #only attempt to clear invalidated object if the cell is actually occupied
          obj = @grid.get_cell(x, y)
          if obj and obj.invalidated

            has_powerup = false
            if obj.has_metadata
              has_powerup = obj.meta_data.key?(:powerup)
            end
            @grid.clear_cell(x, y)
            if has_powerup

              spawn_brick_item(x, y, obj.meta_data)
            end
          end
        end
      end
    end
  end

  def spawn_brick_item(x, y, meta_data)
    return unless meta_data.key?(:powerup)
    the_item = meta_data[:powerup]
    draw_x, draw_y = @offset_x + (x * 32), @offset_y + (y * 32)
    case the_item
    when ValidTiles::SPEED_UP
      powerup = Powerup.new(@args, draw_x, draw_y, :SpeedUp)
      grid_set_cell(x, y, powerup)
    when "Powerup:BombUp"
      powerup = Powerup.new(@args, draw_x, draw_y, :BombUp)
      grid_set_cell(x, y, powerup)
    when "Powerup:FlameUp"
      powerup = Powerup.new(@args, draw_x, draw_y, :ExplosionUp)
      grid_set_cell(x, y, powerup)
    else
      puts "unknown item: #{the_item}"
    end
  end

  #play the given sound, just need to give sound name, the function adds the path and .wav extension
  #so passing "my sound" plays the sound "sounds/my sound.wav"
  #or pass a symbol name of the powerup/sound type
  def play_sound(sound)
    if sound.is_a?(String)
      @args.state.settings.play_sound("sounds/#{sound}.wav")
    elsif sound.is_a?(Symbol)
      case sound
      when :ExplosionUp
        @args.state.settings.play_sound("sounds/flame_on2.wav")
      when :BombUp
        @args.state.settings.play_sound("sounds/dynamite4.wav")
      when :SpeedUp
        @args.state.settings.play_sound("sounds/speed_up.wav")
      end
    end
  end


  def add_brick()
    return unless @args.inputs.mouse.inside_rect?(@grid.boundary_rect)

    #ok we are within the boundaries of the game area lets do more stuff
    mouse_clicked = @args.inputs.mouse.click
    mouse_moved = @args.inputs.mouse.moved
    mouse_left_click = @args.inputs.mouse.button_left
    mouse_right_click = @args.inputs.mouse.button_right
    control_held = @args.inputs.keyboard.key_held.meta

    x, y = @args.inputs.mouse.x, @args.inputs.mouse.y
    offset = @grid.draw_offset
    grid_position = {
      x: ((x - offset.x) / 32).floor, 
      y: ((y - offset.y) / 32).floor
    }

    if mouse_left_click and control_held
      if !@grid.cell_occupied?(grid_position.x, grid_position.y)
        brick = Brick.new(@args, (grid_position.x * 32) + offset.x, (grid_position.y * 32) + offset.y, Color::YELLOW)
        @grid.set_cell(grid_position.x, grid_position.y, brick)
      end
    elsif mouse_right_click and control_held
      if @grid.cell_occupied?(grid_position.x, grid_position.y)
        obj = @grid.get_cell(grid_position.x, grid_position.y)
        if obj.type == :Brick
          @grid.clear_cell(grid_position.x, grid_position.y)
        end
      end
    end
  end

  def make_blocks()
    1.step(25, 3) do | x |
      1.step(18, 3) do | y |
        should_explode = [true, false].sample
        draw_position = {x: (x * 32) + @offset_x, y: (y * 32) + @offset_y}

        block = Block.new(@args, draw_position.x, draw_position.y, should_explode)
        @grid.set_cell(x, y, block)
      end
    end
  end
end
