# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    module Import
      module Readers
        # Imports any exported CSV file to local objects. It transforms the
        # import data using the creator into the final target objects.
        class CSV < Base
          MIME_TYPE = "text/csv"

          def self.first_data_index
            1
          end

          def read_rows
            ::CSV.read(file, col_sep: Decidim.default_csv_col_sep, encoding: "BOM|UTF-8").each_with_index do |row, index|
              yield row, index
            end
          end

          # Returns a StringIO
          def example_file(data)
            csv_data = ::CSV.generate(col_sep: Decidim.default_csv_col_sep) do |csv|
              data.each do |row|
                csv << row
              end
            end

            ::StringIO.new(csv_data)
          end
        end
      end
    end
  end
end
