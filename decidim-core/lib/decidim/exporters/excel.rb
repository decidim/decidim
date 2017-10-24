# frozen_string_literal: true

require "spreadsheet"

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
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet
        sheet.name = "Export"

        sheet.row(0).default_format = Spreadsheet::Format.new(
          weight: :bold,
          pattern: 1,
          pattern_fg_color: :xls_color_14,
          horizontal_align: :center
        )

        sheet.row(0).replace headers

        headers.length.times.each do |index|
          sheet.column(index).width = 20
        end

        processed_collection.each_with_index do |resource, index|
          sheet.row(index + 1).replace headers.map { |header| resource[header] }
        end

        output = StringIO.new
        book.write output

        ExportData.new(output.string, "xls")
      end
    end
  end
end
