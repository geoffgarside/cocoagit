require File.dirname(__FILE__) + '/helper'

class TestPackStore < Test::Unit::TestCase
  def setup
    @store = GITPackStore.alloc.initWithRoot DOT_GIT
  end
  
  def teardown
    @store = nil
  end
  
  def test_pack_dir
    assert_equal File.join(DOT_GIT, "objects/pack"), @store.packsDir
  end
    
  def test_load_object_with_sha
    sha = "226e91f3b4cca13890325f5d33ec050beca99f89"
    str = "#!/usr/bin/env ruby\n\nputs \"hello world!\"\n\nputs \"goodbye world.\"\n"
  
    data = str.dataUsingEncoding NSUTF8StringEncoding
    dataP = Pointer.ptr
    typeP = Pointer.ptr(:int)
    result = @store.loadObjectWithSha1 sha, intoData:dataP, type:typeP, error:nil
    
    assert result
    assert_equal 3, typeP.value
    assert data.isEqualTo dataP.value
  end
end