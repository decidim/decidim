# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a scope type.
    class UpdateScopeType < Rectify::Command
      # Public: Initializes the command.
      #
      # scope_type - The ScopeType to update
      # form - A form object with the params.
      def initialize(scope_type, form)
        @scope_type = scope_type
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

        update_scope_type
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_scope_type
        @scope_type.update_attributes!(attributes)
      end

      def attributes
        {
          name: form.name,
          plural: form.plural
        }
      end
    end
  end
end
