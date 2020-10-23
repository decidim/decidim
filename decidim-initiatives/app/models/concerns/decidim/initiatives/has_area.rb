# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    module HasArea
      extend ActiveSupport::Concern

      included do
        belongs_to :area,
                   foreign_key: "decidim_area_id",
                   class_name: "Decidim::Area",
                   optional: true

        delegate :areas, to: :organization

        validate :area_belongs_to_organization
      end

      private

      def area_belongs_to_organization
        return unless area && organization

        errors.add(:area, :invalid) unless areas.exists?(id: area.id)
      end
    end
  end
end
