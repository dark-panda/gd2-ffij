# frozen_string_literal: true; encoding: ASCII-8BIT
#
# See COPYRIGHT for license details.

module GD2
  #
  # = Description
  #
  # Color objects hold the red, green, blue, and alpha components for a pixel
  # color. Color objects may also be linked to a particular palette index
  # associated with an image.
  #
  # == Creating
  #
  # Color objects are created by specifying the individual components:
  #
  #   red   = Color[1.0, 0.0, 0.0]
  #   green = Color[0.0, 1.0, 0.0]
  #   blue  = Color[0.0, 0.0, 1.0]
  #
  #   transparent_yellow = Color[1.0, 1.0, 0.0, 0.5]
  #
  # The components may be specified as a percentage, as an explicit value
  # between 0..RGB_MAX or 0..ALPHA_MAX, or as another color from which the
  # associated component will be extracted.
  #
  class Color
    attr_reader :rgba   #:nodoc:

    # The palette index of this color, if associated with an image palette
    attr_reader :index

    # The palette of this color, if associated with an image palette
    attr_reader :palette

    alias to_i rgba

    def self.normalize(value, max, component = nil)   #:nodoc:
      case value
      when Integer
        (value < 0) ? 0 : (value > max) ? max : value
      when Float
        normalize((value * max).round, max, component)
      when Color
        value.send(component)
      else
        return normalize(value.to_i, max) if value.respond_to?(:to_i)
        raise TypeError
      end
    end

    def self.pack(r, g, b, a)   #:nodoc:
      r = r.read_int if r.is_a?(FFI::Pointer)
      g = g.read_int if g.is_a?(FFI::Pointer)
      b = b.read_int if b.is_a?(FFI::Pointer)
      a = a.read_int if a.is_a?(FFI::Pointer)
      (a << 24) + (r << 16) + (g << 8) + b
    end

    class << self
      alias [] new
    end

    # Create a new Color object with the given component values.
    def initialize(r, g, b, a = ALPHA_OPAQUE)
      r = self.class.normalize(r, RGB_MAX, :red)
      g = self.class.normalize(g, RGB_MAX, :green)
      b = self.class.normalize(b, RGB_MAX, :blue)
      a = self.class.normalize(a, ALPHA_MAX, :alpha)

      init_with_rgba(self.class.pack(r, g, b, a))
    end

    def self.new_from_rgba(rgba)  #:nodoc:
      allocate.init_with_rgba(rgba)
    end

    def self.new_from_palette(r, g, b, a, index, palette)   #:nodoc:
      allocate.init_with_rgba(pack(r, g, b, a), index, palette)
    end

    def init_with_rgba(rgba, index = nil, palette = nil)  #:nodoc:
      @rgba = rgba
      @index = index
      @palette = palette
      self
    end

    BLACK       = Color[0.0, 0.0, 0.0].freeze
    WHITE       = Color[1.0, 1.0, 1.0].freeze
    TRANSPARENT = Color[0.0, 0.0, 0.0, ALPHA_TRANSPARENT].freeze

    # Return *true* if this color is associated with the specified palette,
    # or with any palette if *nil* is given.
    def from_palette?(palette = nil)
      @palette && @index && (palette.nil? || palette.equal?(@palette))
    end

    # Return a string description of this color.
    def to_s
      s  = 'RGB'
      s += "A" if alpha != ALPHA_OPAQUE
      s += "[#{@index}]" if @index
      s += '#' + [red, green, blue].map { |e| '%02X' % e }.join('')
      s += '%02X' % alpha if alpha != ALPHA_OPAQUE
      s
    end

    def inspect   #:nodoc:
      "<#{to_s}>"
    end

    # Compare this color with another color. Returns *true* if the associated
    # red, green, blue, and alpha components are identical.
    def ==(other)
      other.kind_of?(Color) && rgba == other.rgba
    end

    # Return *true* if this color is visually identical to another color.
    def ===(other)
      self == other || (self.transparent? && other.transparent?)
    end

    # Compare this color with another color in a manner that takes into account
    # palette identities.
    def eql?(other)
      self == other &&
        (palette.nil? || other.palette.nil? ||
          (palette == other.palette && index == other.index))
    end

    def hash  #:nodoc:
      rgba.hash
    end

    def rgba=(value)  #:nodoc:
      @rgba = value
      @palette[@index] = self if from_palette?
    end

    # Return the red component of this color (0..RGB_MAX).
    def red
      (rgba & 0xFF0000) >> 16
    end
    alias r red

    # Modify the red component of this color. If this color is associated
    # with a palette entry, this also modifies the palette.
    def red=(value)
      self.rgba = (rgba & ~0xFF0000) |
        (self.class.normalize(value, RGB_MAX, :red) << 16)
    end
    alias r= red=

    # Return the green component of this color (0..RGB_MAX).
    def green
      (rgba & 0x00FF00) >> 8
    end
    alias g green

    # Modify the green component of this color. If this color is associated
    # with a palette entry, this also modifies the palette.
    def green=(value)
      self.rgba = (rgba & ~0x00FF00) |
        (self.class.normalize(value, RGB_MAX, :green) << 8)
    end
    alias g= green=

    # Return the blue component of this color (0..RGB_MAX).
    def blue
      rgba & 0x0000FF
    end
    alias b blue

    # Modify the blue component of this color. If this color is associated
    # with a palette entry, this also modifies the palette.
    def blue=(value)
      self.rgba = (rgba & ~0x0000FF) |
        self.class.normalize(value, RGB_MAX, :blue)
    end
    alias b= blue=

    # Return the alpha component of this color (0..ALPHA_MAX).
    def alpha
      (rgba & 0x7F000000) >> 24
    end
    alias a alpha

    # Modify the alpha component of this color. If this color is associated
    # with a palette entry, this also modifies the palette.
    def alpha=(value)
      self.rgba = (rgba & ~0xFF000000) |
        (self.class.normalize(value, ALPHA_MAX, :alpha) << 24)
    end
    alias a= alpha=

    # Alpha blend this color with the given color. If this color is associated
    # with a palette entry, this also modifies the palette.
    def alpha_blend!(other)
      self.rgba = ::GD2::GD2FFI.send(:gdAlphaBlend, rgba.to_i, other.rgba.to_i)
      self
    end
    alias << alpha_blend!

    # Like Color#alpha_blend! except returns a new Color without modifying
    # the receiver.
    def alpha_blend(other)
      dup.alpha_blend!(other)
    end

    # Return *true* if the alpha channel of this color is completely
    # transparent.
    def transparent?
      alpha == ALPHA_TRANSPARENT
    end

    # Return *true* if the alpha channel of this color is completely opaque.
    def opaque?
      alpha == ALPHA_OPAQUE
    end
  end
end
