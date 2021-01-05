# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      # Class providing the interface and implementation of an importer. Needs
      # a reader to be passed to the constructor which handles the import file
      # reading depending on its type.
      #
      # You can also use the ImporterFactory class to create an Importer
      # instance.
      class Importer
        # Public: Initializes an Importer.
        #
        # file   - A file with the data to be imported.
        # reader - A Reader to be used to read the data from the file.
        # creator - A Creator to be used during the import.
        # context - A hash including component specific data.
        def initialize(file:, reader: Readers::Base, creator: Creator, context: nil)
          @file = file
          @reader = reader
          @creator = creator
          @context = context
        end

        # Import data and create resources
        #
        # Returns an array of resources
        def prepare
          @prepare ||= collection.map(&:produce)
        end

        # Save resources
        def import!
          collection.map(&:finish!)
        end

        # Returns a collection of creators
        def collection
          @collection ||= collection_data.map { |item| creator.new(item, context) }
        end

        # Returns array of all resource indexes where validations fail.
        def invalid_lines
          @invalid_lines ||= check_invalid_lines(prepare)
        end

        private

        attr_reader :file, :reader, :creator, :context

        def collection_data
          return @collection_data if @collection_data

          @collection_data = []
          data_headers = []
          reader.new(file).read_rows do |rowdata, index|
            if index.zero?
              data_headers = rowdata.map(&:to_sym)
            else
              @collection_data << Hash[
                rowdata.each_with_index.map do |val, ind|
                  [data_headers[ind], val]
                end
              ]
            end
          end

          @collection_data
        end

        def check_invalid_lines(imported_data)
          invalid_lines = []
          imported_data.each_with_index do |record, index|
            invalid_lines << index + 1 unless record.valid?
          end
          invalid_lines
        end
      end
    end
  end
end
