require './test/test_helper'

RUBYCMD = "#{Gem.ruby} -I #{File.join(File.dirname(__FILE__), '..', 'lib')}"

class LoadPathTest < Minitest::Test
  include TestHelper

  def test_loading_valid_path
    script = <<EOF
require "gd2-ffij"
GD2::Image.new(256, 256)
EOF
    msg = %x{#{RUBYCMD} -e '#{script}' 2>&1}
    assert($?.success?)
    assert(msg =~ /^\s*$/)
  end


  def test_use_invalid_glib_path_via_global
    script = <<EOF
$GD2_LIBRARY_FULL_PATH = "/some/invalid/path/libd.so.3"
require "gd2-ffij"
GD2::Image.new(256, 256)
EOF
    msg = %x{#{RUBYCMD} -e '#{script}' 2>&1}
    assert(!$?.success?)
    assert(msg =~ /LoadError/)
  end

  def test_use_invalid_glib_path_via_environment_variable
    script = <<EOF
require "gd2-ffij"
GD2::Image.new(256, 256)
EOF
    ENV['GD2_LIBRARY_FULL_PATH'] = "/some/other/invalid/path/lib.so.3"
    msg = %x{#{RUBYCMD} -e '#{script}' 2>&1}
    ENV.delete('GD2_LIBRARY_FULL_PATH')
    assert(!$?.success?)
    assert(msg =~ /LoadError/)
  end
end
