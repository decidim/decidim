# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # This command deals with destroying a template from the admin panel.
      class DestroyTemplate < Rectify::Command
        # Public: Initializes the command.
        #
        # template - The Template to be destroyed.
        # user        - The user that destroys the template.
        def initialize(template, current_user)
          @template = template
          @current_user = current_user
        end

        # Public: Executes the command.
        #
        # Broadcasts :ok if it got destroyed
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
