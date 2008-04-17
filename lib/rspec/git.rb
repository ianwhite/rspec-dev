module RSpec
  class Git
    def fetch_plugins
      submodules.each do |s|
        puts "** Fetching #{s[:name]}"
        system "git clone #{s[:url]} #{s[:path]}"
      end
    end

    def plugins_fetched?
      submodules.all? {|s| File.directory?(s[:path]) }
    end
    
    def update
      check_for_clean_repos "Unable to update"
      
      submodules.each do |s|
        puts "** Updating #{s[:name]}"
        unless system("cd #{s[:path]} && git pull --rebase")
          puts "Error updating #{s[:name]}"
          exit 1
        end
      end

      puts "** Updating #{superproject[:name]}"
      # need to commit the submodule refs before updating superproject
      # This is behind-the-scenes stuff that should be silent though
      submodules.each {|s| `git add #{s[:path]}` }
      `git commit -m "updated submodules"`

      unless system("git pull --rebase")
        # merge conflict for submodule refs can easily be handled
        # by an add and continue.  So let's try adding them in case
        # it's the only conflict.
        submodules.each {|s| `git add #{s[:path]}` }
        if system("git rebase --continue")
          puts "*** Successfully handled submodule ref conflicts.  All systems go"
        else
          puts "*** Unable to handle submodule ref conflicts.  You should " +
               "'git rebase --abort' and do the rebase manually."
        end
      end
    end
    
    def status
      repos.each do |r|
        puts "** #{r[:name]} status"
        system "cd #{r[:path]} && git status"
      end
    end

    def push_all
      check_for_clean_repos "Unable to push"

      repos.each do |r|
        puts "** push #{r[:name]}"
        system "cd #{r[:path]} && git push"
      end
      puts "Successfully pushed changes to github"
    end

    private
    def check_for_clean_repos(message)
      unless all_repos_clean?
        puts "*** #{message} ***"
        status
        exit 1
      end
    end
    
    def all_repos_clean?
      repos.all? do |r|
        output = `cd #{r[:path]} && git status`
        ['On branch master', 'nothing to commit'].all? {|message| output.include?(message) }
      end
    end
    
    def repos
      [submodules, superproject].flatten
    end

    def superproject
      {:name => "Parent repo", :path => "."}
    end
    
    def submodules
      [
       {:name => "TextMate Bundle", :path => 'RSpec.tmbundle',
        :url => "#{url_prefix}/rspec-tmbundle.git" },
       {:name => "rspec", :path => 'example_rails_app/vendor/plugins/rspec',
        :url => "#{url_prefix}/rspec.git"},
       {:name => "rspec-rails", :path => 'example_rails_app/vendor/plugins/rspec-rails',
        :url => "#{url_prefix}/rspec-rails.git"}
      ]
    end

    def url_prefix
      if ENV["COMMITTER"]
        "git@github.com:dchelimsky"
      else
        "git://github.com/dchelimsky"
      end
    end
  end
end
