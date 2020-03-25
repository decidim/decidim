# frozen_string_literal: true

module Decidim
  module Exporters
    autoload :Exporter, "decidim/exporters/exporter"
    autoload :JSON, "decidim/exporters/json"
    autoload :CSV, "decidim/exporters/csv"
    autoload :Excel, "decidim/exporters/excel"
    autoload :PDF, "decidim/exporters/pdf"
    autoload :ExportData, "decidim/exporters/export_data"

    # Necessary for the i18n normalizer to locate strings not directly invoked in views:

    # i18n-tasks-use t('decidim.admin.exports.formats.JSON')
    # i18n-tasks-use t('decidim.admin.exports.formats.CSV')
    # i18n-tasks-use t('decidim.admin.exports.formats.Excel')

    # Get the exporter class constant from the format as a string.
    #
    # format - The exporter format as a string. i.e "CSV"
    def self.find_exporter(format)
      const_get(format)
    end
  end
end
