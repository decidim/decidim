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
            next if proposal_already_copied?(original_proposal, target_component)

            Decidim::Proposals::ProposalBuilder.copy(
              original_proposal,
              author: proposal_author,
              action_user: form.current_user,
              extra_attributes: {
                "component" => target_component
              }
            )
          end.compact
        end

        def proposals
          Decidim::Proposals::Proposal
            .where(component: origin_component)
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

        def origin_component
          @form.origin_component
        end

        def target_component
          @form.current_component
        end

        def proposal_already_copied?(original_proposal, target_component)
          original_proposal.linked_resources(:proposals, "copied_from_component").any? do |proposal|
            proposal.component == target_component
          end
        end

        def proposal_author
          form.keep_authors ? nil : @form.current_organization
        end
      end
    end
  end
end
