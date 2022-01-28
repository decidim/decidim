# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Creates a QuestionnaireTemplate.
      class CreateQuestionnaireTemplate < Decidim::Command
        # Initializes the command.
        #
        # form - The source for this QuestionnaireTemplate.
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          @template = Decidim.traceability.create!(
            Template,
            @form.current_user,
            name: @form.name,
            description: @form.description,
            organization: @form.current_organization
          )

          @questionnaire = Decidim::Forms::Questionnaire.create!(questionnaire_for: @template)
          @template.update!(templatable: @questionnaire)

          broadcast(:ok, @template)
        end
      end
    end
  end
end
