# frozen_string_literal: true
module Decidim
  module Surveys
    # Command that gets called when the survey of this feature needs to be
    # destroyed. It usually happens as a callback when the feature is removed.
    class DestroySurvey < Rectify::Command
      def initialize(feature)
        @feature = feature
      end

      def call
        Survey.where(feature: @feature).destroy_all
        broadcast(:ok)
      end
    end
  end
end
