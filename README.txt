= rspec-dev

* http://rspec.info
* http://github.com/dchelimsky/rspec-dev/wikis
* mailto:rspec-devel@rubyforge.org

== DESCRIPTION:

This project is for RSpec developers/contributors.

== INSTALL:

  git-clone git://github.com/dchelimsky/rspec-dev.git
  cd rspec-dev
  rake git:update

== RUNNING EXAMPLES:

In order to run RSpec's full suite of examples (rake pre_commit) you must install the following gems:

* rake          # Runs the build script
* rcov          # Verifies that the code is 100% covered by specs
* syntax        # Required to highlight ruby code
* diff-lcs      # Required if you use the --diff switch
* win32console  # Required by the --colour switch if you're on Windows
* hoe           # Required in order to make releases at RubyForge
* heckle        # Required if you use the --heckle switch
* hpricot       # Used for parsing HTML from the HTML output formatter in RSpec's own specs

Once those are all installed, you should be able to run the suite with the following steps:

* cd /path/to/rspec-dev
* rake install_dependencies
* cd example_rails_app
* export RSPEC_RAILS_VERSION=2.1.0
* rake rspec:generate_sqlite3_config
* cd ..
* rake pre_commit

Note that RSpec itself - once built - doesn't have any dependencies outside
the Ruby core and stdlib - with a few exceptions:

* The spec command line uses diff-lcs when --diff is specified.
* The spec command line uses heckle when --heckle is specified.
* The Spec::Rake::SpecTask needs RCov if RCov is enabled in the task.

== LICENSE:

(The MIT License)

Copyright (c) 2005-2008 The RSpec Development Team

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
