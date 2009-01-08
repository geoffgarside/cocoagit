require File.dirname(__FILE__) + '/helper'

class TestPackIndexV2 < Test::Unit::TestCase
  def setup
    @index = GITPackIndex.alloc.initWithPath File.join(DOT_GIT, "objects/pack/pack-709b858145841a007ab0c53e130630fd1eecea6f.idx")
  end
  
  def teardown
    @index = nil
  end
  
  def test_version
    assert_equal 2, @index.version
  end
  
  def test_object_count
    assert_equal 15, @index.numberOfObjects
  end
  
  def test_object_offset
    assert_equal 1032, @index.packOffsetForSha1("226e91f3b4cca13890325f5d33ec050beca99f89")
  end
  
  def test_has_object
    assert @index.hasObjectWithSha1 "226e91f3b4cca13890325f5d33ec050beca99f89"
  end
  
  def test_checksum_string
    assert_equal "d9b99e4efbd35769156692b946511b028b3ede83", @index.checksumString
  end
  
  def test_pack_checksum_string
    assert_equal "ac9654dde94bdb31dd50a50d20fe26c2c5cda925", @index.packChecksumString
  end
  
  def test_verify_checksum
    assert @index.verifyChecksum
  end
end