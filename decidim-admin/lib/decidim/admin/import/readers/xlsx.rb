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

          def read_rows
            workbook = RubyXL::Parser.parse(file)
            sheet = workbook.worksheets[0]
            sheet.each_with_index do |row, index|
              yield row.cells.map(&:value), index
            end
          end
        end
      end
    end
  end
end
