# frozen_string_literal: true

module Decidim
  module Proposals
    class CoauthorInvitedEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::CoauthorEvent

      def action_cell
        "decidim/notification_actions/buttons" if coauthor
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

      def coauthor_id
        extra["coauthor_id"]
      end

      def uuid
        extra["uuid"]
      end

      def coauthor
        @coauthor ||= Decidim::User.find_by(id: coauthor_id, organization:)
      end

      private

      def invite_path
        @invite_path ||= EngineRouter.main_proxy(component).proposal_invite_coauthor_path(proposal_id: resource, id: uuid)
      end
    end
  end
end
