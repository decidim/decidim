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
        include Decidim::ProcessesFileLocally

        delegate :errors, to: :verifier

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

        def verify
          verifier.valid?
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

        def invalid_file?
          collection.blank?
        rescue Decidim::Admin::Import::InvalidFileError
          true
        end

        private

        attr_reader :file, :reader, :creator, :context, :data_headers

        def verifier
          # Prepare needs to be called so that data headers become available.
          data = prepare
          @verifier ||= creator.verifier_klass.new(
            headers: data_headers.map(&:to_s),
            data: data,
            reader: reader,
            context: context
          )
        end

        def collection_data
          return @collection_data if @collection_data

          @collection_data = []
          process_file_locally(file) do |file_path|
            reader.new(file_path).read_rows do |rowdata, index|
              if index.zero?
                @data_headers = rowdata.map { |d| d.to_s.to_sym }
              else
                @collection_data << rowdata.each_with_index.to_h do |val, ind|
                  [@data_headers[ind], val]
                end
              end
            end
          end

          @collection_data
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
