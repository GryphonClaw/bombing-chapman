require "app/modules/Color.rb"

class Label
    attr_reader :x, :y, :text, :size_enum,:alignment_enum, :r, :g, :b, :a, :font, :vertical_alignment_enum, :blend_mode, :blendmode_enum

    def initialize(x: 0, y: 0, text:, r: 255, g: 255, b: 255, a: 255, font: "", size_enum: 2, alignment_enum: TextAlignment.left, vertical_alignment_enum: 0, blend_mode: nil, blendmode_enum: 1)
        @x = x
        @y = y
        @text = text
        @size_enum = size_enum
        @alignment_enum = alignment_enum # 0 = left, 1 = center, 2 = right
        @r = r
        @g = g
        @b = b
        @a = a
        @font = font
        @vertical_alignment_enum = vertical_alignment_enum
        @blend_mode = nil
        @blendmode_enum = blendmode_enum
    end

    def serialize
        {x: @x, y: @y, text: @text, size_enum: @size_enum, alignment_enum: @alignment_enum, **Color::WHITE, font: @font, vertical_alignment_enum: @vertical_alignment_enum}
    end

    def primitive_marker
        :label
    end
end

class TextAlignment
    @@left = 0
    @@center = 1
    @@right = 2

    def self.left
        @@left
    end

    def self.center
        @@center
    end

    def self.right
        @@right
    end
end