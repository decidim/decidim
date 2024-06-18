# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when an admin creates a private note proposal reply.
      class ReplyProposalNote < Decidim::Command
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
          notify_admins_and_valuators

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
              body: form.body,
              proposal:,
              parent:,
              author: form.current_user
            },
            resource: {
              title: proposal.title
            }
          )
        end

        def notify_admins_and_valuators
          # TODO: Notify mentioned users and note author
          # affected_users = Decidim::User.org_admins_except_me(form.current_user).all
          # # Only affects to author of the first note and tagged admins
          # # affected_users =
          # affected_users += Decidim::Proposals::ValuationAssignment.includes(valuator_role: :user).where.not(id: form.current_user.id).where(proposal:).map(&:valuator)

          # data = {
          #   event: "decidim.events.proposals.admin.proposal_note_reply_created",
          #   event_class: Decidim::Proposals::Admin::ProposalNoteReplyCreatedEvent,
          #   resource: parent,
          #   affected_users:
          # }

          # Decidim::EventsManager.publish(**data)
        end
      end
    end
  end
end
