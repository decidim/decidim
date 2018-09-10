# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a Order in the Decidim::Budgets component. It is unique for each
    # user and component and contains a collection of projects
    class Order < Budgets::ApplicationRecord
      include Decidim::HasComponent

      component_manifest_name "budgets"

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"

      has_many :line_items, class_name: "Decidim::Budgets::LineItem", foreign_key: "decidim_order_id", dependent: :destroy
      has_many :projects, through: :line_items, class_name: "Decidim::Budgets::Project", foreign_key: "decidim_project_id"

      validates :user, uniqueness: { scope: :component }
      validate :user_belongs_to_organization
      validates :total_budget, numericality: { greater_than_or_equal_to: :minimum_budget }, if: :checked_out?
      validates :total_budget, numericality: { less_than_or_equal_to: :maximum_budget }, unless: :per_project
      validates :total_projects, numericality: { less_than_or_equal_to: :number_of_projects }, if: :per_project

      scope :finished, -> { where.not(checked_out_at: nil) }
      scope :pending, -> { where(checked_out_at: nil) }

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
        (total_budget.to_f / component.settings.total_budget.to_f) * 100
      end

      # Public: Returns the required minimum budget to checkout
      def minimum_budget
        return 0 unless component
        component.settings.total_budget.to_f * (component.settings.vote_threshold_percent.to_f / 100)
      end

      # Public: Returns the required maximum budget to checkout
      def maximum_budget
        return 0 unless component
        component.settings.total_budget.to_f
      end

      private

      def user_belongs_to_organization
        organization = component&.organization

        return if !user || !organization
        errors.add(:user, :invalid) unless user.organization == organization
      end
    end
  end
end
