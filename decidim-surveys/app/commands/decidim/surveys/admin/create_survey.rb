# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # Command that gets called whenever a component's survey has to be created. It
      # usually happens as a callback when the component itself is created.
      class CreateSurvey < Decidim::Command
        def initialize(component, form)
          @component = component
          @form = form
        end

        attr_reader :form

        def call
          return broadcast(:invalid) if form.invalid?

          @survey = Survey.new(
            component: @component,
            questionnaire: Decidim::Forms::Questionnaire.new(
              title: form.title,
              description: form.description,
              tos: form.tos
            )
          )

          @survey.save ? broadcast(:ok, @survey) : broadcast(:invalid)
        end
      end
    end
  end
end
