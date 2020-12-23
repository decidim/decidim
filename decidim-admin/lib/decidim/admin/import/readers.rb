# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      module Readers
        autoload :Base, "decidim/admin/import/readers/base"
        autoload :CSV, "decidim/admin/import/readers/csv"
        autoload :JSON, "decidim/admin/import/readers/json"
        autoload :XLS, "decidim/admin/import/readers/xls"

        # Accepted mime types
        # keys: are used for dynamic help text on admin form.
        # values: are used to validate the file format of imported document.
        ACCEPTED_MIME_TYPES = {
          json: Readers::JSON::MIME_TYPE,
          csv: Readers::CSV::MIME_TYPE,
          xls: Readers::XLS::MIME_TYPE
        }.freeze

        def self.all
          [
            Readers::CSV,
            Readers::JSON,
            Readers::XLS
          ]
        end

        def self.search_by_mime_type(mime_type)
          all.each do |reader_klass|
            return reader_klass if mime_type == reader_klass::MIME_TYPE
          end

          nil
        end
      end
    end
  end
end
