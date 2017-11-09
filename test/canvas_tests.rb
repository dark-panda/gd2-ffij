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
      pen.polygon([
        [ 64, 64 ],
        [ 192, 192 ],
        [ 64, 128 ]
      ])
    end
    assert(image == load_image('test_canvas_polygon.gd2'))
  end

  def test_filled_polygon
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
      pen.polygon([
        [ 64, 64 ],
        [ 192, 192 ],
        [ 64, 128 ]
      ], true)
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
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.font = GD2::Font::TrueType[PATH_TO_FONT, 32]
      pen.move_to(0, 128)
      pen.text("HELLO")
      pen.move_to(256, 128)
      pen.text("WORLD", Math::PI)
    end
    assert(image == load_image('test_text.gd2'))
  end

  def test_text_circle
    image = new_image
    image.draw do |pen|
      pen.color = image.palette.resolve(GD2::Color[32, 64, 128])
      pen.font = GD2::Font::TrueType[PATH_TO_FONT, 32]
      pen.move_to(128, 128)
      pen.text_circle('HELLO', 'WORLD', 100, 20, 1)
    end
    assert(image == load_image('test_text_circle.gd2'))
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
      pen.arc(128, 128, 256, 64, 0..(Math::PI))
      pen.color = red
      pen.move(128, 128)
      pen.fill_to(blue)
    end
    assert(image == load_image('test_fill_to.gd2'))
  end
end
