# frozen_string_literal: true

module Decidim
  module Admin
    # Updates the newsletter given form data.
    class UpdateNewsletter < Decidim::Command
      # Initializes the command.
      #
      # newsletter - The Newsletter to update.
      # form       - The form object containing the data to update.
      # user       - The user that updates the newsletter.
      def initialize(newsletter, form, user)
        @newsletter = newsletter
        @content_block = newsletter.template
        @form = form
        @user = user
        @organization = user.organization
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

      attr_reader :user, :newsletter, :content_block, :organization, :form

      def update_newsletter
        @newsletter = Decidim.traceability.update!(
          newsletter,
          user,
          subject: form.subject,
          author: user
        )
      end

      def update_content_block
        UpdateContentBlock.call(form, content_block, user) do
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
