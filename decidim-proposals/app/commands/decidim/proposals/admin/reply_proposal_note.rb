# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin creates a private note proposal reply.
      class ReplyProposalNote < Decidim::Command
        include ProposalNotesMethods

        # Public: Initializes the command.
        #
        # form   - A form object with the params.
        # parent - the note to reply.
        def initialize(form, parent)
          @form = form
          @parent = parent
          @proposal = parent.proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the note proposal.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid? || invalid_parent?

          create_proposal_note_reply
          notify_parent_author
          notify_mentioned

          broadcast(:ok, proposal_note)
        end

        private

        attr_reader :form, :proposal_note, :parent, :proposal

        def invalid_parent?
          parent.blank? || parent.reply?
        end

        def create_proposal_note_reply
          @proposal_note = Decidim.traceability.create!(
            ProposalNote,
            form.current_user,
            {
              body: rewritten_body,
              proposal:,
              parent:,
              author: form.current_user
            },
            resource: {
              title: proposal.title
            }
          )
        end

        def parent_author
          @parent_author ||= parent.author
        end

        def notify_parent_author
          return if form.current_user == parent_author

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.admin.proposal_note_replied",
            event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
            resource: proposal,
            affected_users: [parent_author],
            extra: { note_author_id: form.current_user.id }
          )
        end

        def notify_mentioned
          affected_users = mentioned_admins_or_evaluators - [parent_author]

          return if affected_users.blank?

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.admin.proposal_note_mentioned",
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
