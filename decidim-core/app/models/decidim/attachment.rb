# frozen_string_literal: true

module Decidim
  # Attachment can be any type of document or images related to a partcipatory
  # process.
  class Attachment < ApplicationRecord
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource
    include Traceable

    before_save :set_content_type_and_size, if: :attached?

    translatable_fields :title, :description
    belongs_to :attachment_collection, class_name: "Decidim::AttachmentCollection", optional: true
    belongs_to :attached_to, polymorphic: true

    has_one_attached :file
    validates_upload :file, uploader: Decidim::AttachmentUploader
    validates :content_type, presence: true

    delegate :attached?, to: :file

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
      @photo ||= file.attached? && file.image?
    end
    alias image? photo?

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
      url&.split(".")&.last&.downcase
    end

    def url
      attached_uploader(:file).path
    end

    # The URL to download the thumbnail of the file. Only works with images.
    #
    # Returns String.
    def thumbnail_url
      return unless photo?

      attached_uploader(:file).path(variant: :thumbnail)
    end

    # The URL to download the a big version of the file. Only works with images.
    #
    # Returns String.
    def big_url
      return unless photo?

      attached_uploader(:file).path(variant: :big)
    end

    def set_content_type_and_size
      self.content_type = file.content_type
      self.file_size = file.byte_size
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::AttachmentPresenter
    end
  end
end
