# frozen_string_literal: true
module Decidim
  # Categories serve as a taxonomy for components to use for while in the
  # context of a participatory process.
  class Category < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcess, inverse_of: :categories
    has_many :subcategories, -> (object) { where(parent_id: object.id) }, foreign_key: "parent_id", class_name: Decidim::Category, dependent: :destroy
    has_one :parent, class_name: Decidim::Category, foreign_key: "parent_id"

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
      if parent.parent.present?
        self.errors.add(:parent_id, :nesting_too_deep)
      end
    end

    def subcategories_have_same_process
      return unless parent
      self.participatory_process = parent.participatory_process
    end
  end
end
