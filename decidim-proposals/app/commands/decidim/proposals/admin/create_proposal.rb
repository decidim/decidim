# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user creates a new proposal.
      class CreateProposal < Decidim::Command
        include ::Decidim::MultipleAttachmentsMethods

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_attachments?
            build_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          transaction do
            create_proposal
            create_attachments(first_weight: first_attachment_weight) if process_attachments?
            link_author_meeting if form.created_in_meeting?
          end

          send_notification

          broadcast(:ok, proposal)
        end

        private

        attr_reader :form, :proposal, :attachment

        def create_proposal
          @proposal = Decidim::Proposals::ProposalBuilder.create(
            attributes:,
            author: form.author,
            action_user: form.current_user
          )
          @attached_to = @proposal
          Decidim.traceability.perform_action!(:publish, @proposal, form.current_user, visibility: "all") do
            @proposal.update!(published_at: Time.current)
          end
        end

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(form.title, current_organization: form.current_organization).rewrite
          parsed_body = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization).rewrite
          {
            title: parsed_title,
            body: parsed_body,
            taxonomizations: form.taxonomizations,
            component: form.component,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            created_in_meeting: form.created_in_meeting
          }
        end

        def link_author_meeting
          proposal.link_resources(form.author, "proposals_from_meeting")
        end

        def send_notification
          return unless proposal

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: proposal,
            followers: proposal.participatory_space.followers,
            extra: {
              participatory_space: true
            }
          )
        end

        def first_attachment_weight
          return 1 if proposal.photos.count.zero?

          proposal.photos.count
        end
      end
    end
  end
end
