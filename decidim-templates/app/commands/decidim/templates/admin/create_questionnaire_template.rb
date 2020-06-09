# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Creates an QuestionnaireTemplate.
      class CreateQuestionnaireTemplate < Rectify::Command
        # Initializes the command.
        #
        # form - The source for this QuestionnaireTemplate.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          @application = Decidim.traceability.create!(
            Template,
            @form.current_user,
            name: @form.name,
            # description: @form.description,
            organization: @form.current_organization,
            templatable: Decidim::Forms::Questionnaire.new
          )

          broadcast(:ok, @application)
        end
      end
    end
  end
end
