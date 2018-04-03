# frozen_string_literal: true

module Decidim
  module Sortitions
    module Admin
      class SortitionForm < Form
        include TranslatableAttributes

        mimic :sortition

        translatable_attribute :title, String
        attribute :decidim_proposals_component_id, Integer
        attribute :decidim_category_id, Integer
        attribute :dice, Integer
        attribute :target_items, Integer
        translatable_attribute :witnesses, String
        translatable_attribute :additional_info, String

        validates :title, translatable_presence: true
        validates :decidim_proposals_component_id, presence: true
        validates :witnesses, translatable_presence: true
        validates :additional_info, translatable_presence: true
        validates :dice,
                  presence: true,
                  numericality: {
                    only_integer: true,
                    greater_than_or_equal_to: 1,
                    less_than_or_equal_to: 6
                  }

        validates :target_items,
                  presence: true,
                  numericality: {
                    only_integer: true,
                    greater_than_or_equal_to: 1
                  }

        delegate :categories, to: :current_participatory_space
        delegate :current_participatory_space, to: :context
        delegate :current_component, to: :context
      end
    end
  end
end
