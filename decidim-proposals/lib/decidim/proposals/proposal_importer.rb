# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalImporter < Decidim::Importers::Importer
      def initialize(file, reader = Decidim::Admin::Import::Readers::Base, parser = Decidim::Admin::Import::Parser)
        @file = file
        @reader = reader
        @parser = parser
      end

      def import
        parser.resource_klass.transaction do
          if block_given?
            yield collection
          else
            collection.each(&:save!)
          end
        end
      end

      def collection
        @collection ||= collection_data.map { |item| parser.new(item).parse }
      end

      private

      attr_reader :file, :reader, :parser

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
