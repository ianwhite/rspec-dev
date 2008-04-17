module RSpec
  class Git
    def plugins_fetched?
      submodules.all? {|s| File.directory?(s[:path]) }
    end
    
    def update
      check_for_clean_repos "Unable to update"
      
      repos.each do |r|
        if File.exist?(r[:path])
          puts "** Updating #{r[:name]}"
          unless system("cd #{r[:path]} && git pull --rebase")
            puts "Error updating #{r[:name]}"
            exit 1
          end
        else
          puts "** Fetching #{r[:name]}"
          system "git clone #{r[:url]} #{r[:path]}"
        end
      end
      puts "*** all repos updated successfully ***"
    end
    
    def status
      repos.each do |r|
        puts "** #{r[:name]} status"
        system "cd #{r[:path]} && git status"
      end
    end

    def push
      check_for_clean_repos "Unable to push"

      repos.each do |r|
        puts "** push #{r[:name]}"
        unless system("cd #{r[:path]} && git push")
          puts "Error pushing #{r[:name]}"
          exit 1
        end
      end
      puts "Successfully pushed changes to github"
    end

    def commit
      if ENV['MESSAGE'].nil?
        puts "You must pass a commit message.  Try it again with:\n" +
          "rake git:commit MESSAGE='commit message here'"
        return
      end
      
      repos.each do |r|
        output = `cd #{r[:path]} && git status`
        unless output.include?('On branch master')
          puts "*** #{r[:name]} is not on the master branch.  Skipping"
          next
        end
        puts "** Committing #{r[:name]}"
        system "cd #{r[:path]} && git commit -a -m #{ENV['MESSAGE'].inspect}"
      end
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
        !File.exist?(r[:path]) ||
        (output = `cd #{r[:path]} && git status`;
         output.include?('On branch master') &&
         !output.include?('Changes to be committed:') &&
         !output.include?('Changed but not updated:'))
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