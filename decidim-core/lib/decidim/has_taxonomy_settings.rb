# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasTaxonomySettings
    extend ActiveSupport::Concern

    included do
      def available_taxonomy_filters
        return [] unless settings.respond_to?(:taxonomy_filters)
        return [] if settings.taxonomy_filters.blank?

        @available_taxonomy_filters ||= settings.taxonomy_filters.filter_map do |id|
          Decidim::TaxonomyFilter.find_by(id:)
        end
      end
    end
  end
end
