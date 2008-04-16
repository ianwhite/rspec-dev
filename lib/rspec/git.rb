module RSpec
  class Git
    def update
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
      if repos.all? do |r|
          output = `cd #{r[:path]} && git status`
          ['On branch master', 'nothing to commit'].all? {|message| output.include?(message) }
        end
        repos.each do |r|
          puts "** push #{r[:name]}"
          system "cd #{r[:path]} && git push"
        end
        puts "Successfully pushed changes to github"
      else
        puts "Unable to push.  Run 'rake git:status' to view any uncommitted changes"
      end
    end

    private
    def repos
      [submodules, superproject].flatten
    end

    def superproject
      {:name => "Parent repo", :path => "."}
    end
    
    def submodules
      [
       {:name => "TextMate Bundle", :path => 'RSpec.tmbundle'},
       {:name => "rspec", :path => 'example_rails_app/vendor/plugins/rspec'},
       {:name => "rspec-rails", :path => 'example_rails_app/vendor/plugins/rspec-rails'}
      ]
    end
  end
end
