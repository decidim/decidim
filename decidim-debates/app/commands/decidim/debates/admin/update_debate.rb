# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # A command with all the business logic when a user updates a debate.
      class UpdateDebate < Decidim::Command
        include Decidim::MultipleAttachmentsMethods

        # Public: Initializes the command.
        #
        # form   - A form object with the params.
        # debate - The debate to update.
        def initialize(form, debate)
          @form = form
          @debate = debate
          @attached_to = debate
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the debate.
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
            update_debate
            document_cleanup!(include_all_attachments: true)
            create_attachments(first_weight: first_attachment_weight) if process_attachments?
          end

          broadcast(:ok, debate)
        end

        private

        attr_reader :form, :debate, :attachment

        def delete_attachment(attachment)
          Attachment.find(attachment.id).delete if attachment.id.to_i == debate.documents.first.id
        end

        def update_debate
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

          Decidim.traceability.update!(
            debate,
            form.current_user,
            title: parsed_title,
            description: parsed_description,
            category: form.category,
            scope: form.scope,
            start_time: form.start_time,
            end_time: form.end_time,
            information_updates: form.information_updates,
            instructions: form.instructions,
            comments_enabled: form.comments_enabled
          )
        end

        def first_attachment_weight
          return 1 if debate.attachments.count.zero?

          debate.attachments.count + 1
        end
      end
    end
  end
end
