require File.join(File.dirname(__FILE__), *%w[.. lib cocoagit])

require 'rubygems'
require 'test/unit'

# Grit (v 0.9.4) is not working under macruby
#require "mojombo-grit"

COCOAGIT_RUBY = File.join(File.dirname(__FILE__), "..")
COCOAGIT_REPO = File.join(COCOAGIT_RUBY, "..")

# define locations for resources
DOT_GIT = File.expand_path(File.join(COCOAGIT_REPO, *%w[UnitTests Resources dot_git]))