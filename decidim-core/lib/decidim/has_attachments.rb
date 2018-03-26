# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be able to create
  # links from it to another resource.
  module HasAttachments
    extend ActiveSupport::Concern

    included do
      has_many :attachments,
               class_name: "Decidim::Attachment",
               dependent: :destroy,
               inverse_of: :attached_to,
               as: :attached_to

      # All the attachments that are photos for this process.
      #
      # Returns an Array<Attachment>
      def photos
        @photos ||= attachments.select(&:photo?)
      end

      # All the attachments that are documents for this process.
      #
      # Returns an Array<Attachment>
      def documents
        @documents ||= attachments.select(&:document?)
      end

      # All the attachments that are documents for this process that has a collection.
      #
      # Returns an Array<Attachment>
      def documents_with_collection
        documents.select(&:attachment_collection_id?)
      end

      # All the attachments that are documents for this process that not has a collection.
      #
      # Returns an Array<Attachment>
      def documents_without_collection
        documents.reject(&:attachment_collection_id?)
      end
    end
  end
end
