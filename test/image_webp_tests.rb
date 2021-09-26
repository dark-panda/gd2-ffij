# frozen_string_literal: true; encoding: ASCII-8BIT

require './test/test_helper'

class ImageWebpTest < Minitest::Test
  include TestHelper

  def test_import_webp_from_file
    GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
  end

  def test_export_webp
    img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).to_true_color
    out = File.join(Dir.tmpdir, 'test.webp')
    img.export(out)

    assert(File.exist?(out))

    img_a = GD2::Image.import(out)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))

    assert(img_a == img_b)

    File.unlink(out)
  end

  def test_export_and_import_webp_io
    img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).to_true_color
    out = StringIO.new
    img.export(out, format: :webp)

    img_a = GD2::Image.import(out)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))

    assert(img_a == img_b)
  end

  def test_compare_webp
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    assert_equal(img_a.compare(img_b), 0)
    assert_equal(img_a.compare(img_a.dup), 0)
  end

  def test_eqeq_webp
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    assert(img_a == img_b)
    assert(img_a == img_a.dup)
  end

  def test_height_webp
    img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    assert_equal(img.height, 256)
  end

  def test_width_webp
    img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    assert_equal(img.width, 256)
  end

  def test_size_webp
    img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    assert_equal(img.size, [ 256, 256 ])
  end

  def test_aspect_webp
    img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.webp'))
    assert_in_delta(img.aspect, 1.0, 0.00000001)
  end
end
