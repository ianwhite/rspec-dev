require File.dirname(__FILE__) + '/../../spec_helper'

module Surveys
  describe ReportController, 'nested style' do
    it "should return the survey corresponding to the report" do
       Survey.should_receive(:find).with("34")
       get :show, :survey_id => "34"
    end

    it "should map #show" do
      route_for(:controller => "surveys/report", :action =>"show", :survey_id => 12).should == "/surveys/12/report"
    end
  end
end

describe Surveys::ReportController, 'exploded style' do
  it "should return the survey corresponding to the report" do
     Survey.should_receive(:find).with("42")
     get :show, :survey_id => "42"
   end
end
