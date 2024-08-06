# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to be used when creating or updating a taxonomy.
    class TaxonomyItemForm < Decidim::Form
      include Decidim::TranslatableAttributes

      mimic :taxonomy

      # we do not use "name" here to avoid collisions when using foundation tabs for multilingual fields tabs
      # as this is used in a modal and the name identifier is used for the root taxonomy
      translatable_attribute :item_name, String
      attribute :parent_id, Integer

      validates :item_name, translatable_presence: true
      validate :validate_parent_id_within_same_root_taxonomy

      alias name item_name

      def map_model(model)
        self.item_name = model.name
      end

      def self.from_params(params, additional_params = {})
        additional_params[:taxonomy] = {}
        if params[:taxonomy]
          params[:taxonomy].each do |key, value|
            additional_params[:taxonomy][key[8..]] = value if key.start_with?("item_name_")
          end
        end
        super
      end

      def validate_parent_id_within_same_root_taxonomy
        if parent
          current_root_taxonomy = if parent.root?
                                    parent
                                  else
                                    parent.root_taxonomy
                                  end

          errors.add(:parent_id, :invalid) unless parent.root_taxonomy.id == current_root_taxonomy.id
        else
          errors.add(:parent_id, :invalid)
        end
      end

      def parent
        @parent ||= Decidim::Taxonomy.find_by(id: parent_id)
      end
    end
  end
end
