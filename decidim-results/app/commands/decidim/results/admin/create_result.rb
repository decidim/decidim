# frozen_string_literal: true
module Decidim
  module Results
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
            scope: @form.scope,
            category: @form.category,
            feature: @form.current_feature,
            title: @form.title,
            description: @form.description
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
