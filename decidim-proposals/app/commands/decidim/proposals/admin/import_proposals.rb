# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to another.
      class ImportProposals < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          broadcast(:ok, import_proposals)
        end

        private

        attr_reader :form

        def import_proposals
          proposals.map do |original_proposal|
            origin_attributes = original_proposal.attributes.except(
              "id",
              "created_at",
              "updated_at",
              "state",
              "answer",
              "answered_at",
              "decidim_feature_id",
              "reference",
              "proposal_votes_count",
              "proposal_notes_count"
            )

            proposal = Decidim::Proposals::Proposal.new(origin_attributes)
            proposal.category = original_proposal.category
            proposal.feature = target_feature
            proposal.save!

            proposal.link_resources([original_proposal], "copied_from_component")
          end
        end

        def proposals
          Decidim::Proposals::Proposal
            .where(feature: origin_feature)
            .where(state: proposal_states)
        end

        def proposal_states
          @proposal_states = @form.states

          if @form.states.include?("not_answered")
            @proposal_states.delete("not_answered")
            @proposal_states.push(nil)
          end

          @proposal_states
        end

        def origin_feature
          @form.origin_feature
        end

        def target_feature
          @form.current_feature
        end
      end
    end
  end
end
