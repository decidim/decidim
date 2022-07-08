# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern to help when the file needs to be available locally.
  # For example, we need to download file first if it's in AWS S3 bucket
  # or somewhere else than locally in the server.
  module ProcessesFileLocally
    extend ActiveSupport::Concern

    private

    def process_file_locally(blob)
      if ActiveStorage::Blob.service.respond_to? :path_for
        yield ActiveStorage::Blob.service.path_for(blob.key)
      else
        begin
          tempfile = Tempfile.new
          tempfile.binmode
          blob.download { |chunk| tempfile.write(chunk) }
          tempfile.flush
          tempfile.rewind
          yield tempfile.path
        ensure
          tempfile.close!
        end
      end
    end
  end
end
