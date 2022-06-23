# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a category in the
    # system.
    class UpdateCategory < Decidim::Command
      attr_reader :category

      # Public: Initializes the command.
      #
      # category - the Category to update
      # form - A form object with the params.
      def initialize(category, form, user)
        @category = category
        @form = form
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_category
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_category
        Decidim.traceability.update!(
          category,
          @user,
          attributes
        )
      end

      def attributes
        {
          name: form.name,
          weight: form.weight,
          parent_id: form.parent_id
        }
      end
    end
  end
end
