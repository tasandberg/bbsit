require 'test_helper'
require 'pry'
class BBSitTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BBSit::VERSION
  end

  def test_that_it_returns_gem_root
    root = BBSit.root
    main_module = File.join(root, 'lib', 'bbsit.rb')
    assert File.file?(main_module)
  end
end
