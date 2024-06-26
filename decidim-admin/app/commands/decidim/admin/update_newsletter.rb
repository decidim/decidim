# frozen_string_literal: true

module Decidim
  module Admin
    # Updates the newsletter given form data.
    class UpdateNewsletter < Decidim::Command
      delegate :current_user, to: :form
      # Initializes the command.
      #
      # newsletter - The Newsletter to update.
      # form       - The form object containing the data to update.
      def initialize(newsletter, form)
        @newsletter = newsletter
        @content_block = newsletter.template
        @form = form
        @organization = form.current_organization
      end

      def call
        return broadcast(:invalid) unless form.valid?
        return broadcast(:invalid) if newsletter.sent?
        return broadcast(:invalid) unless organization == newsletter.organization

        transaction do
          update_newsletter
          update_content_block
        end

        broadcast(:ok, newsletter)
      end

      private

      attr_reader :newsletter, :content_block, :organization, :form

      def update_newsletter
        # pp current_user.inspect
        @newsletter = Decidim.traceability.update!(
          newsletter,
          current_user,
          subject: form.subject,
          author: current_user
        )
      end

      def update_content_block
        ContentBlocks::UpdateContentBlock.call(form, content_block, current_user) do
          on(:ok) do |content_block|
            @content_block = content_block
          end
          on(:invalid) do
            raise "There was a problem persisting the changes to the content block"
          end
        end
      end
    end
  end
end
