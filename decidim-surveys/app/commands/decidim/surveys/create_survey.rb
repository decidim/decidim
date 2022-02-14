# frozen_string_literal: true

module Decidim
  module Surveys
    # Command that gets called whenever a component's survey has to be created. It
    # usually happens as a callback when the component itself is created.
    class CreateSurvey < Decidim::Command
      def initialize(component)
        @component = component
      end

      def call
        @survey = Survey.new(component: @component, questionnaire: Decidim::Forms::Questionnaire.new)

        @survey.save ? broadcast(:ok) : broadcast(:invalid)
      end
    end
  end
end
