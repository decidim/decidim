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
        # creator - A Creator class to be used during the import.
        # context - A hash including component specific data.
        def initialize(file:, reader: Readers::Base, creator: Creator, context: nil)
          @file = file
          @reader = reader
          @creator = creator
          @context = context
          @data_headers = []
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

        def invalid_columns
          @invalid_columns ||= begin
            prepare
            check_invalid_column_headers
          end
        end

        # Returns array of all resource indexes where validations fail.
        def invalid_indexes
          @invalid_indexes ||= check_invalid_indexes(prepare)
        end

        def invalid_columns_message
          return unless invalid_columns.any?

          reader.invalid_columns_message_for(invalid_columns)
        end

        def invalid_indexes_message
          return unless invalid_indexes.any?

          reader.invalid_indexes_message_for(invalid_indexes)
        end

        private

        attr_reader :file, :reader, :creator, :context

        def collection_data
          return @collection_data if @collection_data

          @collection_data = []
          reader.new(file).read_rows do |rowdata, index|
            if index.zero?
              @data_headers = rowdata.map { |d| d.to_s.to_sym }
            else
              @collection_data << Hash[
                rowdata.each_with_index.map do |val, ind|
                  [@data_headers[ind], val]
                end
              ]
            end
          end

          @collection_data
        end

        def check_invalid_column_headers
          invalid_column_headers = []
          @data_headers.each_with_index do |header, _index|
            invalid_column_headers << header unless creator.header_valid?(header, available_locales)
          end
          invalid_column_headers
        end

        def check_invalid_indexes(imported_data)
          invalid_indexes = []
          imported_data.each_with_index do |record, index|
            invalid_indexes << index unless creator.resource_valid?(record)
          end
          invalid_indexes
        end

        def component
          context[:current_component]
        end

        def available_locales
          @available_locales ||= component.participatory_space.organization.available_locales
        end
      end
    end
  end
end
