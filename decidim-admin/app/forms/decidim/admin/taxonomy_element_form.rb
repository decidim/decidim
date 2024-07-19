# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when creating or updating a taxonomy.
    class TaxonomyElementForm < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :taxonomy

      # we do not use "name" here to avoid collisions when using foundation tabs for multilingual fields tabs
      translatable_attribute :element_name, String
      attribute :parent_id, Integer

      validates :element_name, translatable_presence: true
      validates :parent_id, presence: true
      validate :validate_parent_id_within_same_root_taxonomy

      alias name element_name

      def map_model(model)
        self.element_name = model.name
      end

      def self.from_params(params, additional_params = {})
        additional_params[:taxonomy] = {}
        if params[:taxonomy]
          params[:taxonomy].each do |key, value|
            additional_params[:taxonomy][key[8..]] = value if key.start_with?("element_name_")
          end
        end
        super(params, additional_params)
      end

      def validate_parent_id_within_same_root_taxonomy
        return unless parent_id
        return unless parent

        current_root_taxonomy = if parent.parent_id.nil?
                                  parent
                                else
                                  parent.root_taxonomy
                                end

        errors.add(:parent_id, :invalid) unless parent.root_taxonomy.id == current_root_taxonomy.id
      end

      def parent
        @parent ||= Decidim::Taxonomy.find_by(id: parent_id) if parent_id.present?
      end
    end
  end
end
