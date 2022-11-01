# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Creates a QuestionnaireTemplate.
      class CreateQuestionnaireTemplate < CreateTemplate
        protected

        def assign_template!
          @questionnaire = Decidim::Forms::Questionnaire.create!(questionnaire_for: @template)
          @template.update!(templatable: @questionnaire)
        end

        def target
          :questionnaire
        end
      end
    end
  end
end
