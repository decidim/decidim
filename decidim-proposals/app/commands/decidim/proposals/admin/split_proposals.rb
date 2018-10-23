# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin splits proposals from
      # one component to another.
      class SplitProposals < Rectify::Command
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

          broadcast(:ok, split_proposals)
        end

        private

        attr_reader :form

        def split_proposals
          transaction do
            form.proposals.flat_map do |original_proposal|
              create_proposal(original_proposal)
              create_proposal(original_proposal)
            end
          end
        end

        def create_proposal(original_proposal)
          origin_attributes = original_proposal.attributes.except(
            "id",
            "created_at",
            "updated_at",
            "state",
            "answer",
            "answered_at",
            "decidim_component_id",
            "reference",
            "proposal_votes_count",
            "proposal_notes_count"
          )

          Decidim.traceability.perform_action!(:create, Proposal, form.current_user, visibility: "all") do
            proposal = Proposal.new(origin_attributes)
            proposal.component = form.target_component
            proposal.category = original_proposal.category
            proposal.add_coauthor(form.current_organization)
            proposal.save!
            proposal.link_resources(original_proposal, "copied_from_component")
            proposal
          end
        end
      end
    end
  end
end
