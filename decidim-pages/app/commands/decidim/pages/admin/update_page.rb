# frozen_string_literal: true

module Decidim
  module Pages
    module Admin
      # This command is executed when the user changes a Page from the admin
      # panel.
      class UpdatePage < Decidim::Command
        include ::Decidim::MultipleAttachmentsMethods

        # Initializes a UpdatePage Command.
        #
        # form - The form from which to get the data.
        # page - The current instance of the page to be updated.
        def initialize(form, page)
          @form = form
          @page = page
          @attached_to = page
        end

        # Updates the page if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          if process_attachments?
            build_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          transaction do
            update_page
            attachment_cleanup!(include_all_attachments: true)
            create_attachments(first_weight: first_attachment_weight) if process_attachments?
          end

          broadcast(:ok)
        end

        private

        def update_page
          Decidim.traceability.update!(
            @page,
            @form.current_user,
            body: @form.body
          )
        end

        def first_attachment_weight
          @page.attachments.count
        end
      end
    end
  end
end
