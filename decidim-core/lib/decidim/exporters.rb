# frozen_string_literal: true

module Decidim
  module Exporters
    autoload :Exporter, "decidim/exporters/exporter"
    autoload :JSON, "decidim/exporters/json"
    autoload :CSV, "decidim/exporters/csv"
    autoload :ExportData, "decidim/exporters/export_data"
    autoload :Serializer, "decidim/exporters/serializer"

    def self.find_exporter(format)
      const_get(format.upcase)
    end
  end
end
