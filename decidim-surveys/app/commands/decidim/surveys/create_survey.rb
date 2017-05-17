# frozen_string_literal: true
module Decidim
  module Surveys
    # Command that gets called whenever a feature's survey has to be created. It
    # usually happens as a callback when the feature itself is created.
    class CreateSurvey < Rectify::Command
      def initialize(feature)
        @feature = feature
      end

      def call
        @survey = Survey.new(feature: @feature)

        @survey.save ? broadcast(:ok) : broadcast(:invalid)
      end
    end
  end
end
