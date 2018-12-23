# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a Order in the Decidim::Budgets component. It is unique for each
    # user and component and contains a collection of projects
    class Order < Budgets::ApplicationRecord
      include Decidim::HasComponent
      include Decidim::DataPortability

      component_manifest_name "budgets"

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"

      has_many :line_items, class_name: "Decidim::Budgets::LineItem", foreign_key: "decidim_order_id", dependent: :destroy
      has_many :projects, through: :line_items, class_name: "Decidim::Budgets::Project", foreign_key: "decidim_project_id"

      validates :user, uniqueness: { scope: :component }
      validate :user_belongs_to_organization

      validates :total_budget, numericality: { greater_than_or_equal_to: :minimum_budget }, if: :checked_out_and_not_project?
      validates :total_budget, numericality: { less_than_or_equal_to: :maximum_budget }, unless: :per_project

      validates :total_projects, numericality: { less_than_or_equal_to: :number_of_projects }, if: :per_project
      # i18n-tasks-use t('activerecord.errors.messages.equal_to')
      validates :total_projects, numericality: { equal_to: :number_of_projects }, if: :checked_out_and_per_project?

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

      # Public: Returns the order budget percent from the settings total budget
      def budget_percent
        (total_budget.to_f / component.settings.total_budget.to_f) * 100
      end

      # Public: Returns the required minimum budget to checkout
      def minimum_budget
        return 0 unless component

        component.settings.total_budget.to_f * (component.settings.vote_threshold_percent.to_f / 100)
      end

      # Public: Returns true if the order has been checked out and is budget type
      def checked_out_and_not_project?
        checked_out? && !per_project
      end

      # Public: Returns true if the order has been checked out and is project type
      def checked_out_and_per_project?
        checked_out? && per_project
      end

      def per_project
        component&.settings&.vote_per_project?
      end

      def limit_project_reached?
        return false unless per_project
        total_projects == number_of_projects
      end

      def total_projects
        projects.count
      end

      def remaining_projects
        number_of_projects - projects.count
      end

      def can_checkout?
        if per_project
          limit_project_reached?
        else
          total_budget.to_f >= minimum_budget
        end
      end

      def number_of_projects
        component.settings.total_projects
      end

      def maximum_budget
        return 0 unless component || !per_project
        component&.settings&.total_budget.to_f
      end

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Budgets::DataPortabilityBudgetsOrderSerializer
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
