class Ground
    attr_accessor :x, :y, :width, :height
    attr_accessor :r, :g, :b
    def initialize(x, y, width, height, r = 255, g = 255, b = 255)
      @x = x
      @y = y
      @width = x + width
      @height = y + height
  
      @r = r
      @g = g
      @b = b
    end
  
    def draw()
      {x: @x, y: @y, w: @width, h: @height, r: @r, g: @g, b: @b}
    end
  end
  