# frozen_string_literal: true

module Decidim
  # Area types allows to use different types of areas in participatory space
  # (terriotrial, sectorial, etc.)
  class AreaType < ApplicationRecord
    include Decidim::TranslatableResource
    include Decidim::Traceable

    translatable_fields :name, :plural

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :area_types

    has_many :areas, class_name: "Decidim::Area", inverse_of: :area_type, dependent: :nullify

    validates :name, presence: true

    def translated_name
      Decidim::AreaTypePresenter.new(self).translated_name
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::AreaTypePresenter
    end
  end
end
