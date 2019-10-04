# frozen_string_literal: true

module Decidim
  module Exporters
    # Get the exporter class constant from the format as a string.
    #
    # format - The exporter format as a string. i.e "CSV"
    def self.find_exporter(format)
      const_get(format)
    end
  end
end
