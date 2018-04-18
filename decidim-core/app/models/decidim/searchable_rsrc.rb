# frozen_string_literal: true

require "pg_search"

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

    validates :locale, uniqueness: { scope: :resource }

    pg_search_scope :global_search,
                    against: { content_a: "A", content_b: "B", content_c: "C", content_d: "D" },
                    order_within_rank: "datetime DESC"
  end
end
