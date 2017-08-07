# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a scope.
    class UpdateScope < Rectify::Command
      # Public: Initializes the command.
      #
      # scope - The Scope to update
      # form - A form object with the params.
      def initialize(scope, form)
        @scope = scope
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_scope
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_scope
        @scope.update_attributes!(attributes)
      end

      def attributes
        {
          name: form.name,
          code: form.code,
          scope_type: form.scope_type,
          parent: @parent_scope
        }
      end
    end
  end
end
