# frozen_string_literal: true

module Decidim
  # Attachment can be any type of document or images related to a partcipatory
  # process.
  class Attachment < ApplicationRecord
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource

    translatable_fields :title, :description
    belongs_to :attachment_collection, class_name: "Decidim::AttachmentCollection", optional: true
    belongs_to :attached_to, polymorphic: true

    mount_uploader :file, Decidim::AttachmentUploader

    validates_upload :file
    validates :file, :content_type, presence: true

    default_scope { order(arel_table[:weight].asc, arel_table[:id].asc) }

    # Returns the organization related to this attachment in case the
    # attached_to model belongs to an organization. Otherwise will return nil.
    #
    # Returns Decidim::Organization or nil.
    def organization
      return unless attached_to
      return attached_to if attached_to.is_a?(Decidim::Organization)
      return unless attached_to.respond_to?(:organization)

      attached_to.organization
    end

    # The context of the attachments defines which file upload settings
    # constraints should be used when the file is uploaded. The different
    # contexts can limit for instance which file types the user is allowed to
    # upload.
    #
    # Returns Symbol.
    def context
      return attached_to.attachment_context if attached_to.respond_to?(:attachment_context)

      :participant
    end

    # Whether this attachment is a photo or not.
    #
    # Returns Boolean.
    def photo?
      @photo ||= content_type.start_with? "image"
    end

    # Whether this attachment is a document or not.
    #
    # Returns Boolean.
    def document?
      !photo?
    end

    # Which kind of file this is.
    #
    # Returns String.
    def file_type
      file.url&.split(".")&.last&.downcase
    end

    # The URL to download the file.
    #
    # Returns String.
    delegate :url, to: :file

    # The URL to download the thumbnail of the file. Only works with images.
    #
    # Returns String.
    def thumbnail_url
      return unless photo?

      file.thumbnail.url
    end

    # The URL to download the a big version of the file. Only works with images.
    #
    # Returns String.
    def big_url
      return unless photo?

      file.big.url
    end
  end
end
