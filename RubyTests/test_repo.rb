require File.dirname(__FILE__) + '/helper'

class TestRepo < Test::Unit::TestCase

  def setup
    @r = GITRepo.initWithRoot DOT_GIT, bare:true
  end
  
  def teardown
    @r = nil
  end
  
  def test_init_bare
    repo = GITRepo.initWithRoot DOT_GIT, bare:true
    assert_not_nil repo
    assert_true repo.bare
  end
  
  def test_description
    assert_equal "Unnamed repository; edit this file to name it for gitweb.", @r.description
  end

end