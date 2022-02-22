# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin merges proposals from
      # one component to another.
      class MergeProposals < Decidim::Command
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

          broadcast(:ok, merge_proposals)
        end

        private

        attr_reader :form

        def merge_proposals
          transaction do
            merged_proposal = create_new_proposal
            merged_proposal.link_resources(proposals_to_link, "copied_from_component")
            form.proposals.each(&:destroy!) if form.same_component?
            merged_proposal
          end
        end

        def proposals_to_link
          return previous_links if form.same_component?

          form.proposals
        end

        def previous_links
          @previous_links ||= form.proposals.flat_map do |proposal|
            proposal.linked_resources(:proposals, "copied_from_component")
          end
        end

        def create_new_proposal
          original_proposal = form.proposals.first

          Decidim::Proposals::ProposalBuilder.copy(
            original_proposal,
            author: form.current_organization,
            action_user: form.current_user,
            extra_attributes: {
              component: form.target_component
            },
            skip_link: true
          )
        end
      end
    end
  end
end
