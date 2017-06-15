# frozen_string_literal: true

module Decidim
  # Scopes are used in some entities through Decidim to help users know which is
  # the scope of a participatory process.
  # (i.e. does it affect the whole city or just a district?)
  class ScopeType < ApplicationRecord
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :scope_types

    has_many :scopes, foreign_key: "decidim_scope_type_id", class_name: "Decidim::Scope", inverse_of: :scope_type
  end
end
