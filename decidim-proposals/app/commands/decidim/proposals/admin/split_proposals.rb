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
          Decidim::Proposals::ProposalBuilder.copy(
            original_proposal,
            author: form.current_organization,
            action_user: form.current_user,
            extra_attributes: {
              component: form.target_component
            }
          )
        end
      end
    end
  end
end
