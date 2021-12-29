# frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a questionnaire template
    module Admin
      class ApplyQuestionnaireTemplate < Rectify::Command
        include Decidim::Templates::Admin::QuestionnaireCopier

        # Public: Initializes the command.
        #
        # template - The template we want to apply
        # questionnaire - The questionnaire we want to use the template
        def initialize(questionnaire, template)
          @questionnaire = questionnaire
          @template = template
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @template && @template.valid?

          Template.transaction do
            apply_template
            copy_questionnaire_questions(@template.templatable, @questionnaire)
          end

          broadcast(:ok, @questionnaire)
        end

        private

        attr_reader :form

        def apply_template
          @questionnaire.update!(
            title: @template.templatable.title,
            description: @template.templatable.description,
            tos: @template.templatable.tos
          )
        end
      end
    end
  end
end
