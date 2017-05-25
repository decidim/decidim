# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a category in the
    # system.
    class DestroyCategory < Rectify::Command
      # Public: Initializes the command.
      #
      # category - A Category that will be destroyed
      def initialize(category)
        @category = category
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the data wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if category.nil? || category.subcategories.any?

        destroy_category
        broadcast(:ok)
      end

      private

      attr_reader :category

      def destroy_category
        category.destroy!
      end
    end
  end
end
