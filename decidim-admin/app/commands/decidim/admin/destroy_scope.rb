# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a scope.
    class DestroyScope < Decidim::Command
      # Public: Initializes the command.
      #
      # scope - The Scope to destroy
      # current_user - the user performing the action
      def initialize(scope, current_user)
        @scope = scope
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        update_scope
        broadcast(:ok)
      end

      private

      attr_reader :current_user

      def update_scope
        Decidim.traceability.perform_action!(
          "delete",
          @scope,
          current_user,
          extra: {
            parent_name: @scope.parent.try(:name),
            scope_type_name: @scope.scope_type.try(:name)
          }
        ) do
          @scope.destroy!
        end
      end
    end
  end
end
