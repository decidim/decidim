# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when creating or updating a taxonomy.
    class TaxonomyForm < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :taxonomy

      translatable_attribute :name, String

      attribute :parent_id, Integer
      attribute :weight, Integer
      attribute :organization, Decidim::Organization

      validates :name, translatable_presence: true
      validates :weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :organization, presence: true

      alias organization current_organization
    end
  end
end
