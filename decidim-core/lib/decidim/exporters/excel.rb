# frozen_string_literal: true

require "rubyXL"

require "rubyXL/convenience_methods/cell"
require "rubyXL/convenience_methods/font"
require "rubyXL/convenience_methods/workbook"
require "rubyXL/convenience_methods/worksheet"

module Decidim
  module Exporters
    # Exports any serialized object (Hash) into a readable Excel file. It transforms
    # the columns using slashes in a way that can be afterwards reconstructed
    # into the original nested hash.
    #
    # For example, `{ name: { ca: "Hola", en: "Hello" } }` would result into
    # the columns: `name/ca` and `name/es`.
    #
    # It will maintain types like Integers, Floats & Dates so Excel can deal with
    # them.
    class Excel < CSV
      # Public: Exports a file in an Excel readable format.
      #
      # Returns an ExportData instance.
      def export
        workbook = RubyXL::Workbook.new
        worksheet = workbook[0]

        headers.each_with_index.map do |header, index|
          worksheet.change_column_width(index, 20)
          worksheet.add_cell(0, index, header)
        end

        worksheet.change_row_fill(0, "c0c0c0")
        worksheet.change_row_bold(0, true)
        worksheet.change_row_horizontal_alignment(0, "center")

        processed_collection.each_with_index do |resource, index|
          headers.each_with_index do |header, j|
            if resource[header].respond_to?(:strftime)
              cell = worksheet.add_cell(index + 1, j, custom_sanitize(resource[header]))
              resource[header].is_a?(Date) ? cell.set_number_format("dd.mm.yyyy") : cell.set_number_format("dd.mm.yyyy HH:MM:SS")
              next
            end
            worksheet.add_cell(index + 1, j, custom_sanitize(resource[header]))
          end
        end

        ExportData.new(workbook.stream.string, "xlsx")
      end
    end
  end
end
