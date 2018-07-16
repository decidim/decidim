# frozen_string_literal: true

module Decidim
  # A moderation belongs to a reportable and includes many reports
  class Metric < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    belongs_to :participatory_space, foreign_key: "participatory_space_id", foreign_type: "participatory_space_type", polymorphic: true, optional: true
    belongs_to :related_object, foreign_key: "related_object_id", foreign_type: "related_object_type", polymorphic: true, optional: true
    belongs_to :category, foreign_key: "decidim_category_id", class_name: "Decidim::Category", optional: true
    default_scope { order(:day) }
  end
end
