# frozen_string_literal: true
module Decidim
  module Budgets
    # The data store for a Order in the Decidim::Budgets component. It is unique for each
    # user and feature and contains a collection of projects
    class Order < Budgets::ApplicationRecord
      include Decidim::HasFeature

      feature_manifest_name "budgets"

      belongs_to :user, class_name: Decidim::User, foreign_key: "decidim_user_id"

      has_many :projects, through: :line_items, class_name: Decidim::Budgets::Project, foreign_key: "decidim_project_id"
      has_many :line_items, class_name: Decidim::Budgets::LineItem, foreign_key: "decidim_order_id", dependent: :destroy

      validates :user, presence: true, uniqueness: { scope: :feature }
      validate :user_belongs_to_organization

      validates :total_budget, numericality: {
                  greater_than_or_equal_to: :minimum_budget,
                }, if: :checked_out?

      validates :total_budget, numericality: {
                  less_than_or_equal_to: :maximum_budget
                }

      # Public: Returns the sum of project budgets
      def total_budget
        projects.to_a.sum(&:budget)
      end

      # Public: Returns true if the order has been checked out
      def checked_out?
        checked_out_at.present?
      end

      # Public: Check if the order total budget is enough to checkout
      def can_checkout?
        total_budget.to_f >= minimum_budget
      end

      # Public: Returns the order budget percent from the settings total budget
      def budget_percent
        (total_budget.to_f / feature.settings.total_budget.to_f) * 100
      end

      # Public: Returns the required minimum budget to checkout
      def minimum_budget
        return 0 unless feature
        feature.settings.total_budget.to_f * (feature.settings.vote_threshold_percent.to_f / 100)
      end

      # Public: Returns the required maximum budget to checkout
      def maximum_budget
        return 0 unless feature
        feature.settings.total_budget.to_f
      end

      private

      def user_belongs_to_organization
        return if !user || !organization
        errors.add(:user, :invalid) unless user.organization == organization
      end
    end
  end
end
