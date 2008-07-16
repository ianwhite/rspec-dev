# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :i_should_only_be_run_once, 
                :only => 'action_with_ac_base_before_filter_checking_multi_require_bug'
  
  def i_should_only_be_run_once
    true
  end
  private :i_should_only_be_run_once
end
