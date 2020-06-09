# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class DestroyQuestionnaireTemplate < Rectify::Command
        # Public: Initializes the command.
        #
        # template - the Template to update
        # form - A form object with the params.
        def initialize(template)
          @template = template
        end

        # Destroys the template.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          destroy_template

          broadcast(:ok)
        end

        private

        attr_reader :template, :current_user

        def destroy_template
          Decidim.traceability.perform_action!(
            :delete,
            template,
            current_user
          ) do
            template.destroy!
          end
        end
      end
    end
  end
end
