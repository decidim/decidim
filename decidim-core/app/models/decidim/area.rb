# frozen_string_literal: true

module Decidim
  # Areas are used in Assemblies to help users know which is
  # the Area of a participatory space.
  class Area < ApplicationRecord
    include Traceable
    include Loggable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :areas

    belongs_to :area_type,
               foreign_key: "area_type_id",
               class_name: "Decidim::AreaType",
               inverse_of: :areas,
               optional: true

    validates :name, :organization, presence: true
    validates :name, uniqueness: { scope: [:organization, :area_type] }

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::AreaPresenter
    end

    def translated_name
      Decidim::AreaPresenter.new(self).translated_name
    end
  end
end
