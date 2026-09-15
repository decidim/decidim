# frozen_string_literal: true

module Decidim
  module Pages
    # Command that gets called whenever a component's page has to be duplicated.
    # It is need a context with the old component that
    # is going to be duplicated on the new one
    class CopyPage < Decidim::Command
      def initialize(context)
        @context = context
      end

      def call
        Decidim::Pages::Page.transaction do
          pages = Decidim::Pages::Page.where(component: @context[:old_component])
          pages.each do |page|
            new_page = Decidim::Pages::Page.create!(component: @context[:new_component], body: page.body)
            copy_attachments(page, new_page)
          end
        end
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      def copy_attachments(original_page, new_page)
        original_page.attachments.each do |attachment|
          new_attachment = Decidim::Attachment.new(
            {
              attached_to: new_page
            }.merge(
              attachment.attributes.slice("content_type", "description", "file_size", "title", "weight")
            )
          )

          if attachment.file.attached?
            new_attachment.file = attachment.file.blob
          else
            new_attachment.attached_uploader(:file).remote_url = attachment.attached_uploader(:file).url
          end

          new_attachment.save!
        rescue Errno::ENOENT, OpenURI::HTTPError => e
          Rails.logger.warn("[ERROR] Could not copy attachment from page #{original_page.id} when copying to component due to #{e.message}")
        end
      end
    end
  end
end
