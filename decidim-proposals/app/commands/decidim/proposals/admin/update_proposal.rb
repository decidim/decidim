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
            update_proposal_author
            create_attachment if process_attachments?
          end

          broadcast(:ok, proposal)
        end

        private

        attr_reader :form, :proposal, :attachment

        def update_proposal
          Decidim.traceability.update!(
            proposal,
            form.current_user,
            title: parsed_title,
            body: parsed_body,
            category: form.category,
            scope: form.scope,
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

        def parsed_title
          @parsed_title ||= Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        end

        def parsed_body
          @parsed_body ||= begin
            ret = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.body, current_organization: form.current_organization).rewrite.strip
            ret += "\n" + parsed_extra_hashtags.strip unless parsed_extra_hashtags.empty?
            ret
          end
        end

        def parsed_extra_hashtags
          @parsed_extra_hashtags ||= Decidim::ContentProcessor.parse_with_processor(
            :hashtag,
            form.extra_hashtags.map { |hashtag| "##{hashtag}" }.join(" "),
            current_organization: form.current_organization,
            extra_hashtags: true
          ).rewrite
        end
      end
    end
  end
end
