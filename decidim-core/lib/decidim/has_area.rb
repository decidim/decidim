# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to belong to an
  # area.
  module HasArea
    extend ActiveSupport::Concern

    included do
      belongs_to :area,
                 foreign_key: "decidim_area_id",
                 class_name: "Decidim::Area",
                 optional: true

      scope :with_area, ->(area_id) { where(decidim_area_id: area_id) }

      scope :with_any_area, lambda { |*original_area_ids|
        area_ids = original_area_ids.map { |id| id.to_s.split("_") }.flatten.uniq
        return self if area_ids.include?("all")

        where(decidim_area_id: area_ids)
      }
    end
  end
end
