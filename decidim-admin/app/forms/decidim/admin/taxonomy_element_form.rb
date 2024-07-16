# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when creating or updating a taxonomy.
    class TaxonomyElementForm < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :taxonomy

      # we don't use "name" here to avoid colisions when using foundation tabs for multilang fields tabs
      translatable_attribute :element_name, String
      attribute :parent_id, Integer

      validates :element_name, translatable_presence: true
      validates :parent_id, presence: true
      # TODO: validate parent_id is valid within the same root taxonomy

      alias name element_name

      def map_model(model)
        self.element_name = model.name
      end

      def self.from_params(params, additional_params = {})
        additional_params[:taxonomy] = {}
        params[:taxonomy].each do |key, value|
          additional_params[:taxonomy][key[8..]] = value if key.start_with?("element_name_")
        end
        super(params, additional_params)
      end
    end
  end
end
