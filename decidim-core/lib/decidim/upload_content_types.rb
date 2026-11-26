# frozen_string_literal: true

module Decidim
  # The content types accepted for each file format, keyed by the format detected
  # from the file contents (magic bytes) or derived from the file extension.
  #
  # It is shared by the upload endpoints and the upload validators so that the
  # content type declared by the client is checked against the same accepted
  # types, and so that the endpoints are not stricter than the model validation
  # for the aliases commonly used in the wild for the same format.
  module UploadContentTypes
    FORMAT_CONTENT_TYPES = {
      png: %w(image/png),
      jpeg: %w(image/jpeg image/jpg image/pjpeg),
      gif: %w(image/gif),
      bmp: %w(image/bmp image/x-ms-bmp image/windows-bmp),
      tiff: %w(image/tiff image/x-tiff),
      webp: %w(image/webp),
      heif: %w(image/heic image/heif image/heic-sequence image/heif-sequence),
      avif: %w(image/avif image/avis),
      svg: %w(image/svg+xml),
      # The text based formats. `text/plain` is the generic type clients use for
      # any plain text file, so it is accepted as an alias for them; without it
      # the upload endpoints would reject a text file declared as `text/plain`
      # even when both it and the type of the extension are allowed.
      txt: %w(text/plain),
      csv: %w(text/csv text/comma-separated-values text/plain),
      json: %w(application/json application/x-json text/json text/plain),
      markdown: %w(text/markdown text/x-markdown text/plain),
      rtf: %w(application/rtf application/x-rtf text/rtf text/plain)
    }.freeze

    # Strips the content type parameters (e.g. "image/png;charset=binary") and
    # normalizes the casing, as content types are case insensitive.
    def self.normalize(content_type)
      content_type.to_s.split(";", 2).first.to_s.strip.downcase
    end

    # The file format a content type belongs to, or nil when it does not belong to
    # one of the known formats.
    def self.format(content_type)
      FORMAT_CONTENT_TYPES.find { |_format, types| types.include?(normalize(content_type)) }&.first
    end

    # Whether the content type is one of the accepted types for the given format.
    def self.match?(format, content_type)
      FORMAT_CONTENT_TYPES.fetch(format).include?(normalize(content_type))
    end

    # The accepted content types for the format of a given content type, or nil
    # when the content type does not belong to a known format.
    def self.accepted_types(content_type)
      FORMAT_CONTENT_TYPES[format(content_type)]
    end
  end
end
