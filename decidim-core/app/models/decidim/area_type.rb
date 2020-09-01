# frozen_string_literal: true

module Decidim
  # Area types allows to use different types of areas in participatory space
  # (terriotrial, sectorial, etc.)
  class AreaType < ApplicationRecord
    include Decidim::TranslatableResource

    translatable_fields :name, :plural

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :area_types

    has_many :areas, foreign_key: "area_type_id", class_name: "Decidim::Area", inverse_of: :area_type, dependent: :nullify

    validates :name, presence: true

    def translated_name
      Decidim::AreaTypePresenter.new(self).translated_name
    end
  end
end
