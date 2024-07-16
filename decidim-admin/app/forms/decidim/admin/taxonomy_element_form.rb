# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when creating or updating a taxonomy.
    class TaxonomyElementForm < TaxonomyForm
      mimic :taxonomy

      attribute :parent_id, Integer

      validates :parent_id, presence: true
      # TODO: validate parent_id is valid within the same root taxonomy
    end
  end
end
