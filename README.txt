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
* meta_project  # Required in order to make releases at RubyForge
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

== MORE INFORMATION:

* http://rspec.info
* 
