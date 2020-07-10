# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a Order in the Decidim::Budgets component. It is unique for each
    # user and component and contains a collection of projects
    class Order < Budgets::ApplicationRecord
      include Decidim::DataPortability
      include Decidim::NewsletterParticipant

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"
      belongs_to :budget, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Budget", inverse_of: :orders
      has_one :component, through: :budget, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
      has_many :line_items, class_name: "Decidim::Budgets::LineItem", foreign_key: "decidim_order_id", dependent: :destroy
      has_many :projects, through: :line_items, class_name: "Decidim::Budgets::Project", foreign_key: "decidim_project_id"

      validates :user, uniqueness: { scope: :budget }
      validates :budget, presence: true
      validate :user_belongs_to_organization

      validates :total_budget, numericality: {
        greater_than_or_equal_to: :minimum_budget
      }, if: :checked_out?

      validates :total_budget, numericality: {
        less_than_or_equal_to: :maximum_budget
      }

      validate :reach_minimum_projects, if: :checked_out?

      scope :finished, -> { where.not(checked_out_at: nil) }
      scope :pending, -> { where(checked_out_at: nil) }

      # Public: Returns the sum of project budgets
      def total_budget
        projects.to_a.sum(&:budget_amount)
      end

      # Public: Returns true if the order has been checked out
      def checked_out?
        checked_out_at.present?
      end

      # Public: Check if the order total budget is enough to checkout
      def can_checkout?
        if minimum_projects_rule?
          projects.count >= minimum_projects
        else
          total_budget.to_f >= minimum_budget
        end
      end

      # Public: Returns the order budget percent from the settings total budget
      def budget_percent
        (total_budget.to_f / budget.total_budget.to_f) * 100
      end

      # Public: Returns the required minimum budget to checkout
      def minimum_budget
        return 0 unless budget
        return 0 if minimum_projects_rule?

        budget.total_budget.to_f * (budget.settings.vote_threshold_percent.to_f / 100)
      end

      # Public: Returns the required maximum budget to checkout
      def maximum_budget
        return 0 unless budget

        budget.total_budget.to_f
      end

      # Public: Returns if it is required a minimum projects limit to checkout
      def minimum_projects_rule?
        return unless budget

        budget.settings.vote_rule_minimum_budget_projects_enabled
      end

      # Public: Returns the required minimum projects to checkout
      def minimum_projects
        return 0 unless budget

        budget.settings.vote_minimum_budget_projects_number
      end

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Budgets::DataPortabilityBudgetsOrderSerializer
      end

      def self.newsletter_participant_ids(component)
        Decidim::Budgets::Order.where(component: component).joins(:component)
                               .finished
                               .pluck(:decidim_user_id).flatten.compact.uniq
      end

      private

      def user_belongs_to_organization
        organization = budget.try(:component).try(:organization)

        return if !user || !organization

        errors.add(:user, :invalid) unless user.organization == organization
      end

      def reach_minimum_projects
        return unless minimum_projects_rule?

        errors.add(:projects, :invalid) if minimum_projects > projects.count
      end
    end
  end
end
