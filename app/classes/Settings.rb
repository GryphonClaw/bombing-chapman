class Settings
    attr_accessor :play_sounds
    attr_accessor :show_debug_collision_rects
    attr_accessor :print_debug_grid_items
    attr_accessor :show_collision_move_player_debug_output
    attr_accessor :should_draw_blocks
    attr_accessor :tile_embed_type
    def initialize(args)
        @args = args

        @play_sounds = true
        @draw_debug_rects = true
        @hide_powerup_icons = false
        @show_debug_collision_rects = true

        @print_debug_grid_items = false

        @should_draw_blocks = true

        @show_collision_move_player_debug_output = true

        @tile_embed_type = :centered
    end

    def play_sound(sound)
        if @play_sounds
            @args.outputs.sounds << sound
        end
    end
end