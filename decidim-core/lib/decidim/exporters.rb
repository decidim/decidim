# frozen_string_literal: true

module Decidim
  module Exporters
    autoload :Exporter, "decidim/exporters/exporter"
    autoload :JSON, "decidim/exporters/json"
    autoload :CSV, "decidim/exporters/csv"
    autoload :Excel, "decidim/exporters/excel"
    autoload :PDF, "decidim/exporters/pdf"
    autoload :ExportData, "decidim/exporters/export_data"

    # Lock the export formats to one of the available exporters
    EXPORT_FORMATS = [:JSON, :CSV, :Excel, :PDF, :FormPDF].freeze

    class UnknownFormatError < StandardError; end

    # Necessary for the i18n normalizer to locate strings not directly invoked in views:

    # i18n-tasks-use t('decidim.admin.exports.formats.JSON')
    # i18n-tasks-use t('decidim.admin.exports.formats.CSV')
    # i18n-tasks-use t('decidim.admin.exports.formats.Excel')

    # Get the exporter class constant from the format as a string.
    #
    # format - The exporter format as a string. i.e "CSV"
    def self.find_exporter(format)
      raise UnknownFormatError unless format.respond_to?(:to_sym)
      raise UnknownFormatError unless EXPORT_FORMATS.include?(format.to_sym)
      raise UnknownFormatError unless const_defined?(format.to_sym)

      const_get(format.to_sym)
    end
  end
end
