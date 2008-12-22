$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

unless defined? RUBY_ENGINE && RUBY_ENGINE == 'macruby'
  puts "You need to install MacRuby"
  exit 1
end

# load custom macruby extensions
require 'cocoagit/extensions/macruby'

# load frameworks
framework 'Foundation'
git_xcode = File.join(File.dirname(__FILE__), '..', '..', 'build', 'Debug', 'Git.framework')
framework git_xcode

# load macruby extensions for cocoagit classes
require 'cocoagit/extensions/cocoagit'
