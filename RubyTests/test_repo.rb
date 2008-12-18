require File.dirname(__FILE__) + '/helper'

class TestRepo < Test::Unit::TestCase

  def setup
    @r = GITRepo.alloc.initWithRoot DOT_GIT, bare:true
  end
  
  def teardown
    @r = nil
  end
  
  def test_init_bare
    repo = GITRepo.alloc.initWithRoot DOT_GIT, bare:true
    assert repo
    assert repo.bare?
  end
  
  def test_description
    assert_equal "Unnamed repository; edit this file to name it for gitweb.\n", @r.desc
  end

end