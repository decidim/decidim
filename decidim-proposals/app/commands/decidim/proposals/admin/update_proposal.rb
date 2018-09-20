# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user updates a proposal.
      class UpdateProposal < Rectify::Command
        include AttachmentMethods

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # proposal - the proposal to update.
        def initialize(form, proposal)
          @form = form
          @proposal = proposal
          @attached_to = proposal
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
            @proposal.attachments.destroy_all

            build_attachment
            return broadcast(:invalid) if attachment_invalid?
          end

          transaction do
            update_proposal
            create_attachment if process_attachments?
          end

          broadcast(:ok, proposal)
        end

        private

        attr_reader :form, :proposal, :current_user, :attachment

        def update_proposal
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_body = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.body, current_organization: form.current_organization).rewrite

          @proposal.update!(
            title: parsed_title,
            body: parsed_body,
            category: form.category,
            scope: form.scope,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude
          )
        end
      end
    end
  end
end
