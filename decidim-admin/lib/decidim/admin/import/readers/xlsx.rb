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
          rescue Zip::Error
            raise Decidim::Admin::Import::InvalidFileError, "The provided XLSX file is not valid"
          end

          # Returns a StringIO
          def example_file(data)
            workbook = RubyXL::Workbook.new
            sheet = workbook.worksheets[0]

            data.each_with_index do |row, rowi|
              row.each_with_index do |col, coli|
                sheet.add_cell(rowi, coli, col)
              end
            end

            workbook.stream
          end
        end
      end
    end
  end
end
