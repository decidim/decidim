# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when creating or updating a taxonomy.
    class TaxonomyForm < Decidim::Form
      include Decidim::TranslatableAttributes

      translatable_attribute :name, String do |field, _locale|
        validates field, length: { in: 5..15 }, if: proc { |resource| resource.send(field).present? }
      end

      attribute :parent_id, Integer
      attribute :weight, Integer

      validates :name, presence: true
      validates :weight, numericality: { only_integer: true }
    end
  end
end
