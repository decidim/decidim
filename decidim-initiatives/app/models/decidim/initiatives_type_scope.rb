# frozen_string_literal: true

module Decidim
  class InitiativesTypeScope < ApplicationRecord
    belongs_to :type,
               foreign_key: "decidim_initiatives_types_id",
               class_name: "Decidim::InitiativesType",
               inverse_of: :scopes

    belongs_to :scope,
               foreign_key: "decidim_scopes_id",
               class_name: "Decidim::Scope"

    has_many :initiatives,
             foreign_key: "scoped_type_id",
             class_name: "Decidim::Initiative",
             dependent: :restrict_with_error,
             inverse_of: :scoped_type

    validates :scope, uniqueness: { scope: :type }
    validates :supports_required, presence: true
    validates :supports_required, numericality: {
      only_integer: true,
      greater_than: 0
    }
  end
end
