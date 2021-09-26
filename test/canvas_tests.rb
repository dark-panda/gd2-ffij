# frozen_string_literal: true; encoding: ASCII-8BIT

require './test/test_helper'

class CanvasTest < Minitest::Test
  include TestHelper

  def test_line
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
      pen.line(64, 64, 192, 192)
    end
    assert(image == load_image('test_canvas_line.gd2'))
  end

  def test_rectangle
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
      pen.rectangle(64, 64, 192, 192)
    end
    assert(image == load_image('test_canvas_rectangle.gd2'))
  end

  def test_filled_rectangle
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
      pen.rectangle(64, 64, 192, 192, true)
    end
    assert(image == load_image('test_canvas_filled_rectangle.gd2'))
  end

  def test_polygon
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
      pen.polygon([[64, 64], [192, 192], [64, 128]])
    end
    assert(image == load_image('test_canvas_polygon.gd2'))
  end

  def test_filled_polygon
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
      pen.polygon([[64, 64], [192, 192], [64, 128]], true)
    end
    assert(image == load_image('test_canvas_filled_polygon.gd2'))
  end

  def test_move_to_and_line_to
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
      pen.move_to(64, 64)
      pen.line_to(128, 128)
    end
    assert(image == load_image('test_canvas_move_to_and_line_to.gd2'))
  end

  def test_fill
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.rectangle(64, 64, 192, 192)
      pen.move_to(65, 65)
      pen.fill
    end
    assert(image == load_image('test_fill.gd2'))
  end

  def test_arc
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.arc(128, 128, 128, 128, 0..256)
    end
    assert(image == load_image('test_arc.gd2'))
  end

  def test_text
    image = new_image
    clr = GD2::Color[32, 64, 128]
    image.draw do |pen|
      pen.color = image.palette.resolve(clr)
      pen.font = GD2::Font::TrueType[PATH_TO_FONT, 32]
      pen.move_to(0, 128)
      pen.text('HELLO')
      pen.move_to(256, 128)
      pen.text('WORLD', Math::PI)
    end

    # The test used to do this
    #
    #   assert(image == load_image('test_text.gd2'))
    #
    # but the problem is that font rendering tend to be imprecise,
    # which makes this *really* fragile.  Instead, we just render the
    # text and make sure it's roughly where we expect it to be

    rows = rows_with_color(image, clr)
    top = rows[0]
    bottom = rows[-1]

    # We expect at least 2 rows back.  (Tens of rows, actually)
    assert(rows.size >= 2)

    # We know row 128 will have text on it
    assert(top < 128 && bottom > 128)

    # We know the top and bottom should be untouched
    assert(top > 50 && bottom < 256 - 50)
  end

  def test_text_circle
    image = new_image
    clr = GD2::Color[32, 64, 128]
    image.draw do |pen|
      pen.color = image.palette.resolve(clr)
      pen.font = GD2::Font::TrueType[PATH_TO_FONT, 32]
      pen.move_to(128, 128)
      pen.text_circle('HELLO', 'WORLD', 100, 20, 1)
    end

    # As with test_text() above, font rendering variations make this
    # test really fragile so once again, we just poke around the region.

    rows = rows_with_color(image, clr)
    top = rows[0]
    bottom = rows[-1]

    # We expect at least 2 rows back.  (Tens of rows, actually)
    assert(rows.size >= 2)

    # We know that the ring of text occupies most of the image, so the
    # top and bottom of the text are going to be pretty close to the
    # top and bottom of the image (which is 256x256).
    assert(top < 40 && bottom > 210)

    # But there'll be *some* free space
    assert(top > 10 && bottom < 256 - 10)
  end

  def test_wedge
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.wedge(128, 128, 256, 256, 0..180)
    end
    assert(image == load_image('test_wedge.gd2'))
  end

  def test_filled_wedge
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.wedge(128, 128, 256, 256, 0..180, true)
    end
    assert(image == load_image('test_filled_wedge.gd2'))
  end

  def test_ellipse
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.ellipse(128, 128, 64, 32)
    end
    assert(image == load_image('test_ellipse.gd2'))
  end

  def test_filled_ellipse
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.ellipse(128, 128, 64, 32, true)
    end
    assert(image == load_image('test_filled_ellipse.gd2'))
  end

  def test_circle
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.circle(128, 128, 128)
    end
    assert(image == load_image('test_circle.gd2'))
  end

  def test_filled_circle
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.circle(128, 128, 128, true)
    end
    assert(image == load_image('test_filled_circle.gd2'))
  end

  def test_fill_to
    image = new_image
    image.draw do |pen|
      blue = image.palette.resolve(GD2::Color[32, 64, 128])
      red  = image.palette.resolve(GD2::Color[255, 0, 0])
      pen.color = blue
      pen.arc(128, 128, 256, 64, 0..Math::PI)
      pen.color = red
      pen.move(128, 128)
      pen.fill_to(blue)
    end
    assert(image == load_image('test_fill_to.gd2'))
  end
end
