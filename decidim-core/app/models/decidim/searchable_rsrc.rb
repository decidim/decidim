require 'pg_search'

module Decidim
  # A searchable Resource
  class SearchableRsrc < ApplicationRecord
    include PgSearch

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    belongs_to :scope,
               foreign_key: "decidim_scope_id",
               class_name: "Decidim::Scope",
               optional: true
    belongs_to :resource, polymorphic: true
    belongs_to :decidim_participatory_space, polymorphic: true

    pg_search_scope :global_search, against: {content_A: 'A',content_B: 'B',content_C: 'C',content_D: 'D'}
  end
end
