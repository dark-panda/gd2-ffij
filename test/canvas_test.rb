require 'test/unit'
require 'tmpdir'

require 'rubygems'
require 'gd2-jay'

require 'test/test_helper'

class CanvasTest < Test::Unit::TestCase
  include TestHelper

  def new_image
	GD2::Image.new(256, 256)
  end

  def test_line
	image = new_image
	image.draw do |pen|
	  pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
	  pen.line(64, 64, 192, 192)
	end
	assert(image == GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, 'test_canvas_line.gd2'))))
  end

  def test_rectangle
	image = new_image
	image.draw do |pen|
	  pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
	  pen.rectangle(64, 64, 192, 192)
	end
	assert(image == GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, 'test_canvas_rectangle.gd2'))))
  end

  def test_filled_rectangle
	image = new_image
	image.draw do |pen|
	  pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
	  pen.rectangle(64, 64, 192, 192, true)
	end
	assert(image == GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, 'test_canvas_filled_rectangle.gd2'))))
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
	assert(image == GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, 'test_canvas_polygon.gd2'))))
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
	assert(image == GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, 'test_canvas_filled_polygon.gd2'))))
  end

  def test_move_to_and_line_to
	image = new_image
	image.draw do |pen|
	  pen.color = image.palette.resolve(GD2::Color[255, 255, 255])
	  pen.move_to(64, 64)
	  pen.line_to(128, 128)
	end
	assert(image == GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, 'test_canvas_move_to_and_line_to.gd2'))))
  end
end
