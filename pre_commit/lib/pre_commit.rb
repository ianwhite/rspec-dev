RSPEC_DEV_ROOT = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. ..]))
RSPEC_PLUGIN_ROOT = File.expand_path(File.join(RSPEC_DEV_ROOT, *%w[example_rails_app vendor plugins]))

require "pre_commit/pre_commit"
require "pre_commit/rspec"
require "pre_commit/core"
require "pre_commit/rspec_on_rails"
