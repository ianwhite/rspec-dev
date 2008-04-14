module RSpec
  class Git
    def update
      puts "** Updating parent repo"
      if system("git pull --rebase")
        submodules.each do |submodule|
          puts "\n** Updating submodule: #{submodule}"
          system "cd #{submodule} && git pull --rebase"
        end
      end
    end

    def status
      puts "** Parent repo status:"
      system "git status"
      submodules.each do |submodule|
        puts "\n** #{submodule} status"
        system "cd #{submodule} && git status"
      end
    end

    def push_all
      repos = (submodules << '.')
      if repos.all? do |r|
          output = `cd #{r} && git status`
          ['On branch master', 'nothing to commit'].all? {|message| output.include?(message) }
        end
        repos.each do |r|
          puts "\n** push #{r}"
          system "cd #{r} && git push"
        end
        puts "Successfully pushed changes to github"
      else
        puts "Unable to push.  Run 'rake git:status' to view any uncommitted changes"
      end
    end

    private
    def submodules
      ['RSpec.tmbundle',
       'example_rails_app/vendor/plugins/rspec',
       'example_rails_app/vendor/plugins/rspec-rails']
    end
  end
end
