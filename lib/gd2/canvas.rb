# frozen_string_literal: true; encoding: ASCII-8BIT
#
# See COPYRIGHT for license details.

require 'matrix'

module GD2
  class Canvas
    class NoColorSelectedError < StandardError; end
    class NoFontSelectedError < StandardError; end

    class Point
      attr_reader :x, :y

      def initialize(x, y)
        @x, @y = x, y
      end

      def coordinates
        [@x, @y]
      end

      def transform!(matrix)
        @x, @y = (Matrix.row_vector([@x, @y, 1]) * matrix)[0, 0..1]
        self
      end

      def transform(matrix)
        dup.transform!(matrix)
      end

      def draw(image, mode)
        image.set_pixel(@x, @y, mode)
      end
    end

    class Line
      def initialize(point1, point2)
        @p1, @p2 = point1, point2
      end

      def draw(image, mode)
        ::GD2::GD2FFI.send(:gdImageLine, image.image_ptr,
          @p1.x.to_i, @p1.y.to_i, @p2.x.to_i, @p2.y.to_i, mode.to_i)
        nil
      end
    end

    class Rectangle
      def initialize(point1, point2)
        @p1, @p2 = point1, point2
      end

      def draw(image, mode)
        ::GD2::GD2FFI.send(draw_sym, image.image_ptr, @p1.x.to_i, @p1.y.to_i, @p2.x.to_i, @p2.y.to_i, mode.to_i)
        nil
      end

      def draw_sym
        :gdImageRectangle
      end
    end

    class FilledRectangle < Rectangle
      def draw_sym
        :gdImageFilledRectangle
      end
    end

    class Polygon
      def initialize(points)
        @points = points
      end

      def draw(image, mode)
        ::GD2::GD2FFI.send(draw_sym, image.image_ptr, @points.map { |point|
          point.coordinates.pack('i_i_')
        }.join(''), @points.length, mode.to_i)
        nil
      end

      def draw_sym
        :gdImagePolygon
      end
    end

    class OpenPolygon < Polygon
      def draw_sym
        :gdImageOpenPolygon
      end
    end

    class FilledPolygon < Polygon
      def draw_sym
        :gdImageFilledPolygon
      end
    end

    class Arc
      def initialize(center, width, height, range)
        @center, @width, @height = center, width, height
        @range = Range.new(360.degrees - range.end, 360.degrees - range.begin,
          range.exclude_end?)
      end

      def draw(image, mode)
        ::GD2::GD2FFI.send(:gdImageArc, image.image_ptr, @center.x.to_i, @center.y.to_i,
          @width.to_i, @height.to_i,
          @range.begin.to_degrees.round.to_i, @range.end.to_degrees.round.to_i, mode.to_i)
        nil
      end
    end

    class Wedge < Arc
      # Arc styles

      ARC             = 0
      PIE             = ARC
      CHORD           = 1
      NO_FILL         = 2
      EDGED           = 4

      def initialize(center, width, height, range, chord = false)
        super(center, width, height, range)
        @chord = chord
      end

      def draw(image, mode)
        ::GD2::GD2FFI.send(:gdImageFilledArc, image.image_ptr, @center.x.to_i, @center.y.to_i,
          @width.to_i, @height.to_i,
          @range.begin.to_degrees.round.to_i, @range.end.to_degrees.round.to_i,
          mode.to_i, style.to_i)
        nil
      end

      def style
        (@chord ? CHORD : ARC) | NO_FILL | EDGED
      end
    end

    class FilledWedge < Wedge
      def style
        super & ~(NO_FILL | EDGED)
      end
    end

    class Ellipse
      def initialize(center, width, height)
        @center, @width, @height = center, width, height
      end

      def draw(image, mode)
        ::GD2::GD2FFI.send(:gdImageArc, image.image_ptr, @center.x.to_i, @center.y.to_i,
          @width.to_i, @height.to_i, 0, 360, mode.to_i)
        nil
      end
    end

    class FilledEllipse < Ellipse
      def draw(image, mode)
        ::GD2::GD2FFI.send(:gdImageFilledEllipse, image.image_ptr, @center.x.to_i, @center.y.to_i,
          @width.to_i, @height.to_i, mode.to_i)
      end
    end

    class Text
      def initialize(font, point, angle, string)
        @font = font
        @point = point
        @angle = angle
        @string = string
      end

      def draw(image, color)
        @font.draw(image.image_ptr, @point.x, @point.y, @angle, @string, color)
      end
    end

    class TextCircle
      def initialize(font, point, radius, text_radius, fill_portion,
          top, bottom)
        @font = font
        @point = point
        @radius = radius
        @text_radius = text_radius
        @fill_portion = fill_portion
        @top = top
        @bottom = bottom
      end

      def draw(image, color)
        @font.draw_circle(image.image_ptr, @point.x, @point.y, @radius,
          @text_radius, @fill_portion, @top, @bottom, color)
      end
    end

    attr_reader :color, :thickness, :style, :brush, :tile, :dont_blend,
      :transformation_matrix
    attr_accessor :anti_aliasing, :font

    # Special colors

    STYLED          = -2
    BRUSHED         = -3
    STYLED_BRUSHED  = -4
    TILED           = -5

    TRANSPARENT     = -6  # Line styles only; not a color index
    ANTI_ALIASED    = -7

    def initialize(image)
      @image = image
      self.thickness = 1
      self.anti_aliasing = false
      @transformation_matrix = Matrix.identity(3)
      move_to(0, 0)
    end

    def color=(color)
      @pixel = @image.color2pixel(@color = color)
      @brush = @style = nil
    end

    def thickness=(thickness)
      ::GD2::GD2FFI.send(:gdImageSetThickness, @image.image_ptr, @thickness = thickness.to_i)
    end

    def style=(ary)
      if @style = ary
        ::GD2::GD2FFI.send(:gdImageSetStyle, @image.image_ptr,
          ary.map { |c|
            !c ? TRANSPARENT : true == c ? -1 : @image.color2pixel(c)
          }, ary.length)
      end
    end

    def brush=(image)
      if @brush = image
        ::GD2::GD2FFI.send(:gdImageSetBrush, @image.image_ptr, image.image_ptr)
      end
    end

    def tile=(image)
      if @tile = image
        ::GD2::GD2FFI.send(:gdImageSetTile, @image.image_ptr, image.image_ptr)
      end
    end

    alias anti_aliasing? anti_aliasing

    def dont_blend=(color)
      @dont_blend = color ? @image.color2pixel(color) : nil
    end

    def affine_transform(a, b, c, d, tx, ty)
      old_matrix = @transformation_matrix
      begin
        @transformation_matrix = Matrix[[a, b, 0], [c, d, 0], [tx, ty, 1]] *
          @transformation_matrix
        yield
      ensure
        @transformation_matrix = old_matrix
      end
    end

    def translate(tx, ty)
      affine_transform(1, 0, 0, 1, tx, ty) { |*block_args|
        yield(*block_args)
    }
    end

    def scale(sx, sy = sx)
      affine_transform(sx, 0, 0, sy, 0, 0) { |*block_args|
        yield(*block_args)
      }
    end

    def rotate(angle)
      cos = Math.cos(angle)
      sin = Math.sin(angle)
      affine_transform(cos, sin, -sin, cos, 0, 0) { |*block_args|
        yield(*block_args)
      }
    end

    def cartesian
      affine_transform(1, 0, 0, -1, 0, @image.height - 1) { |*block_args|
        yield(*block_args)
      }
    end

    def point(x, y)
      Point.new(x, y).transform!(transformation_matrix)
    end

    def move_to(x, y)
      @point = point(x, y)
      self
    end

    def move(x, y)
      @point.transform!(Matrix[[1, 0, 0], [0, 1, 0], [x, y, 1]] *
        @transformation_matrix)
      # @point = point(@point.x + x, @point.y + y)
      self
    end

    def location
      @point.transform(transformation_matrix.inverse).coordinates
    end

    def line(x1, y1, x2, y2)
      Line.new(point(x1, y1), point(x2, y2)).draw(@image, line_pixel)
    end

    def line_to(x, y)
      point2 = point(x, y)
      Line.new(@point, point2).draw(@image, line_pixel)
      @point = point2
      self
    end

    def fill
      ::GD2::GD2FFI.send(:gdImageFill, @image.image_ptr, @point.x.to_i, @point.y.to_i, fill_pixel.to_i)
      self
    end

    def fill_to(border)
      # An apparent bug in gd prevents us from using fill_pixel
      ::GD2::GD2FFI.send(:gdImageFillToBorder, @image.image_ptr, @point.x.to_i, @point.y.to_i,
        @image.color2pixel(border), pixel.to_i)
      self
    end

    def rectangle(x1, y1, x2, y2, filled = false)
      (filled ? FilledRectangle : Rectangle).new(point(x1, y1), point(x2, y2)).
        draw(@image, filled ? fill_pixel : line_pixel)
    end

    def polygon(points, filled = false, open = false)
      points = points.map { |(x, y)| point(x, y) }
      if filled
        FilledPolygon.new(points).draw(@image, fill_pixel)
      else
        (open ? OpenPolygon : Polygon).new(points).draw(@image, line_pixel)
      end
    end

    def arc(cx, cy, width, height, range)
      Arc.new(point(cx, cy), width, height, range).draw(@image, line_pixel)
    end

    def wedge(cx, cy, width, height, range, filled = false, chord = false)
      (filled ? FilledWedge : Wedge).new(point(cx, cy), width, height,
        range, chord).draw(@image, filled ? fill_pixel : line_pixel)
    end

    def ellipse(cx, cy, width, height, filled = false)
      (filled ? FilledEllipse : Ellipse).new(point(cx, cy), width, height).
        draw(@image, filled ? fill_pixel : line_pixel)
    end

    def circle(cx, cy, diameter, filled = false)
      ellipse(cx, cy, diameter, diameter, filled)
    end

    def text(string, angle = 0.0)
      Text.new(get_font, @point, angle, string).draw(@image, pixel)
    end

    def text_circle(top, bottom, radius, text_radius, fill_portion)
      TextCircle.new(get_font, @point, radius, text_radius, fill_portion,
        top, bottom).draw(@image, pixel)
    end

    private

    def get_font
      raise NoFontSelectedError, 'No font selected' unless @font
      @font
    end

    def pixel
      raise NoColorSelectedError, 'No drawing color selected' unless @pixel
      @pixel
    end

    def line_pixel
      if @style && @brush
        STYLED_BRUSHED
      elsif @style
        STYLED
      elsif @brush
        BRUSHED
      elsif anti_aliasing?
        if @dont_blend
          ::GD2::GD2FFI.send(:gdImageSetAntiAliasedDontBlend, @image.image_ptr,
            pixel.to_i, @dont_blend.to_i)
        else
          ::GD2::GD2FFI.send(:gdImageSetAntiAliased, @image.image_ptr, pixel.to_i)
        end
        ANTI_ALIASED
      else
        pixel
      end
    end

    def fill_pixel
      defined?(@tile) ? TILED : pixel
    end
  end
end
