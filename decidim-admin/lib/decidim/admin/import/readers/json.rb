# frozen_string_literal: true

require "json"

module Decidim
  module Admin
    module Import
      module Readers
        # Imports any exported JSON file to local objects. It transforms the
        # import data using the creator into the final target objects.
        class JSON < Base
          MIME_TYPE = "application/json"

          def self.invalid_indexes_message_for(indexes)
            [
              I18n.t("decidim.admin.imports.invalid_indexes.json.message", count: indexes.count, indexes: humanize_indexes(indexes)),
              I18n.t("decidim.admin.imports.invalid_indexes.json.detail")
            ].join(" ")
          end

          def read_rows
            json_string = File.read(file)
            columns = []
            ::JSON.parse(json_string).each_with_index do |row, index|
              if index.zero?
                columns = row.keys
                yield columns, index
              end

              values = columns.map { |c| row[c] }
              last_present = values.rindex { |v| !v.nil? }
              if last_present
                yield values[0..last_present], index + 1
              else
                yield [], index + 1
              end
            end
          rescue ::JSON::ParserError
            raise Decidim::Admin::Import::InvalidFileError, "The provided JSON file is not valid"
          end
        end
      end
    end
  end
end
