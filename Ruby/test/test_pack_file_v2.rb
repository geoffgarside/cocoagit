require File.dirname(__FILE__) + '/helper'

class TestPackFileV2 < Test::Unit::TestCase
  def setup
    @pack = GITPackFile.alloc.initWithPath File.join(DOT_GIT, "objects/pack/pack-709b858145841a007ab0c53e130630fd1eecea6f.pack")
  end
  
  def teardown
    @pack = nil
  end
  
  def test_version
    assert_equal 2, @pack.version
  end
  
  def test_object_count
    assert_equal 15, @pack.numberOfObjects
  end
    
  def test_has_object
    assert @pack.hasObjectWithSha1 "226e91f3b4cca13890325f5d33ec050beca99f89"
  end
  
  def test_checksum_string
    assert_equal "ac9654dde94bdb31dd50a50d20fe26c2c5cda925", @pack.checksumString
  end
  
  def test_verify_checksum
    assert @pack.verifyChecksum
  end
  
  def test_data_for_object
    sha = "226e91f3b4cca13890325f5d33ec050beca99f89"
    str = "#!/usr/bin/env ruby\n\nputs \"hello world!\"\n\nputs \"goodbye world.\"\n"
    data = str.dataUsingEncoding:NSUTF8StringEncoding
    
    assert data.isEqualTo @pack.dataForObjectWithSha1(sha)
  end
end