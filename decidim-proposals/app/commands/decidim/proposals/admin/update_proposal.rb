# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user updates a proposal.
      class UpdateProposal < Decidim::Command
        include ::Decidim::MultipleAttachmentsMethods

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
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          delete_attachment(form.attachment) if delete_attachment?

          if process_attachments?
            build_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          transaction do
            update_proposal
            update_proposal_author
            document_cleanup!(include_all_attachments: true)
            create_attachments(first_weight: first_attachment_weight) if process_attachments?
          end

          broadcast(:ok, proposal)
        end

        private

        attr_reader :form, :proposal, :attachment, :gallery

        def delete_attachment(attachment)
          Attachment.find(attachment.id).delete if attachment.id.to_i == proposal.documents.first.id
        end

        def update_proposal
          parsed_title = Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite
          parsed_body = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization).rewrite
          Decidim.traceability.update!(
            proposal,
            form.current_user,
            title: parsed_title,
            body: parsed_body,
            taxonomizations: form.taxonomizations,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            created_in_meeting: form.created_in_meeting
          )
        end

        def update_proposal_author
          proposal.coauthorships.clear
          proposal.add_coauthor(form.author)
          proposal.save!
          proposal
        end

        def first_attachment_weight
          return 1 if proposal.photos.count.zero?

          proposal.photos.count
        end

        def delete_attachment?
          @form.attachment&.delete_file.present?
        end
      end
    end
  end
end
