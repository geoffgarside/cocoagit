MacRuby + Cocoagit
==================

Towards the overall goal: "if it is easy, then we will do it", I've setup a
small MacRuby project inside the cocoagit repository in order to write unit 
tests in Ruby. In part, this is also a personal experiment with MacRuby.
The original goal was to test cocoagit using the 'grit' library, but 'grit'
does not work with MacRuby right now...

Eventually, it could be more than this, but I think testing in Ruby is
generally less painful than Objective-C, so this seemed like a good starting
point.

There are definitely some sharp edges, but overall, it's not too bad. To get
started, you'll need the latest build of MacRuby, the 0.3.0 release is missing
a key feature (wrapping C pointers).

## Install a self-contained version of MacRuby trunk

Inside the 'Ruby' directory, type:

    rake macruby:bootstrap

### Why do this?

Ideally, this section should be replaced by a link to the MacRuby download
page, pointing you to the latest release version.  Unfortunately, MacRuby
0.3.0 does not support creating 'Pointer' objects, which essentially wrap
references to (void *) C pointers. This pass-by-reference technique is
commonly used for NSErrors in the Foundation libraries.  We also use it to
do lazy loading in cocoagit.  Since we need to test these methods, lack of
Pointer support in 0.3.0 is a deal-breaker.

I have no control over MacRuby releases. However, masterkain maintains a
git clone of the MacRuby SVN repo on github, so rather than trying to navigate
branches of the SVN repo, just clone my MacRuby fork, pull the 'cocoagit'
branch, build and install it.  See the 'macruby' tasks in the Rakefile for
the necessary commands.

## Using cocoagit with MacRuby

### Run tests

    rake test

### Interactive Console with Cocoagit loaded

    rake console

### Do-it-yourself

Use the Macruby executables in ./bin.  See the [MacRuby tutorial][] for more
info.

[macruby tutorial]: http://www.macruby.org/trac/wiki/MacRubyTutorial