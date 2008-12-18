# Monkey patch for MacRuby 0.3.0 release version:
# String does not respond to :each, only :each_byte
class String; alias :each :each_line; end

require 'test/unit'
require "grit"

DOT_GIT = File.join(File.dirname(__FILE__), *%w[.. UnitTests Resources dot_git])

git_framework_xcode = File.join(File.dirname(__FILE__), '..', 'build', 'Debug', 'Git.framework')

framework git_framework_xcode