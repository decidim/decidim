# frozen_string_literal: true

require "pg_search"

module Decidim
  # A Searchable Resource.
  # This is a model to a PgSearch table that indexes all searchable resources.
  # This table is used to perform textual searches.
  #
  # Main attributes are:
  # - locale: One entry per locale is required, so each resource will be indexed once per locale.
  # - content_a: The most relevant textual content.
  # - content_b: The second most relevant textual content.
  # - content_c: The third most relevant textual content.
  # - content_d: The less relevant textual content.
  # - datetime:  The timestamp that places this resource in the line of time. Used as second criteria (first is text relevance) for sorting.
  #
  class SearchableResource < ApplicationRecord
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
