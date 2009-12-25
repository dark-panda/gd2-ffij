require 'test/unit'

$:.push 'lib'
require 'gd2'

class ImageTest < Test::Unit::TestCase
  include GD2

  def setup
    @image = Image.new(50, 50)
  end

  def test_image
    assert @image == Image.new(50, 50),
      'Images are not equal'
  end

  def teardown
    @image = nil
    GC.start
  end
end
