require File.dirname(__FILE__) + '/helper'

class TestCommit < Test::Unit::TestCase

  def setup
    @r = GITRepo.alloc.initWithRoot DOT_GIT, bare:true
  end
  
  def teardown
    @r = nil
  end
  
  def test_read_commit
    commit = @r.commitWithSha1 "f7e7e7d240ccdae143b064aa7467eb2fa91aa8a5", error:nil
    assert commit
    expected = { 
      "message"=>"removed bang, added goodbye message.",
      "parents"=>{"id"=>"2bb318d2c722b344f6fae8ec274d0c7df9020544"},
      "authored_date"=>"Wed Oct 22 20:02:50 2008 -0700",
      "tree"=>"e252da6072a2f887a1f0165177ec068baf566d0e",
      "committer"=>{"name"=>"Brian Chapados ", "email"=>"chapados@sciencegeeks.org"},
      "author"=>{"name"=>"Brian Chapados ", "email"=>"chapados@sciencegeeks.org"},
      "id"=>"f7e7e7d240ccdae143b064aa7467eb2fa91aa8a5",
      "committed_date"=>"Wed Oct 22 20:02:50 2008 -0700"
    }
    assert_equal expected, commit.to_hash
  end

  def test_unknown_object_error
    errorP = Pointer.ptr
    commit = @r.commitWithSha1 "0007e7d240ccdae143b064aa7467eb2fa91aa8a5", error:errorP
    assert_nil commit
    assert_equal GITError::ObjectNotFound, errorP.value.code
  end
  
end