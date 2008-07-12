class PreCommit::RspecOnRails < PreCommit
  
  RAILS_TAGS = [
    {:version => '2.1.0', :tag => 'v2.1.0'},
    {:version => '2.0.2', :tag => 'v2.0.2'},
    {:version => '1.2.6', :tag => 'v1.2.6'},
    {:version => 'edge', :tag => 'master'},
  ]
  
  def pre_commit
    check_dependencies
    used_railses = []
    RAILS_TAGS.each do |tag|
      begin
        rspec_pre_commit(tag[:version], false)
        used_railses << tag[:version]
      rescue Exception => e
        unless tag[:version] == 'edge'
          raise e
        end
      end
    end
    puts "All specs passed against the following released versions of Rails: #{used_railses.join(", ")}"
    unless used_railses.include?('edge')
      puts "There were errors running pre_commit against edge"
    end
  end

  def rails_version_from_dir(rails_dir)
    File.basename(rails_dir)
  end

  def rspec_pre_commit(rails_version=ENV['RSPEC_RAILS_VERSION'],cleanup_rspec=true)
    puts "#####################################################"
    puts "running pre_commit against rails #{rails_version}"
    ENV['RSPEC_RAILS_VERSION'] = rails_version
    pair = RAILS_TAGS.find{|pair| pair[:version] == rails_version}
    raise "version????" unless pair
    puts "#####################################################"
    Dir.chdir "#{RSPEC_DEV_ROOT}/example_rails_app/vendor/rails" do
      sh "git checkout #{pair[:tag]}"
    end
    puts "#####################################################"
    ensure_db_config
    clobber_sqlite_data
    cleanup(cleanup_rspec)
    generate_rspec

    generate_login_controller
    generate_account_model
    generate_event_model_skip_fixture
    generate_purchase
    migrate_up

    rake_sh "spec"
    rake_sh "spec:plugins:rspec_on_rails"
    
    # TODO - why is this necessary? Shouldn't the specs leave
    # a clean DB?
    rake_sh "db:test:prepare"
    sh "ruby vendor/plugins/rspec-rails/stories/all.rb"
  ensure
    cleanup(cleanup_rspec)
  end

  def cleanup(cleanup_rspec=true)
    revert_routes
    migrate_down
    rm_generated_purchase_files
    rm_generated_event_model_files
    rm_generated_account_model_files
    rm_generated_login_controller_files
    remove_generated_rspec_files if cleanup_rspec
  end

  def revert_routes
    output = silent_sh("cp config/routes.rb.restore config/routes.rb")
    raise "Error reverting routes.rb" if shell_error?(output)
  end

  def create_purchase
  end
  
  def remove_generated_rspec_files
    rm_rf 'script/autospec'
    rm_rf 'script/spec'
    rm_rf 'script/spec_server'
    rm_rf 'spec/spec_helper.rb'
    rm_rf 'spec/spec.opts'
    rm_rf 'spec/rcov.opts'
    rm_rf 'lib/tasks/rspec.rake'
    rm_rf 'stories/all.rb'
    rm_rf 'stories/helper.rb'
  end
  
  def copy(source, target)
    output = silent_sh("cp -R #{File.expand_path(source)} #{File.expand_path(target)}")
    raise "Error installing rspec" if shell_error?(output)
  end
  
  def generate_rspec
    result = silent_sh("ruby script/generate rspec --force")
    if error_code? || result =~ /^Missing/
      raise "Failed to generate rspec environment:\n#{result}"
    end
  end

  def ensure_db_config
    config_path = 'config/database.yml'
    unless File.exists?(config_path)
      message = <<-EOF
      #####################################################
      Could not find #{config_path}

      You can get rake to generate this file for you using either of:
        rake rspec:generate_mysql_config
        rake rspec:generate_sqlite3_config
        rake rspec:generate_postgres_config

      If you use mysql, you'll need to create dev and test
      databases and users for each. To do this, standing
      in rspec_on_rails, log into mysql as root and then...
        mysql> source db/mysql_setup.sql;

      There is also a teardown script that will remove
      the databases and users:
        mysql> source db/mysql_teardown.sql;
      #####################################################
      EOF
      raise message.gsub(/^      /, '')
    end
  end

  def generate_mysql_config
    copy 'config/database.mysql.yml', 'config/database.yml'
  end

  def generate_sqlite3_config
    copy 'config/database.sqlite3.yml', 'config/database.yml'
  end

  def generate_postgres_config
    copy 'config/database.pgsql.yml', 'config/database.yml'
  end

  def clobber_db_config
    rm 'config/database.yml'
  end

  def clobber_sqlite_data
    rm_rf 'db/*.db'
  end

  def generate_purchase
    generator = "ruby script/generate rspec_scaffold purchase order_id:integer created_at:datetime amount:decimal keyword:string description:text --force"
    notice = <<-EOF
    #####################################################
    #{generator}
    #####################################################
    EOF
    puts notice.gsub(/^    /, '')
    result = silent_sh(generator)
    if error_code? || result =~ /not/
      raise "rspec_scaffold failed. #{result}"
    end
  end
  
  def purchase_migration_version
    "005"
  end

  def migrate_up
    rake_sh "db:migrate"
  end

  def destroy_purchase
  end

  def migrate_down
    notice = <<-EOF
    #####################################################
    Migrating down and reverting config/routes.rb
    #####################################################
    EOF
    puts notice.gsub(/^    /, '')
    rake_sh "db:migrate", 'VERSION' => (purchase_migration_version.to_i - 1)
    output = silent_sh("cp config/routes.rb.restore config/routes.rb")
    raise "revert failed: #{output}" if error_code?
  end

  def rm_generated_purchase_files
    puts "#####################################################"
    puts "Removing generated files for purchases resource"
    remove %W{
      app/helpers/purchases_helper.rb
      app/models/purchase.rb
      app/controllers/purchases_controller.rb
      app/views/purchases
      spec/models/purchase_spec.rb
      spec/helpers/purchases_helper_spec.rb
      spec/controllers/purchases_controller_spec.rb
      spec/controllers/purchases_routing_spec.rb
      spec/fixtures/purchases.yml
      spec/views/purchases
    }
    remove Dir['db/migrate/*_create_purchases.rb']
    puts "#####################################################"
  end
  
  def generate_login_controller
    generator = "ruby script/generate rspec_controller login signup login logout --force"
    notice = <<-EOF
    #####################################################
    #{generator}
    #####################################################
    EOF
    puts notice.gsub(/^    /, '')
    result = silent_sh(generator)
    if error_code? || result =~ /not/
      raise "rspec_scaffold failed. #{result}"
    end
  end
  
  def rm_generated_login_controller_files
    puts "#####################################################"
    puts "Removing generated files for login controller"
    remove %W{
      app/helpers/login_helper.rb
      app/controllers/login_controller.rb
      app/views/login
      spec/helpers/login_helper_spec.rb
      spec/controllers/login_controller_spec.rb
      spec/views/login
    }
    puts "#####################################################"
  end
  
  def generate_account_model
    generator = "ruby script/generate rspec_model account name:string balance_in_cents:integer --force"
    notice = <<-EOF
    #####################################################
    #{generator}
    #####################################################
    EOF
    puts notice.gsub(/^    /, '')
    result = silent_sh(generator)
    if error_code? || result =~ /not/
      raise "rspec_model failed. #{result}"
    end
  end
  
  def rm_generated_account_model_files
    puts "#####################################################"
    puts "Removing files generated for account model"
    remove %W{
      app/models/account.rb
      spec/models/account_spec.rb
      spec/fixtures/accounts.yml
    }
    remove Dir['db/migrate/*_create_accounts.rb']
    puts "#####################################################"
  end

  def generate_event_model_skip_fixture
    generator = "ruby script/generate rspec_model event name:string date:date --skip-fixture --force"
    notice = <<-EOF
    #####################################################
    #{generator}
    #####################################################
    EOF
    puts notice.gsub(/^    /, '')
    result = silent_sh(generator)
    if error_code? || result =~ /not/
      raise "rspec_model with --skip-fixture failed. #{result}"
    end
  end
  
  def rm_generated_event_model_files
    puts "#####################################################"
    puts "Removing files generated for event model"
    remove %W{
      app/models/event.rb
      spec/models/event_spec.rb
    }
    remove Dir['db/migrate/*_create_events.rb']
    puts "#####################################################"
  end
  
  def remove(files)
    files.each {|file| rm_rf file}
  end

  def install_dependencies
    if File.exist?("#{RSPEC_DEV_ROOT}/example_rails_app/vendor/rails/.git")
      puts "Rails is already installed"
    else
      if File.exist?("#{RSPEC_DEV_ROOT}/example_rails_app/vendor/rails")
        sh "rm -rf #{RSPEC_DEV_ROOT}/example_rails_app/vendor/rails"
      end
      Dir.chdir "#{RSPEC_DEV_ROOT}/example_rails_app/vendor" do
        puts "cloning rails - this might take a while"
        sh "git clone git://github.com/rails/rails.git"
      end
    end
  end

  def check_dependencies
    unless File.exist?("#{RSPEC_DEV_ROOT}/example_rails_app/vendor/rails/.git")
      raise "Rails is not installed. Please run 'rake install_dependencies'"
    end
  end
  
  def update_dependencies
    check_dependencies
    Dir.chdir "#{RSPEC_DEV_ROOT}/example_rails_app/vendor/rails" do
      sh "git checkout master"
      sh "git pull"
    end
  end

end
