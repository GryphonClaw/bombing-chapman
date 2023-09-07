class ImageButton
  attr_accessor :enabled
  def initialize(args, x, y, width, height, label, image_path = nil, enabled = true, callback = nil)
    @args = args
    @x = x
    @y = y
    @width = width
    @height = height
    @text = label
    @callback = callback

    @image = {x: @x, y: @y, w: @width, h: @height, path: image_path}#.to_sprite

    @enabled = enabled
    @mouse_entered = false
  end

  def tick()
    return unless @enabled
    @mouse_entered = @args.inputs.mouse.inside_rect?(rect) 
    if check_click()
      @callback.call
    end
  end

  def draw()
    output = []
    output << {**rect, **bg_color}.to_solid

    text_w, text_h =  $gtk.calcstringbox(@text)

    output << @image
    output << {x: @x + ((@width / 2) - (text_w/2)), y: @y + ((text_h)), text: @text, **label_color}.to_label

    output << {**rect, **outline_color}.to_border

    if mouse_entered
      output << {x: @x, y: @y, w: @width, h: @height, **Color::WHITE}.merge({a: 25}).to_solid
    end

    @args.outputs.primitives << output
  end

  def outline_color
    Color::RED
  end

  def label_color
    @enabled ? Color::BLACK : Color::LIGHTGREY
  end

  def bg_color
    Color::WHITE
  end

  private
  def check_click()
    # puts @args.inputs.mouse.button_left
    return unless (mouse_entered and !@args.inputs.mouse.button_left)
    # puts mouse_is_inside_button

      if @args.inputs.mouse.up
        mouse_started_inside = false
        return true
      end
    return false
  end

  def mouse_entered
    @mouse_entered
  end

  def valid_mouse_down
    (mouse_entered and @args.inputs.mouse.down)
  end

  def rect
    {x: @x, y: @y, w: @width, h: @height}
  end
end