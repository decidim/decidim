# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a StaticPage from the admin panel.
    class DestroyStaticPage < Rectify::Command
      # Public: Initializes the command.
      #
      # page - The StaticPage to be destroyed.
      def initialize(page, current_user)
        @page = page
        @current_user = current_user
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed
      def call
        destroy_page
        broadcast(:ok)
      end

      private

      attr_reader :page, :current_user

      def destroy_page
        transaction do
          Decidim.traceability.perform_action!(
            "delete",
            page,
            current_user
          ) do
            page.destroy!
          end
        end
      end
    end
  end
end
