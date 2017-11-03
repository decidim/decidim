# frozen_string_literal: true

module Decidim
  module Exporters
    autoload :Exporter, "decidim/exporters/exporter"
    autoload :JSON, "decidim/exporters/json"
    autoload :CSV, "decidim/exporters/csv"
    autoload :Excel, "decidim/exporters/excel"
    autoload :ExportData, "decidim/exporters/export_data"
    autoload :Serializer, "decidim/exporters/serializer"

    # Get the exporter class constant from the format as a string.
    #
    # format - The exporter format as a string. i.e "CSV"
    def self.find_exporter(format)
      const_get(format)
    end
  end
end
