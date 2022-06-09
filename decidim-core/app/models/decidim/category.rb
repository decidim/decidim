# frozen_string_literal: true

module Decidim
  # Categories serve as a taxonomy for components to use for while in the
  # context of a participatory process.
  class Category < ApplicationRecord
    include Decidim::TranslatableResource
    include Decidim::FilterableResource
    include Decidim::Traceable

    translatable_fields :name

    belongs_to :participatory_space, foreign_key: "decidim_participatory_space_id", foreign_type: "decidim_participatory_space_type", polymorphic: true
    has_many :subcategories, foreign_key: "parent_id", class_name: "Decidim::Category", dependent: :destroy, inverse_of: :parent
    belongs_to :parent, class_name: "Decidim::Category", inverse_of: :subcategories, optional: true
    has_many :categorizations, foreign_key: "decidim_category_id", class_name: "Decidim::Categorization", dependent: :destroy

    default_scope { order(arel_table[:parent_id].asc, arel_table[:weight].asc) }

    validate :forbid_deep_nesting
    before_validation :subcategories_have_same_participatory_space

    # Scope to return only the first-class categories, that is, those that are
    # not subcategories.
    #
    # Returns an ActiveRecord::Relation.
    def self.first_class
      where(parent_id: nil)
    end

    def descendants
      @descendants ||= Category.where(parent_id: id)
    end

    def translated_name
      Decidim::CategoryPresenter.new(self).translated_name
    end

    def unused?
      categorizations.empty?
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::CategoryPresenter
    end

    # Allow ransacker to search for a key in a hstore column (`name`.`en`)
    ransacker_i18n :name

    private

    # This is done since we only allow one level of subcategories.
    def forbid_deep_nesting
      return unless parent
      return if parent.parent.blank?

      errors.add(:parent_id, :nesting_too_deep)
    end

    def subcategories_have_same_participatory_space
      return unless parent
      return if participatory_space == parent.participatory_space

      self.participatory_space = parent.participatory_space
    end
  end
end
