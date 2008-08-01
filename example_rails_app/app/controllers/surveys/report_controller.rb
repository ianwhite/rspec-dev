module Surveys
  class ReportController < ApplicationController
    def show
      @survey = Survey.find(params[:survey_id])

      respond_to do |format|
        format.html
        format.xml
      end
    end
  end
end