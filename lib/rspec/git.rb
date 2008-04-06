module RSpec
  class Git
    def update
      puts "** Updating parent repo"
      if system("git pull --rebase")
        submodules.each do |submodule|
          puts "\n** Updating submodule: #{submodule}"
          system "cd #{submodule}; git pull --rebase"
        end
      end
    end

    def status
      puts "** Parent repo status:"
      system "git status"
      submodules.each do |submodule|
        puts "\n** #{submodule} status"
        system "cd #{submodule}; git status"
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
