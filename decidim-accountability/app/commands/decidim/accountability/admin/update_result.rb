# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateResult < Decidim::Commands::UpdateResource
        include Decidim::Accountability::ResultCommandHelper
        fetch_form_attributes :scope, :category, :parent_id, :title, :description, :start_date, :end_date,
                              :progress, :decidim_accountability_status_id, :external_id, :weight

        protected

        alias result resource

        def run_after_hooks
          link_proposals
          link_meetings
          link_projects
          send_notifications if should_notify_followers?
        end

        def send_notifications
          result.linked_resources(:proposals, "included_proposals").each do |proposal|
            Decidim::EventsManager.publish(
              event: "decidim.events.accountability.result_progress_updated",
              event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
              resource: result,
              affected_users: proposal.notifiable_identities,
              followers: proposal.followers - proposal.notifiable_identities,
              extra: {
                progress: result.progress,
                proposal_id: proposal.id
              }
            )
          end
        end

        def should_notify_followers?
          result.previous_changes["progress"].present?
        end
      end
    end
  end
end
