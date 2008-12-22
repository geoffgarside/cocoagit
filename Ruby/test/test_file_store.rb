require File.dirname(__FILE__) + '/helper'

class TestFileStore < Test::Unit::TestCase
  def setup
    @store = GITFileStore.alloc.initWithRoot DOT_GIT
  end
  
  def teardown
    @store = nil
  end
  
  def test_objects_dir
    assert_equal File.join(DOT_GIT, "objects"), @store.objectsDir
  end
  
  def test_path_for_object
    sha = "87f974580d485f3cfd5fd9cc62491341067f0c59"
    expected = File.join(DOT_GIT, "objects/87/f974580d485f3cfd5fd9cc62491341067f0c59")
    assert_equal expected, @store.stringWithPathToObject(sha)
  end
  
  def test_data_with_contents_of_object
    sha = "87f974580d485f3cfd5fd9cc62491341067f0c59"
    str = "blob 29\x00hello world!\n\ngoodbye world.\n"
    
    # BUG: There appears to a MacRuby bug in NSString#dataUsingEncoding
    #      If the ruby string contains a null (\0 or \x00), then
    #      The data object returned encodes a string full of spaces (\020)
    #      instead of the actual string data.
    data = str.dataUsingEncoding NSUTF8StringEncoding
    store_data = @store.dataWithContentsOfObject(sha)
    store_str = NSString.alloc.initWithData store_data, encoding:NSUTF8StringEncoding
    # This next assertion fails...
    # assert_equal data, store_data
    
    # For now, just check that strings are the same!
    assert_equal str, store_str
  end
  
  def test_load_object_with_sha
    sha = "87f974580d485f3cfd5fd9cc62491341067f0c59"
    str = "hello world!\n\ngoodbye world.\n"
  
    data = str.dataUsingEncoding NSUTF8StringEncoding
    dataP = Pointer.ptr
    typeP = Pointer.ptr(:int)
    result = @store.loadObjectWithSha1 sha, intoData:dataP, type:typeP, error:nil
    
    assert result
    assert_equal 3, typeP.value
    assert data.isEqualTo dataP.value
  end
end