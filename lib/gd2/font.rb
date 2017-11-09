# frozen_string_literal: true; encoding: ASCII-8BIT
#
# See COPYRIGHT for license details.

module GD2
  #
  # = Description
  #
  # Font objects represent a particular font in a particular size.
  #
  # == Built-in Fonts
  #
  # The following font classes may be used without further instantiation:
  #
  #   Font::Tiny
  #   Font::Small
  #   Font::MediumBold
  #   Font::Large
  #   Font::Giant
  #
  # == TrueType Fonts
  #
  # To use a TrueType font, first instantiate the font at a particular size:
  #
  #   font = Font::TrueType[fontname, ptsize]
  #
  # Here +fontname+ may be a path to a TrueType font, or a fontconfig pattern
  # if fontconfig support is enabled (see Font::TrueType.fontconfig).
  #
  # See Font::TrueType.new for further options.
  class Font
    private_class_method :new

    def self.font_ptr   #:nodoc:
      ::GD2::GD2FFI.send(font_sym)
    end

    def self.draw(image_ptr, x, y, angle, string, fg)   #:nodoc:
      raise ArgumentError, "Angle #{angle} not supported for #{self}" unless
        angle == 0.degrees || angle == 90.degrees

      ::GD2::GD2FFI.send(angle > 0 ? :gdImageStringUp : :gdImageString, image_ptr,
        font_ptr, x.to_i, y.to_i, string, fg.to_i)
      nil
    end
  end

  class Font::Small < Font
    def self.font_sym   #:nodoc:
      :gdFontGetSmall
    end
  end

  class Font::Large < Font
    def self.font_sym   #:nodoc:
      :gdFontGetLarge
    end
  end

  class Font::MediumBold < Font
    def self.font_sym   #:nodoc:
      :gdFontGetMediumBold
    end
  end

  class Font::Giant < Font
    def self.font_sym   #:nodoc:
      :gdFontGetGiant
    end
  end

  class Font::Tiny < Font
    def self.font_sym   #:nodoc:
      :gdFontGetTiny
    end
  end

  class Font::TrueType
    class FontconfigError < StandardError; end
    class FreeTypeError < StandardError; end

    CHARMAP_UNICODE           =   0
    CHARMAP_SHIFT_JIS         =   1
    CHARMAP_BIG5              =   2

    FTEX_LINESPACE            =   1
    FTEX_CHARMAP              =   2
    FTEX_RESOLUTION           =   4
    FTEX_DISABLE_KERNING      =   8
    FTEX_XSHOW                =  16
    FTEX_FONTPATHNAME         =  32
    FTEX_FONTCONFIG           =  64
    FTEX_RETURNFONTPATHNAME   = 128

    def self.register(font) #:nodoc:
      Thread.current[:fontcount] ||= 0
      Thread.current[:fontcount] += 1

      if Thread.current[:fontcount].zero?
        raise FreeTypeError, 'FreeType library failed to initialize' unless
          ::GD2::GD2FFI.send(:gdFontCacheSetup).zero?
      end

      ObjectSpace.define_finalizer(font, font_finalizer)
    end

    def self.font_finalizer
      proc { unregister }
    end

    def self.unregister
      if Thread.current[:fontcount]
        Thread.current[:fontcount] -= 1
      else
        Thread.current[:fontcount] = 0
      end

      ::GD2::GD2FFI.send(:gdFontCacheShutdown) if Thread.current[:fontcount].zero?
    end

    private_class_method :font_finalizer, :unregister

    def self.fontconfig #:nodoc:
      if Thread.current[:fontconfig].nil?
        Thread.current[:fontconfig] = false
      end

      Thread.current[:fontconfig]
    end

    # Return a boolean indicating whether fontconfig support has been enabled.
    # The default is *false*.
    def self.fontconfig?
      fontconfig
    end

    # Set whether fontconfig support should be enabled. To use this, the GD
    # library must have been built with fontconfig support. Raises an error if
    # fontconfig support is unavailable.
    def self.fontconfig=(want)
      avail = !::GD2::GD2FFI.send(:gdFTUseFontConfig, want ? 1 : 0).zero?
      raise FontconfigError, 'Fontconfig not available' if want && !avail
      Thread.current[:fontconfig] = !!want
    end

    class << self
      alias [] new
    end

    # The effective path to this TrueType font
    attr_reader :fontpath

    # The chosen linespacing
    attr_reader :linespacing

    # The chosen charmap
    attr_reader :charmap

    # The chosen horizontal resolution hint
    attr_reader :hdpi

    # The chosen vertical resolution hint
    attr_reader :vdpi

    # Whether kerning is desired
    attr_reader :kerning

    # Instantiate a TrueType font given by +fontname+ (either a pathname or a
    # fontconfig pattern if fontconfig is enabled) and +ptsize+ (a point size
    # given as a floating point number).
    #
    # The possible +options+ are:
    #
    # - :linespacing => The desired line spacing for multiline text, expressed as
    #   a multiple of the font height. A line spacing of 1.0 is the minimum to
    #   guarantee that lines of text do not collide. The default according to GD
    #   is 1.05.
    #
    # - :charmap => Specify a preference for Unicode, Shift_JIS, or Big5
    #   character encoding. Use one of the constants
    #   Font::TrueType::CHARMAP_UNICODE, Font::TrueType::CHARMAP_SHIFT_JIS, or
    #   Font::TrueType::CHARMAP_BIG5.
    #
    # - :hdpi => The horizontal resolution hint for the rendering engine. The
    #   default according to GD is 96 dpi.
    #
    # - :vdpi => The vertical resolution hint for the rendering engine. The
    #   default according to GD is 96 dpi.
    #
    # - :dpi => A shortcut to specify both :hdpi and :vdpi.
    #
    # - :kerning => A boolean to specify whether kerning tables should be used,
    #   if fontconfig is available. The default is *true*.
    #
    def initialize(fontname, ptsize, options = {})
      @fontname, @ptsize = fontname, ptsize.to_f
      @linespacing = options.delete(:linespacing)
      @linespacing = @linespacing.to_f if @linespacing
      @charmap = options.delete(:charmap)
      @hdpi = options.delete(:hdpi)
      @vdpi = options.delete(:vdpi)
      if dpi = options.delete(:dpi)
        @hdpi ||= dpi
        @vdpi ||= dpi
      end
      @kerning = options.delete(:kerning)
      @kerning = true if @kerning.nil?

      self.class.register(self)

      # Get the font path (and verify existence of file)

      strex = strex(false, true)
      args = [ nil, nil, 0, @fontname, @ptsize, 0.0, 0, 0, '', strex ]
      r = ::GD2::GD2FFI.send(:gdImageStringFTEx, *args)

      raise FreeTypeError.new(r.read_string) unless r.null?
      @fontpath = strex[:fontpath].read_string
    ensure
      ::GD2::GD2FFI.send(:gdFree, strex[:fontpath])
    end

    def inspect   #:nodoc:
      result  = "#<#{self.class} #{@fontpath.inspect}, #{@ptsize}"
      result += ", :linespacing => #{@linespacing}" if @linespacing
      result += ", :charmap => #{@charmap}" if @charmap
      result += ", :hdpi => #{@hdpi}" if @hdpi
      result += ", :vdpi => #{@vdpi}" if @vdpi
      result += ", :kerning => #{@kerning}" unless @kerning
      result += '>'
    end

    def draw(image_ptr, x, y, angle, string, fg)  #:nodoc:
      brect = FFI::MemoryPointer.new(:int, 8)
      strex = strex(true)
      args = [ image_ptr, brect, fg, @fontname, @ptsize, angle.to_f, x.to_i, y.to_i, string.gsub('&', '&amp;'), strex ]

      r = ::GD2::GD2FFI.send(:gdImageStringFTEx, *args)
      raise FreeTypeError.new(r.read_string) unless r.null?
      brect = brect.read_array_of_int(8)

      if !strex[:xshow].null? && (xshow = strex[:xshow])
        begin
          xshow = xshow.read_string.split(' ').map { |e| e.to_f }
        ensure
          ::GD2::GD2FFI.send(:gdFree, strex[:xshow])
        end
      else
        xshow = []
      end

      sum = 0.0
      position = Array.new(xshow.length + 1)
      xshow.each_with_index do |advance, i|
        position[i] = sum
        sum += advance
      end
      position[-1] = sum

      { :lower_left   => [brect[0], brect[1]],
        :lower_right  => [brect[2], brect[3]],
        :upper_right  => [brect[4], brect[5]],
        :upper_left   => [brect[6], brect[7]],
        :position     => position
      }
    end

    def draw_circle(
      image_ptr, cx, cy, radius, text_radius, fill_portion,
      top, bottom, fgcolor
    ) #:nodoc:
      r = ::GD2::GD2FFI.send(
        :gdImageStringFTCircle, image_ptr, cx.to_i, cy.to_i,
        radius.to_f, text_radius.to_f, fill_portion.to_f, @fontname, @ptsize,
        top || '', bottom || '', fgcolor.to_i
      )
      raise FreeTypeError.new(r.read_string) unless r.null?
      nil
    end

    # Return a hash describing the rectangle that would enclose the given
    # string rendered in this font at the given angle. The returned hash
    # contains the following keys:
    #
    # - :lower_left => The [x, y] coordinates of the lower left corner.
    # - :lower_right => The [x, y] coordinates of the lower right corner.
    # - :upper_right => The [x, y] coordinates of the upper right corner.
    # - :upper_left => The [x, y] coordinates of the upper left corner.
    # - :position => An array of floating point character position offsets for
    #   each character of the +string+, beginning with 0.0. The array also
    #   includes a final position indicating where the last character ends.
    #
    # The _upper_, _lower_, _left_, and _right_ references are relative to the
    # text of the +string+, regardless of the +angle+.
    def bounding_rectangle(string, angle = 0.0)
      data = draw(nil, 0, 0, angle, string, 0)

      if string.length == 1
        # gd annoyingly fails to provide xshow data for strings of length 1
        position = draw(nil, 0, 0, angle, string + ' ', 0)[:position]
        data[:position] = position[0...-1]
      end

      data
    end

    private

    def strex(xshow = false, returnfontpathname = false)
      flags = 0
      flags |= FTEX_LINESPACE           if @linespacing
      flags |= FTEX_CHARMAP             if @charmap
      flags |= FTEX_RESOLUTION          if @hdpi || @vdpi
      flags |= FTEX_DISABLE_KERNING     unless @kerning
      flags |= FTEX_XSHOW               if xshow
      flags |= FTEX_RETURNFONTPATHNAME  if returnfontpathname

      strex = FFIStruct::FTStringExtraPtr.new
      strex[:flags] = flags
      strex[:linespacing] = @linespacing || 0.0
      strex[:charmap] = @charmap ? @charmap : 0
      strex[:hdpi] = @hdpi || @vdpi || 0
      strex[:vdpi] = @vdpi || @hdpi || 0
      strex
    end
  end
end
