# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin creates a private note proposal.
      class CreateProposalNote < Decidim::Command
        include ProposalNotesMethods

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # proposal - the proposal to relate.
        def initialize(form, proposal)
          @form = form
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the note proposal.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_proposal_note
          notify_mentioned
          notify_not_mentioned_evaluators

          broadcast(:ok, proposal_note)
        end

        private

        attr_reader :form, :proposal_note, :proposal

        def create_proposal_note
          @proposal_note = Decidim.traceability.create!(
            ProposalNote,
            form.current_user,
            {
              body: rewritten_body,
              proposal:,
              author: form.current_user
            },
            resource: {
              title: proposal.title
            }
          )
        end

        def notify_mentioned
          notify_creation(mentioned_admins_or_evaluators, "decidim.events.proposals.admin.proposal_note_mentioned")
        end

        def notify_not_mentioned_evaluators
          notify_creation(proposal_evaluators - mentioned_admins_or_evaluators, "decidim.events.proposals.admin.proposal_note_created")
        end

        def notify_creation(affected_users, event)
          return if affected_users.blank?

          Decidim::EventsManager.publish(
            event:,
            event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
            resource: proposal,
            affected_users:,
            extra: { note_author_id: form.current_user.id }
          )
        end
      end
    end
  end
end
