# frozen_string_literal: true

require "csv"

module Decidim
  module Exporters
    # Exports any serialized object (Hash) into a readable CSV. It transforms
    # the columns using slashes in a way that can be afterwards reconstructed
    # into the original nested hash.
    #
    # For example, `{ name: { ca: "Hola", en: "Hello" } }` would result into
    # the columns: `name/ca` and `name/es`.
    class CSV < Exporter
      # Public: Exports a CSV serialized version of the collection using the
      # provided serializer and following the previously described strategy.
      #
      # Returns an ExportData instance.
      def export
        data = ::CSV.generate(headers: headers, write_headers: true, col_sep: ";") do |csv|
          processed_collection.each do |resource|
            csv << headers.map { |header| resource[header] }
          end
        end

        ExportData.new(data, "csv")
      end

      private

      def headers
        return [] if processed_collection.empty?
        processed_collection.first.keys
      end

      def processed_collection
        @processed_collection ||= collection.map do |resource|
          flatten(@serializer.new(resource).serialize)
        end
      end

      def flatten(object, key = nil)
        if object.is_a? Hash
          object.inject({}) do |result, (subkey, value)|
            new_key = key ? "#{key}/#{subkey}" : subkey.to_s
            result.merge(flatten(value, new_key))
          end
        elsif object.is_a?(Array)
          { key.to_s => object.map(&:to_s).join(", ") }
        else
          { key.to_s => object }
        end
      end
    end
  end
end
