# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user destroys a Result from the admin
      # panel.
      class DestroyResult < Decidim::Command
        # Initializes an UpdateResult Command.
        #
        # result - The current instance of the result to be destroyed.
        # current_user - the user performing the action
        def initialize(result, current_user)
          @result = result
          @current_user = current_user
        end

        # Destroys the result.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          destroy_result

          broadcast(:ok)
        end

        private

        attr_reader :result, :current_user

        def destroy_result
          Decidim.traceability.perform_action!(
            :delete,
            result,
            current_user
          ) do
            result.destroy!
          end
        end
      end
    end
  end
end
