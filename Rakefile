dir = File.dirname(__FILE__)
$:.unshift(File.expand_path("#{dir}/lib"))
$:.unshift(File.expand_path("#{dir}/example_rails_app/vendor/plugins/rspec/lib"))
require "rspec/git"
require 'rubyforge'

def git
  RSpec::Git.new
end

namespace :git do
  desc "Update rspec-dev & sub-projects"
  task :update do
    git.update
  end

  desc "Update rspec-dev & sub-projects"
  task :pull => :update

  desc "Reset rspec-dev and sub-projects"
  task :hard_reset do
    git.hard_reset
  end
  
  desc "Tag rspec-dev and sub-projects"
  task :tag do
    git.tag
  end
end

if git.plugins_fetched?
  $LOAD_PATH.unshift(File.expand_path("#{dir}/pre_commit/lib"))
  require "pre_commit"
  
  task :default => :pre_commit
  
  desc "Runs pre_commit_core and pre_commit_rails"
  task :pre_commit do
    pre_commit.pre_commit
  end
  
  desc "Makes sure the correct versions of gems are on the system"
  task :check_for_gem_dependencies do
    pre_commit.check_for_gem_dependencies
  end
  
  desc "Runs pre_commit against rspec (core)"
  task :pre_commit_core do
    pre_commit.pre_commit_core
  end
  
  desc "Runs textmate bundle specs"
  task :pre_commit_textmate_bundle do
    pre_commit.pre_commit_textmate_bundle
  end
  
  desc "Runs pre_commit against example_rails_app (against all supported Rails versions)"
  task :pre_commit_rails do
    pre_commit.pre_commit_rails
  end
  
  task :ok_to_commit do |t|
    pre_commit.ok_to_commit
  end
  
  desc "Touches files storing revisions so that svn will update $LastChangedRevision"
  task :touch_revision_storing_files do
    pre_commit.touch_revision_storing_files
  end
  
  desc "Deletes generated documentation"
  task :clobber do
    rm_rf 'doc/output'
  end
  
  desc "Installs dependencies for development environment"
  task :install_dependencies do
    pre_commit.install_dependencies
  end
  
  desc "Updates dependencies for development environment"
  task :update_dependencies do
    pre_commit.update_dependencies
  end

  desc "Build the website, but do not publish it"
  task(:website) {core.website}

  def pre_commit
    PreCommit::Rspec.new(self)
  end
  
  desc "Fix line endings"
  task(:fix_cr_lf) {pre_commit.fix_cr_lf}
  
  namespace :git do
    desc "Commit rspec-dev & sub-projects"
    task :commit do
      git.commit
    end
    
    desc "Show status of rspec-dev & sub-projects"
    task :status do
      git.status
    end
  
    desc "Push rspec-dev & sub-projects to github"
    task :push do
      git.push
    end

    desc "Add remote references to rspec-dev & sub-projects"
    task :add_remotes do
      git.add_remotes
    end
  end
end

# desc "Run all specs and store html output in doc/output/report.html"
# Spec::Rake::SpecTask.new('spec_html') do |t|
#   t.spec_files = FileList['spec/**/*_spec.rb']
#   t.spec_opts = ['--format html:../../../../doc/output/report.html', '--format progress','--backtrace']
# end

def assign_version
  ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
end

desc "Package the RSpec.tmbundle"
task :package_tmbundle do
  version = assign_version
  mkdir 'pkg' rescue nil
  rm_rf "pkg/RSpec-#{version}.tmbundle" rescue nil
  `git clone RSpec.tmbundle pkg/RSpec-#{version}.tmbundle`
  rm_rf "pkg/RSpec-#{version}.tmbundle/.git"
  Dir.chdir 'pkg' do
    `tar zcvf RSpec-#{version}.tmbundle.tgz RSpec-#{version}.tmbundle`
  end
end

task :clobber_pkg do
  rm_rf "pkg"
end
task :clobber => :clobber_pkg

task :release_rspec do
  version = assign_version
  Dir.chdir 'example_rails_app/vendor/plugins/rspec' do
    sh 'rake release'
  end
end

task :release_rspec_rails do
  version = assign_version
  Dir.chdir 'example_rails_app/vendor/plugins/rspec-rails' do
    sh 'rake release'
  end
end

task :release_tmbundle do |t|
  version = assign_version
  abort "Versions don't match #{version} vs #{Spec::VERSION::STRING}" unless version == Spec::VERSION::STRING
  
  rubyforge = RubyForge.new.configure
  puts "Logging in to rubyforge ..."
  rubyforge.login
  
  puts "Releasing rspec-rails version #{version} ..."
  rubyforge.add_file('rspec', 'rspec', Spec::VERSION::STRING, "pkg/RSpec-#{version}.tmbundle.tgz")
end
  
task :release_tmbundle => :package_tmbundle

task :release => [:release_rspec, :release_rspec_rails, :release_tmbundle]