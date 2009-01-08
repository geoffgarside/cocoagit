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

  def test_load_blob
    sha = "87f974580d485f3cfd5fd9cc62491341067f0c59"
    o = @r.objectWithSha1 sha, error:nil
    b = @r.blobWithSha1 sha, error:nil
    assert_equal o, b
    assert_equal "blob", o.type
    assert_equal "hello world!\n\ngoodbye world.\n", o.stringValue
  end
  
  def test_load_commit
    sha = "f7e7e7d240ccdae143b064aa7467eb2fa91aa8a5"
    o = @r.objectWithSha1 sha, error:nil
    c = @r.commitWithSha1 sha, error:nil
    assert_equal o, c
    assert_equal "commit", o.type
    assert_equal "removed bang, added goodbye message.", c.message.strip
  end
  
  def test_load_tree
    sha = "a9ecfd8989d7c427c5564cf918b264261866ce01"
    o = @r.objectWithSha1 sha, error:nil
    tree = @r.treeWithSha1 sha, error:nil
    assert_equal o, tree
    assert_equal "tree", o.type
    assert_equal 1, o.entries.count
  end
    
  def test_object_not_found
    errorp = Pointer.ptr
    o = @r.objectWithSha1 "1"*40, error:errorp
    assert_nil o
    assert_equal GITError::ObjectNotFound, errorp.value.code
  end
  
  def test_object_type_mismatch
    blob_sha = "87f974580d485f3cfd5fd9cc62491341067f0c59"
    errorp = Pointer.ptr
    o = @r.commitWithSha1 blob_sha, error:errorp
    assert_nil o
    assert_equal GITError::ObjectTypeMismatch, errorp.value.code
  end
  
end