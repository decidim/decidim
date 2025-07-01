# frozen_string_literal: true

module Decidim
  module Pages
    module Admin
      # This class holds a Form to update pages from Decidim's admin panel.
      class PageForm < Decidim::Form
        include TranslatableAttributes
        include Decidim::AttachmentAttributes
        include Decidim::HasUploadValidations

        translatable_attribute :body, Decidim::Attributes::RichText
        attribute :attachment, ::Decidim::AttachmentForm

        attachments_attribute :documents
        attachments_attribute :photos
      end
    end
  end
end
