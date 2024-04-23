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

    after_create_commit :increase_attachment_counter
    after_destroy_commit :decrease_attachment_counter

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

    private

    # rubocop:disable Rails/SkipsModelValidations
    def increase_attachment_counter
      return if dummy_resource_class?

      attached_to.increment!(:attachments_count)
    end

    def decrease_attachment_counter
      return if dummy_resource_class?

      attached_to.decrement!(:attachments_count)
    end
    # rubocop:enable Rails/SkipsModelValidations

    # Skip the attachments counter_cache if this is a DummyResource class or if it is the Organization class
    # (both used in tests).
    # In the case of the DummyResource class, as it does not have a table so the counter_cache does not work on it
    # In the case of the Organization class, it is only used for tests, so it does not need the column in the table
    def dummy_resource_class?
      return false unless defined?("Decidim::Dev")

      [::Decidim::Dev::DummyResource, ::Decidim::Organization].any? { |klass| attached_to.instance_of? klass }
    end
  end
end
