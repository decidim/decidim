# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Result from the admin
      # panel.
      class CreateResult < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the result if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_result
            link_meetings
            link_proposals
            link_projects
            notify_proposal_followers
          end

          broadcast(:ok)
        end

        private

        attr_reader :result

        def create_result
          params = {
            component: @form.current_component,
            scope: @form.scope,
            category: @form.category,
            parent_id: @form.parent_id,
            title: @form.title,
            description: @form.description,
            start_date: @form.start_date,
            end_date: @form.end_date,
            progress: @form.progress,
            decidim_accountability_status_id: @form.decidim_accountability_status_id,
            external_id: @form.external_id.presence,
            weight: @form.weight
          }

          @result = Decidim.traceability.create!(
            Result,
            @form.current_user,
            params,
            visibility: "all"
          )
        end

        def proposals
          @proposals ||= result.sibling_scope(:proposals).where(id: @form.proposal_ids)
        end

        def projects
          @projects ||= result.sibling_scope(:projects).where(id: @form.project_ids)
        end

        def meeting_ids
          @meeting_ids ||= proposals.flat_map do |proposal|
            proposal.linked_resources(:meetings, "proposals_from_meeting").pluck(:id)
          end.uniq
        end

        def meetings
          @meetings ||= result.sibling_scope(:meetings).where(id: meeting_ids)
        end

        def link_proposals
          result.link_resources(proposals, "included_proposals")
        end

        def link_projects
          result.link_resources(projects, "included_projects")
        end

        def link_meetings
          result.link_resources(meetings, "meetings_through_proposals")
        end

        def notify_proposal_followers
          proposals.each do |proposal|
            authors_ids = proposal.authors.pluck(:id)
            Decidim::EventsManager.publish(
              event: "decidim.events.accountability.proposal_linked",
              event_class: Decidim::Accountability::ProposalLinkedEvent,
              resource: result,
              recipient_ids: authors_ids + proposal.followers.pluck(:id),
              extra: {
                proposal_id: proposal.id
              }
            )
          end
        end
      end
    end
  end
end
