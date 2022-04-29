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

      # The first attachment that is a photo for this model.
      #
      # Returns an Attachment
      def photo
        @photo ||= photos.first
      end

      # All the attachments that are photos for this model.
      #
      # Returns an Array<Attachment>
      def photos
        @photos ||= attachments.with_attached_file.order(:weight).select(&:photo?)
      end

      # All the attachments that are documents for this model.
      #
      # Returns an Array<Attachment>
      def documents
        @documents ||= attachments.with_attached_file.order(:weight).includes(:attachment_collection).select(&:document?)
      end

      # All the attachments that are documents for this model that has a collection.
      #
      # Returns an Array<Attachment>
      def documents_with_collection
        documents.select(&:attachment_collection_id?)
      end

      # All the attachments that are documents for this model that not has a collection.
      #
      # Returns an Array<Attachment>
      def documents_without_collection
        documents.reject(&:attachment_collection_id?)
      end
    end

    # Attachment context for the file uploaders checks (e.g. which kind of files
    # the user is allowed to upload in this context).
    #
    # Override this in the model class if it is for a different context.
    #
    # Returns a Symbol.
    def attachment_context
      :participant
    end
  end
end
