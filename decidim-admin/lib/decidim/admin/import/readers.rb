# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      module Readers
        autoload :Base, "decidim/admin/import/readers/base"
        autoload :CSV, "decidim/admin/import/readers/csv"
        autoload :JSON, "decidim/admin/import/readers/json"
        autoload :XLSX, "decidim/admin/import/readers/xlsx"

        # Accepted mime types
        # keys: are used for dynamic help text on admin form.
        # values: are used to validate the file format of imported document.
        ACCEPTED_MIME_TYPES = {
          csv: Readers::CSV::MIME_TYPE,
          json: Readers::JSON::MIME_TYPE,
          xlsx: Readers::XLSX::MIME_TYPE
        }.freeze

        def self.all
          [
            Readers::CSV,
            Readers::JSON,
            Readers::XLSX
          ]
        end

        def self.search_by_mime_type(mime_type)
          all.each do |reader_klass|
            return reader_klass if mime_type == reader_klass::MIME_TYPE
          end

          nil
        end

        def self.search_by_file_extension(extension)
          return unless ACCEPTED_MIME_TYPES.has_key?(extension.to_sym)

          search_by_mime_type(ACCEPTED_MIME_TYPES[extension.to_sym])
        end
      end
    end
  end
end
