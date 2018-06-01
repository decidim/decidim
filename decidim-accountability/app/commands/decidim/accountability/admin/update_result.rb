# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateResult < Rectify::Command
        # Initializes an UpdateResult Command.
        #
        # form - The form from which to get the data.
        # result - The current instance of the result to be updated.
        def initialize(form, result)
          @form = form
          @result = result
        end

        # Updates the result if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_result
            link_proposals
            link_meetings
            link_projects
          end

          broadcast(:ok)
        end

        private

        attr_reader :result, :form

        def update_result
          Decidim.traceability.update!(
            result,
            form.current_user,
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
          )
        end

        def proposals
          @proposals ||= result.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def projects
          @projects ||= result.sibling_scope(:projects).where(id: form.project_ids)
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
      end
    end
  end
end
