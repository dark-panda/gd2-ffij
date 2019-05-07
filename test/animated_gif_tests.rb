# frozen_string_literal: true; encoding: ASCII-8BIT

require './test/test_helper'

class AnimatedGifTest < Minitest::Test
  include TestHelper

  def test_animation
    image1 = GD2::Image::IndexedColor.new(256, 256)

    black = image1.palette.allocate(GD2::Color[0, 0, 0])
    white = image1.palette.allocate(GD2::Color[255, 255, 255])
    lime = image1.palette.allocate(GD2::Color[0, 255, 0])

    image1.draw do |pen|
      pen.color = white
      pen.line(64, 64, 192, 192)
    end

    image2 = GD2::Image::IndexedColor.new(256, 256)
    black = image2.palette.allocate(GD2::Color[0, 0, 0])
    white = image2.palette.allocate(GD2::Color[255, 255, 255])
    lime = image2.palette.allocate(GD2::Color[0, 255, 0])

    image2.draw do |pen|
      pen.color = lime
      pen.rectangle(32, 64, 192, 192)
    end

    anim = GD2::AnimatedGif.new
    anim.add(image1)
    anim.add(image2, delay: 50)
    anim.add(image1, delay: 50)
    anim.end

    output = StringIO.new

    anim.export(output)

    assert(output.read == File.read('test/images/test_animated_gif.gif'))
  end
end
