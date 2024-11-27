# frozen_string_literal: true

module Decidim
  module Commands
    class SoftDeleteResource < ::Decidim::Command
      # Initializes the command.
      #
      # @param resource [ActiveRecord::Base] the resource to soft delete.
      # @param current_user [Decidim::User] the current user.
      def initialize(resource, current_user)
        @resource = resource
        @current_user = current_user
      end

      # Soft deletes the resource.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        soft_delete_resource
        send_notification_to_authors

        broadcast(:ok, resource)
      rescue Decidim::Commands::HookError, StandardError
        broadcast(:invalid)
      end

      protected

      attr_reader :resource, :current_user

      def invalid? = false

      def soft_delete_resource
        Decidim.traceability.perform_action!(
          "soft_delete",
          resource,
          current_user
        ) do
          resource.destroy!
        end
      end

      def send_notification_to_authors
        coauthors = resource.try(:coauthorships)&.map do |coauthorship|
          coauthorship.decidim_author_type.constantize.find(coauthorship.decidim_author_id)
        end || []

        recipients = (resource.try(:authors) || [resource.try(:author)]).compact + coauthors

        return if recipients.empty?

        Decidim::EventsManager.publish(
          event: "decidim.events.resources.soft_deleted",
          event_class: Decidim::SoftDeleteResourceEvent,
          resource:,
          affected_users: recipients.uniq
        )
      end
    end
  end
end
