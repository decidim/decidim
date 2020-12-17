# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      # A factory class providing easier way to create new importers.
      class ImporterFactory
        def self.build(file, mime_type, *args)
          reader = Readers.find_by_mime_type(mime_type)
          raise NotImplementedError, "No reader implemented for mime type: #{mime_type}" if reader.nil?

          Importer.new(file, reader, *args)
        end
      end
    end
  end
end
