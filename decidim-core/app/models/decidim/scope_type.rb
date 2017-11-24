# frozen_string_literal: true

module Decidim
  # Scope types allows to use different types of scopes in participatory process
  # (municipalities, provinces, states, countries, etc.)
  class ScopeType < ApplicationRecord
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :scope_types

    has_many :scopes, foreign_key: "scope_type_id", class_name: "Decidim::Scope", inverse_of: :scope_type, dependent: :nullify

    validates :name, presence: true
  end
end
