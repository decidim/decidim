# frozen_string_literal: true

module Decidim
  # Categories serve as a taxonomy for components to use for while in the
  # context of a participatory process.
  class Category < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: "Decidim::ParticipatoryProcess", inverse_of: :categories
    has_many :subcategories, foreign_key: "parent_id", class_name: "Decidim::Category", dependent: :destroy, inverse_of: :parent
    belongs_to :parent, class_name: "Decidim::Category", foreign_key: "parent_id", inverse_of: :subcategories

    validate :forbid_deep_nesting
    before_save :subcategories_have_same_process

    # Scope to return only the first-class categories, that is, those that are
    # not subcategories.
    #
    # Returns an ActiveRecord::Relation.
    def self.first_class
      where(parent_id: nil)
    end

    private

    def forbid_deep_nesting
      return unless parent
      return unless parent.parent.present?

      errors.add(:parent_id, :nesting_too_deep)
    end

    def subcategories_have_same_process
      return unless parent
      self.participatory_process = parent.participatory_process
    end
  end
end
