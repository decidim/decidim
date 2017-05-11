# frozen_string_literal: true

module Decidim
  module Surveys
    # Exposes the survey resource so users can view and answer them.
    class SurveysController < Decidim::Surveys::ApplicationController
      def show
        @survey = Survey.find_by(feature: current_feature)
      end
    end
  end
end
