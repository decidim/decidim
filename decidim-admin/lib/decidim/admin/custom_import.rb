# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Admin
    # A concern to help custom importing procedures that do not use the default
    # importing logic.
    module CustomImport
      extend ActiveSupport::Concern

      include Decidim::ProcessesFileLocally

      private

      def process_import_file(blob, &)
        reader_klass = import_reader_klass_for(blob)
        process_file_locally(blob) do |file_path|
          reader = reader_klass.new(file_path)
          reader.read_rows(&)
        end
      end

      def import_reader_klass_for(blob)
        Decidim::Admin::Import::Readers.search_by_mime_type(blob.content_type)
      end
    end
  end
end
