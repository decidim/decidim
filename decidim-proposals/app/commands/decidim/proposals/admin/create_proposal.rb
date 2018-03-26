# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user creates a new proposal.
      class CreateProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_attachments?
            build_attachment
            return broadcast(:invalid) if attachment_invalid?
          end

          transaction do
            create_proposal
            create_attachment if process_attachments?
            send_notification
          end

          broadcast(:ok, proposal)
        end

        private

        attr_reader :form, :proposal, :attachment

        def create_proposal
          @proposal = Decidim.traceability.create!(
            Proposal,
            form.current_user,
            attributes
          )
        end

        def attributes
          {
            title: form.title,
            body: form.body,
            category: form.category,
            scope: form.scope,
            component: form.component,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            published_at: Time.current
          }
        end

        def build_attachment
          @attachment = Attachment.new(
            title: form.attachment.title,
            file: form.attachment.file,
            attached_to: @proposal
          )
        end

        def attachment_invalid?
          if attachment.invalid? && attachment.errors.has_key?(:file)
            form.attachment.errors.add :file, attachment.errors[:file]
            true
          end
        end

        def attachment_present?
          form.attachment.file.present?
        end

        def create_attachment
          attachment.attached_to = proposal
          attachment.save!
        end

        def attachments_allowed?
          form.current_component.settings.attachments_allowed?
        end

        def process_attachments?
          attachments_allowed? && attachment_present?
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: proposal,
            recipient_ids: @proposal.participatory_space.followers.pluck(:id),
            extra: {
              participatory_space: true
            }
          )
        end
      end
    end
  end
end
