# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasFilePath
    extend ActiveSupport::Concern

    private

    def file_path
      @file_path ||= if ActiveStorage::Blob.service.respond_to? :path_for
                       ActiveStorage::Blob.service.path_for(file.key)
                     else
                       tempfile = Tempfile.new
                       tempfile.binmode
                       tempfile.write(file.download)
                       tempfile.rewind
                       tempfile.path
                     end
    end
  end
end
