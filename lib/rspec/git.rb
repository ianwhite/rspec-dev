module RSpec
  class Git
    def update
      repos.each do |r|
        puts "** Updating #{r[:name]}"
        unless system("cd #{r[:path]} && git pull --rebase")
          puts "Error updating #{r[:name]}"
          break
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
      [submodules, {:name => "Parent repo", :path => "."}].flatten
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
