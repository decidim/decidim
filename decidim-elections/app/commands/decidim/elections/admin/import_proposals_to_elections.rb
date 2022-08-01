# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # A command is executed when an admin imports proposals from
      # one component to answers of elections component.
      class ImportProposalsToElections < Decidim::Command
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
          return broadcast(:invalid) if invalid?

          broadcast(:ok, create_answers_from_accepted_proposals)
        end

        private

        attr_reader :form, :answer

        def invalid?
          form.election.started? || form.invalid?
        end

        def create_answers_from_accepted_proposals
          transaction do
            proposals.map do |original_proposal|
              next if proposal_already_copied?(original_proposal)

              create_answer_from_proposal(original_proposal)
              answer.link_resources([original_proposal], "related_proposals")
            end.compact
          end
        end

        def create_answer_from_proposal(original_proposal)
          params = {
            question: form.question,
            title: original_proposal.title,
            description: original_proposal.body,
            weight: form.weight
          }

          @answer = Decidim.traceability.create!(
            Answer,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def proposals
          @proposals ||= if @form.import_all_accepted_proposals?
                           Decidim::Proposals::Proposal.where(component: origin_component).where(state: "accepted")
                         else
                           Decidim::Proposals::Proposal.where(component: origin_component)
                         end
        end

        def origin_component
          @form.origin_component
        end

        def target_question
          @form.question
        end

        def proposal_already_copied?(original_proposal)
          # Note: we are including also answers from unpublished components
          # because otherwise duplicates could be created until the component is
          # published.
          original_proposal.linked_resources(:answers, "related_proposals", component_published: false).any? do |answer|
            answer.question == target_question
          end
        end
      end
    end
  end
end
