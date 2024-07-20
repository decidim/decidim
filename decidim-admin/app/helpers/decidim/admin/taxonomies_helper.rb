# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show taxonomies in admin
    module TaxonomiesHelper
      def taxonomy_count_label
        current_page?(taxonomies_path) ? "amount" : "count"
      end
    end
  end
end
