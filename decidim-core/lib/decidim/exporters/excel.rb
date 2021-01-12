# frozen_string_literal: true

# require "spreadsheet"
require "rubyXL"
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
        # book = Spreadsheet::Workbook.new
        workbook.add_worksheet("Export")
        # sheet = book.create_worksheet
        worksheet = workbook[0]
        # sheet.name = "Export"

        # sheet.row(0).default_format = Spreadsheet::Format.new(
        #   weight: :bold,
        #   pattern: 1,
        #   pattern_fg_color: :xls_color_14,
        #   horizontal_align: :center
        # )

        # sheet.row(0).replace headers

        # headers.length.times.each do |index|
        #   sheet.column(index).width = 20
        # end

        headers.each_with_index.map do |header, index|
          worksheet.change_column_width(index, 20)
          worksheet.add_cell(0, index, header)
        end

        processed_collection.each_with_index do |resource, index|
          # sheet.row(index + 1).replace(headers.map { |header| custom_sanitize(resource[header]) })
          headers.each_with_index do |header, j|
            worksheet.add_cell(index + 1, j, custom_sanitize(resource[header]))
          end
        end

        # output = StringIO.new
        # book.write output

        # ExportData.new(output.string, "xls")

        ExportData.new(workbook.stream.string, "xlsx")
      end
    end
  end
end
