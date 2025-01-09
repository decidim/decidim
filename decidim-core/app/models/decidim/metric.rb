# frozen_string_literal: true

module Decidim
  # A Metric is a registry that holds cumulative and quantity value by day, taxonomy, participatory_space, taxonomy, an a related object
  class Metric < ApplicationRecord
    # ParticipatorySpace, RelatedObject and Taxonomy are optional relationships because not all metric objects need them
    # For example, User is only related to an organization, but a Proposal can have all of them
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    belongs_to :participatory_space, foreign_type: "participatory_space_type", polymorphic: true, optional: true
    belongs_to :related_object, foreign_type: "related_object_type", polymorphic: true, optional: true
    belongs_to :taxonomy, foreign_key: "decidim_taxonomy_id", class_name: "Decidim::Taxonomy", optional: true

    validates :day, uniqueness: { scope:
                                  [
                                    :metric_type,
                                    :decidim_organization_id,
                                    :participatory_space_type,
                                    :participatory_space_id,
                                    :related_object_type,
                                    :related_object_id,
                                    :decidim_taxonomy_id
                                  ] }
  end
end
