# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class AreaType < ApplicationRecord
        self.table_name = "decidim_area_types"
        has_many :areas, class_name: "Decidim::Maintenance::ImportModels::Area", inverse_of: :area_type, dependent: :nullify
      end
    end
  end
end
