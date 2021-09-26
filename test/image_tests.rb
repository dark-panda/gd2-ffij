# frozen_string_literal: true; encoding: ASCII-8BIT

require './test/test_helper'

class ImageTest < Minitest::Test
  include TestHelper

  def test_invalid_image_sizes
    assert_raises(ArgumentError) do
      GD2::Image.new(-10, 10)
    end

    assert_raises(ArgumentError) do
      GD2::Image.new(0, 10)
    end

    assert_raises(ArgumentError) do
      GD2::Image.new(10, -10)
    end

    assert_raises(ArgumentError) do
      GD2::Image.new(10, 0)
    end

    assert_raises(GD2::Image::MemoryAllocationError) do
      n_bytes = [42].pack('i').size
      n_bits = n_bytes * 8
      max = 2 ** (n_bits - 2) - 1

      GD2::Image.new(max, max)
    end
  end

  def test_image_new_and_release
    GD2::Image.new(50, 50)
  end

  def test_image_true_color_new_and_release
    GD2::Image::TrueColor.new(50, 50)
  end

  def test_image_indexed_color_new_and_release
    GD2::Image::IndexedColor.new(50, 50)
  end

  [:png, :gif, :jpg, :wbmp, :gd2].each do |ext|
    class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
      def test_load_#{ext}_from_file
        GD2::Image.load(File.open(File.join(PATH_TO_IMAGES, 'test.#{ext}')))
      end

      def test_load_#{ext}_from_string
        GD2::Image.load(File.read(File.join(PATH_TO_IMAGES, 'test.#{ext}')))
      end
    RUBY
  end

  # TODO: add xbm, xpm and wbmp tests
  [:png, :gif, :jpg, :gd, :gd2].each do |ext|
    class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
      def test_import_#{ext}_from_file
        GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
      end

      def test_export_#{ext}
        img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2'))
        out = File.join(Dir.tmpdir, 'test.#{ext}')
        img.export(out)

        assert(File.exist?(out))

        img_a = GD2::Image.import(out)
        img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))

        assert(img_a == img_b)

        File.unlink(out)
      end

      def test_export_and_import_#{ext}_io
        img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2'))
        out = StringIO.new
        img.export(out, format: :#{ext})

        img_a = GD2::Image.import(out)
        img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))

        assert(img_a == img_b)
      end

      def test_compare_#{ext}
        img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        assert_equal(img_a.compare(img_b), 0)
        assert_equal(img_a.compare(img_a.dup), 0)
      end

      def test_eqeq_#{ext}
        img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        assert(img_a == img_b)
        assert(img_a == img_a.dup)
      end

      def test_height_#{ext}
        img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        assert_equal(img.height, 256)
      end

      def test_width_#{ext}
        img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        assert_equal(img.width, 256)
      end

      def test_size_#{ext}
        img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        assert_equal(img.size, [ 256, 256 ])
      end

      def test_aspect_#{ext}
        img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.#{ext}'))
        assert_in_delta(img.aspect, 1.0, 0.00000001)
      end
    RUBY
  end

  def test_rotate
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).rotate!(Math::PI)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_rotated_180.gd2'))

    assert(img_a == img_b)
  end

  def test_crop
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).crop!(64, 64, 128, 128)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_cropped.gd2'))

    assert(img_a == img_b)
  end

  def test_uncrop
    img = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).crop!(64, 64, 128, 128)
    img.uncrop!(64)

    assert_equal(img.size, [256, 256])
  end

  def test_resize
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).resize!(512, 512)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_resized.gd2'))

    assert(img_a == img_b)
  end

  def test_resampled
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).resize!(512, 512, true)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_resampled.gd2'))

    assert(img_a == img_b)
  end

  def test_polar_transform
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test.gd2')).polar_transform!(100)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_polar_transform.gd2'))

    assert(img_a == img_b)
  end

  def test_color_sharpened
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_color.gd2')).sharpen(100)
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_color_sharpened.gd2'))

    assert(img_a == img_b)
  end

  def test_to_indexed_color
    img_a = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_color.gd2')).to_indexed_color
    img_b = GD2::Image.import(File.join(PATH_TO_IMAGES, 'test_color_indexed.gd2'))

    assert(img_a == img_b)
  end
end
