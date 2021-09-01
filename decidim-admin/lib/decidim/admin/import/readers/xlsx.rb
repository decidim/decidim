# frozen_string_literal: true

require "rubyXL"

module Decidim
  module Admin
    module Import
      module Readers
        # Imports any exported XLSX file to local objects. It transforms the
        # import data using the creator into the final target objects.
        class XLSX < Base
          MIME_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

          def self.first_data_index
            1
          end

          def read_rows
            workbook = RubyXL::Parser.parse(file)
            sheet = workbook.worksheets[0]
            sheet.each_with_index do |row, index|
              if row
                yield row.cells.map { |c| c && c.value }, index
              else
                yield [], index
              end
            end
          end
        end
      end
    end
  end
end
