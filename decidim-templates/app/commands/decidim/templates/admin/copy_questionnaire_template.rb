# frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a questionnaire template
    module Admin
      class CopyQuestionnaireTemplate < Decidim::Command
        include Decidim::Templates::Admin::QuestionnaireCopier

        # Public: Initializes the command.
        #
        # template - A template we want to duplicate
        def initialize(template, user)
          @template = template
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @template.valid?

          Decidim.traceability.perform_action!("duplicate", @template, @user) do
            Template.transaction do
              copy_template
              copy_questionnaire_questions(@template.templatable, @copied_template.templatable)
            end
          end

          broadcast(:ok, @copied_template)
        end

        private

        attr_reader :form

        def copy_template
          @copied_template = Template.create!(
            organization: @template.organization,
            name: @template.name,
            description: @template.description
          )
          @resource = Decidim::Forms::Questionnaire.create!(
            @template.templatable.dup.attributes.merge(
              questionnaire_for: @copied_template
            )
          )

          @copied_template.update!(templatable: @resource)
        end
      end
    end
  end
end
