# frozen_string_literal: true

module Decidim
  module Accountability
    module ResultCommandHelper
      def proposals
        @proposals ||= resource.sibling_scope(:proposals).where(id: form.proposal_ids)
      end

      def projects
        @projects ||= resource.sibling_scope(:projects).where(id: form.project_ids)
      end

      def meeting_ids
        @meeting_ids ||= proposals.flat_map do |proposal|
          proposal.linked_resources(:meetings, "proposals_from_meeting").pluck(:id)
        end.uniq
      end

      def meetings
        @meetings ||= resource.sibling_scope(:meetings).where(id: meeting_ids)
      end

      def link_proposals
        resource.link_resources(proposals, "included_proposals")
      end

      def link_projects
        resource.link_resources(projects, "included_projects")
      end

      def link_meetings
        resource.link_resources(meetings, "meetings_through_proposals")
      end

      def notify_proposal_followers
        proposals.each do |proposal|
          Decidim::EventsManager.publish(
            event: "decidim.events.accountability.proposal_linked",
            event_class: Decidim::Accountability::ProposalLinkedEvent,
            resource:,
            affected_users: proposal.notifiable_identities,
            followers: proposal.followers - proposal.notifiable_identities,
            extra: {
              proposal_id: proposal.id
            }
          )
        end
      end
    end
  end
end
