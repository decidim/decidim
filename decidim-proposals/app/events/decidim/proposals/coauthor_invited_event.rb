# frozen_string_literal: true

module Decidim
  module Proposals
    class CoauthorInvitedEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::CoauthorEvent
      include Decidim::Core::Engine.routes.url_helpers

      def action_cell
        "decidim/notification_actions/buttons" unless user_is_coauthor?
      end

      def action_data
        [
          {
            i18n_label: "decidim.events.proposals.coauthor_invited.actions.accept",
            url: invite_path,
            icon: "check-line",
            method: "patch"
          },
          {
            i18n_label: "decidim.events.proposals.coauthor_invited.actions.decline",
            url: invite_path,
            icon: "close-circle-line",
            method: "delete"
          }
        ]
      end

      def resource_url
        notifications_url(host: component.organization.host)
      end

      private

      def invite_path
        @invite_path ||= EngineRouter.main_proxy(component).proposal_invite_coauthor_path(proposal_id: resource, id: user.id)
      end

      def user_is_coauthor?
        resource.authors.include?(user)
      end
    end
  end
end
