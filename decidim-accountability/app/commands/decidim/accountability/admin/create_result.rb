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
          end

          broadcast(:ok)
        end

        private

        attr_reader :result

        def create_result
          @result = Result.create!(
            feature: @form.current_feature,
            scope: @form.scope,
            category: @form.category,
            parent_id: @form.parent_id,
            title: @form.title,
            description: @form.description,
            start_date: @form.start_date,
            end_date: @form.end_date,
            progress: @form.progress,
            decidim_accountability_status_id: @form.decidim_accountability_status_id
          )
        end

        def proposals
          @proposals ||= result.sibling_scope(:proposals).where(id: @form.proposal_ids)
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

        def link_meetings
          result.link_resources(meetings, "meetings_through_proposals")
        end
      end
    end
  end
end
