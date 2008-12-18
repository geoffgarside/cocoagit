require File.dirname(__FILE__) + '/helper'

class TestCommit < Test::Unit::TestCase

  def setup
    @r = GITRepo.alloc.initWithRoot DOT_GIT, bare:true
  end
  
  def teardown
    @r = nil
  end
  
  def test_load_commit
    commit = @r.commitWithSha1 "f7e7e7d240ccdae143b064aa7467eb2fa91aa8a5", error:nil
    assert commit
  end

  def test_unknown_object_error
    errorP = Pointer.allocate.new
    commit = @r.commitWithSha1 "0007e7d240ccdae143b064aa7467eb2fa91aa8a5", error:nil
    
    assert_nil commit
  end

end