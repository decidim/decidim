# frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a questionnaire template
    module Admin
      class CopyQuestionnaireTemplate < CopyTemplate
        include Decidim::Templates::Admin::QuestionnaireCopier

        private

        attr_reader :form

        def copy_template
          super
          @resource = Decidim::Forms::Questionnaire.create!(
            @template.templatable.dup.attributes.merge(
              questionnaire_for: @copied_template
            )
          )

          @copied_template.update!(templatable: @resource)
          copy_questionnaire_questions(@template.templatable, @copied_template.templatable)
        end
      end
    end
  end
end
