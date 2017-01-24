# frozen_string_literal: true
module Decidim
  # Attachment can be any type of document or images related to a partcipatory
  # process.
  class ParticipatoryProcessAttachment < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcess, inverse_of: :attachments

    validates :file, :participatory_process, :content_type, presence: true
    validates :file, file_size: { less_than_or_equal_to: 10.megabytes }
    mount_uploader :file, Decidim::AttachmentUploader

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
      file.url&.split(".").last&.downcase
    end

    # The URL to download the file.
    #
    # Returns String.
    def url
      file.url
    end

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
