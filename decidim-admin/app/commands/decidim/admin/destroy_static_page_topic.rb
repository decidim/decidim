# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a StaticPageTopic from the admin panel.
    class DestroyStaticPageTopic < Decidim::Command
      # Public: Initializes the command.
      #
      # page - The StaticPageTopic to be destroyed.
      def initialize(_topic, current_user)
        @topic = page
        @current_user = current_user
      end

      # Public: Executes the command.
      #
      # Broadcasts :ok if it got destroyed
      def call
        destroy_topic
        broadcast(:ok)
      end

      private

      attr_reader :page, :current_user

      def destroy_page
        transaction do
          Decidim.traceability.perform_action!(
            "delete",
            topic,
            current_user
          ) do
            topic.destroy!
          end
        end
      end
    end
  end
end
