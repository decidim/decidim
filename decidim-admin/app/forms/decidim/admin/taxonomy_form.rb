# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when creating or updating a taxonomy.
    class TaxonomyForm < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :taxonomy

      translatable_attribute :name, String

      validates :name, translatable_presence: true

      alias organization current_organization

      def parent_id = nil
    end
  end
end
