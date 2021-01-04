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
        # context - A hash including component specific data.
        # creator - A Creator to be used during the import.
        def initialize(file, reader = Readers::Base, context:, creator: Creator)
          @file = file
          @reader = reader
          @creator = creator
          @context = context
        end

        def import
          collection
        end

        # Returns a data collection of the target data.
        def collection
          @collection ||= collection_data.map { |item| creator.new(item, context).produce }
        end

        delegate :finish!, to: :creator

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
      end
    end
  end
end
