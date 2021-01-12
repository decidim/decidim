# frozen_string_literal: true

# require "spreadsheet"
require "rubyXL"

require "rubyXL/convenience_methods/cell"
# require "rubyXL/convenience_methods/color"
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
        # book = Spreadsheet::Workbook.new
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

        worksheet.change_row_fill(0, "c0c0c0")
        worksheet.change_row_bold(0, true)
        worksheet.change_row_horizontal_alignment(0, "center")

        processed_collection.each_with_index do |resource, index|
          # sheet.row(index + 1).replace(headers.map { |header| custom_sanitize(resource[header]) })
          headers.each_with_index do |header, j|
            # raise custom_sanitize(resource[header]).class.inspect

            if resource[header].class == ActiveSupport::TimeWithZone
              # c = worksheet.add_cell(index + 1, j)
              # c.set_number_format("dd.mm.yyyy HH:MM:SS")
              # c.change_contents(resource[header].to_datetime)
              # # raise c.value.to_time.utc.iso8601.inspect
              # raise c.raw_value.inspect
              cell = worksheet.add_cell(index + 1, j, custom_sanitize(resource[header]))
              cell.set_number_format("dd.mm.yyyy HH:MM:SS")
              # raise cell.value.inspect
              next
            end
            worksheet.add_cell(index + 1, j, custom_sanitize(resource[header]))
            # c.change_contents(custom_sanitize(resource[header])) if resource[header].class == ActiveSupport::TimeWithZone
            # if j == 5
              # foo = custom_sanitize(resource[header])
              # raise foo.to_date.inspect
              # raise worksheet[1][5].inspect
            # end
          end
        end

        # output = StringIO.new
        # book.write output

        # ExportData.new(output.string, "xls")

        # raise workbook.stream.string.inspect

        ExportData.new(workbook.stream.string, "xlsx")
      end
    end
  end
end
