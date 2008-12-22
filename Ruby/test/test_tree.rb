require File.dirname(__FILE__) + '/helper'

class TestTree < Test::Unit::TestCase

  def setup
    @r = GITRepo.alloc.initWithRoot DOT_GIT, bare:true
    @tree = @r. treeWithSha1 "a9ecfd8989d7c427c5564cf918b264261866ce01"
  end
  
  def teardown
    @r = nil
    @tree = nil
  end
  
  def test_entry_count
    assert_equal 1, @tree.entries.count
  end
  
  # tree entry tests
  
  def test_entry_contents
    entry = @tree.entries.first
    assert_equal 100644, entry.mode
    assert_equal "index.html", entry.name 
    assert_equal "b8ea533af44f544877babe0aaabc1d7f3ed2593f", entry.sha1
  end

  def test_init_with_mode_name_hash
    first_entry = @tree.entries.first
    entry = GITTreeEntry.alloc.initWithMode 100644,
              name:"index.html",
              sha1:"b8ea533af44f544877babe0aaabc1d7f3ed2593f",
              parent:@tree.sha1
    assert_equal first_entry.mode, entry.mode
    assert_equal first_entry.name, entry.name
    assert_equal first_entry.sha1, entry.sha1
  end
  
  def test_init_with_modestring_name_hash
    first_entry = @tree.entries.first
    entry = GITTreeEntry.alloc.initWithModeString "100644",
              name:"index.html",
              sha1:"b8ea533af44f544877babe0aaabc1d7f3ed2593f",
              parent:@tree.sha1
    assert_equal first_entry.mode, entry.mode
    assert_equal first_entry.name, entry.name
    assert_equal first_entry.sha1, entry.sha1
  end
  

=begin
  # This is causing a segfault
  def test_init_with_entry_line
    entry = @tree.entries.first 
    entry_line = entry_line(entry.mode, entry.name, entry.sha1)
    
    new_entry = GITTreeEntry.alloc.initWithTreeLine entry_line, parent:@tree.sha1
    assert new_entry
    assert_equal entry, new_entry
  end
=end

  private
  
  def entry_line(mode, name, sha1)
    #NSString.alloc.initWithFormat "%o %s\0%s", arguments:[mode, name, [sha1].pack("H*")]
    "%o %s\0%s" % [mode, name, [sha1].pack("H*")]
  end
  
end