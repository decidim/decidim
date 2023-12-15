# frozen_string_literal: true

module Decidim
  module Admin
    # Creates a newsletter and assigns the right author and
    # organization.
    class CreateNewsletter < Decidim::Commands::CreateResource
      fetch_form_attributes :subject, :organization
      # Initializes the command.
      #
      # form - The source fo data for this newsletter.
      # content_block - An instance of `Decidim::ContentBlock` that holds the
      #     newsletter attributes.
      def initialize(form, content_block)
        super(form)
        @content_block = content_block
      end

      private

      attr_reader :content_block

      def resource_class = Decidim::Newsletter

      def attributes = super.merge({ author: form.current_user })

      def run_after_hooks
        ContentBlocks::UpdateContentBlock.call(form, content_block, form.current_user) do
          on(:ok) do |content_block|
            content_block.update(scoped_resource_id: resource.id)
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
