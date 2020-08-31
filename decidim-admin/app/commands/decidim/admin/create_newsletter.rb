# frozen_string_literal: true

module Decidim
  module Admin
    # Creates a newsletter and assigns the right author and
    # organization.
    class CreateNewsletter < Rectify::Command
      # Initializes the command.
      #
      # form - The source fo data for this newsletter.
      # content_block - An instance of `Decidim::ContentBlock` that holds the
      #     newsletter attributes.
      # user - The User that authored this newsletter.
      def initialize(form, content_block, user)
        @form = form
        @content_block = content_block
        @user = user
      end

      def call
        return broadcast(:invalid) unless form.valid?

        transaction do
          create_newsletter
          create_content_block
        end

        broadcast(:ok, newsletter)
      end

      private

      attr_reader :user, :form, :newsletter, :content_block

      def create_newsletter
        @newsletter = Decidim.traceability.create!(
          Newsletter,
          user,
          subject: form.subject,
          author: user,
          organization: user.organization
        )
      end

      def create_content_block
        UpdateContentBlock.call(form, content_block, user) do
          on(:ok) do |content_block|
            content_block.update(scoped_resource_id: newsletter.id)
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
