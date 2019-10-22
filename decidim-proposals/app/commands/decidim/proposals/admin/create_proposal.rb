# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user creates a new proposal.
      class CreateProposal < Rectify::Command
        include AttachmentMethods
        include GalleryMethods
        include HashtagsMethods

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

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            create_proposal
            create_card_image if form.component.settings.allow_card_image?
            create_attachment if process_attachments?
            create_gallery if process_gallery?
            send_notification
          end

          broadcast(:ok, proposal)
        end

        private

        attr_reader :form, :proposal, :attachment, :gallery

        def create_proposal
          @proposal = Decidim::Proposals::ProposalBuilder.create(
            attributes: attributes,
            author: form.author,
            action_user: form.current_user
          )
          @attached_to = @proposal
        end

        def create_card_image
          @proposal.card_image = form.card_image
          @proposal.remove_card_image = form.remove_card_image
          @proposal.save
        end

        def attributes
          {
            title: title_with_hashtags,
            body: body_with_hashtags,
            category: form.category,
            scope: form.scope,
            component: form.component,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            created_in_meeting: form.created_in_meeting,
            card_image: form.card_image,
            published_at: Time.current
          }
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: proposal,
            followers: @proposal.participatory_space.followers,
            extra: {
              participatory_space: true
            }
          )
        end
      end
    end
  end
end
