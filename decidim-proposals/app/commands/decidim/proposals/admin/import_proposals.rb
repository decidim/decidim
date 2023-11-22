# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to another.
      class ImportProposals < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
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
              }.merge(proposal_answer_attributes(original_proposal))
            )
          end.compact
        end

        def proposals
          @proposals = Decidim::Proposals::Proposal
                       .where(component: origin_component)
                       .only_status(@form.states)
          @proposals = @proposals.where(scope: proposal_scopes) unless proposal_scopes.empty?
          @proposals
        end

        def proposal_scopes
          @form.scopes
        end

        def origin_component
          @form.origin_component
        end

        def target_component
          @form.current_component
        end

        def proposal_already_copied?(original_proposal, target_component)
          # Note: we are including also proposals from unpublished components
          # because otherwise duplicates could be created until the component is
          # published.
          original_proposal.linked_resources(:proposals, "copied_from_component", component_published: false).any? do |proposal|
            proposal.component == target_component
          end
        end

        def proposal_author
          form.keep_authors ? nil : @form.current_organization
        end

        def proposal_answer_attributes(original_proposal)
          return {} unless form.keep_answers

          state = Decidim::Proposals::ProposalState.where(component: target_component, token: original_proposal.customized_proposal_state).first!

          {
            answer: original_proposal.answer,
            answered_at: original_proposal.answered_at,
            proposal_state: state,
            state_published_at: original_proposal.state_published_at
          }
        end
      end
    end
  end
end
