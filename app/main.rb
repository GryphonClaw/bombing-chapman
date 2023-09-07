require "app/includes.rb"


def app_init(args)

end

def process_input(args)
  kb = args.inputs.keyboard

  if args.inputs.keyboard.key_down.r
    reset_game(args)
  end


end

def reset_game(args)
  args.state.game = BombermanGame.new(args)
end

def tick args
  if args.tick_count == 0
    app_init(args)
  end

  args.state.settings ||= Settings.new(args)
  args.state.game ||= BombermanGame.new(args)
  args.state.debug.hide_item_gfx ||= false
  set_background_color(args)

  args.state.game.tick
  return unless args.inputs.keyboard.has_focus

  process_input(args)
end

def set_background_color(args)
  args.outputs.background_color = [0, 0, 0, 255]
end

$gtk.reset_next_tick