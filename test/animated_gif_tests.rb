# frozen_string_literal: true; encoding: ASCII-8BIT

require './test/test_helper'

class AnimatedGifTest < Minitest::Test
  include TestHelper

  def test_animation
    img_a = GD2::Image::IndexedColor.new(256, 256)

    img_a.palette.allocate(GD2::Color[0, 0, 0])

    white = img_a.palette.allocate(GD2::Color[255, 255, 255])
    lime = img_a.palette.allocate(GD2::Color[0, 255, 0])

    img_a.draw do |pen|
      pen.color = white
      pen.line(64, 64, 192, 192)
    end

    img_b = GD2::Image::IndexedColor.new(256, 256)

    img_b.palette.allocate(GD2::Color[0, 0, 0])

    white = img_b.palette.allocate(GD2::Color[255, 255, 255])
    lime = img_b.palette.allocate(GD2::Color[0, 255, 0])

    img_b.draw do |pen|
      pen.color = lime
      pen.rectangle(32, 64, 192, 192)
    end

    anim = GD2::AnimatedGif.new
    anim.add(img_a)
    anim.add(img_b, delay: 50)
    anim.add(img_a, delay: 50)
    anim.end

    output = StringIO.new

    anim.export(output)

    assert(output.read == File.read('test/images/test_animated_gif.gif'))
  end
end
