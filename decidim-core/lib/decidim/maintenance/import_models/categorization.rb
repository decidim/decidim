# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class Categorization < ApplicationRecord
        self.table_name = "decidim_categorizations"

        belongs_to :category, foreign_key: :decidim_category_id
        belongs_to :categorizable, polymorphic: true
      end
    end
  end
end
