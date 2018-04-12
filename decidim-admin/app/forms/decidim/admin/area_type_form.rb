# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update areas.
    class AreaTypeForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      translatable_attribute :plural, String
      attribute :organization, Decidim::Organization

      mimic :area_type

      validates :name, :plural, translatable_presence: true
      validates :organization, presence: true

      alias organization current_organization
    end
  end
end
