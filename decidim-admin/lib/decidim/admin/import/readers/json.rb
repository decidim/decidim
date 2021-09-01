# frozen_string_literal: true

require "json"

module Decidim
  module Admin
    module Import
      module Readers
        # Imports any exported JSON file to local objects. It transforms the
        # import data using the creator into the final target objects.
        class JSON < Base
          class << self
            def invalid_indexes_message_for(indexes)
              [
                I18n.t("decidim.admin.imports.invalid_indexes.json.message", count: indexes.count, indexes: humanize_indexes(indexes)),
                I18n.t("decidim.admin.imports.invalid_indexes.json.detail")
              ].join(" ")
            end
          end

          MIME_TYPE = "application/json"

          def read_rows
            json_string = File.read(file)
            ::JSON.parse(json_string).each_with_index do |row, index|
              yield row.keys, index if index.zero?
              yield row.values, index + 1
            end
          end
        end
      end
    end
  end
end
