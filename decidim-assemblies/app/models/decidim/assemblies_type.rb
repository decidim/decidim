# frozen_string_literal: true

module Decidim
  # Assembly type.
  class AssembliesType < ApplicationRecord
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :assemblies,
             foreign_key: "decidim_assemblies_type_id",
             class_name: "Decidim::Assembly",
             dependent: :nullify

    validates :title, presence: true
  end
end
