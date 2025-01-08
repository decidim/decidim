# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This class holds a Form to create/update results from Decidim's admin panel.
      class ResultBulkActionsForm < Decidim::Form
        include Decidim::TranslationsHelper
        include Decidim::HasTaxonomyFormAttributes

        attribute :result_ids, Array[Integer]
        attribute :start_date, Decidim::Attributes::LocalizedDate
        attribute :end_date, Decidim::Attributes::LocalizedDate
        attribute :decidim_accountability_status_id, Integer
      end
    end
  end
end
