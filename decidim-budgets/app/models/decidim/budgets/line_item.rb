# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a LineItem in the Budget resource. It describes an
    # association between an order and a project.
    class LineItem < Budgets::ApplicationRecord
      belongs_to :order, class_name: "Decidim::Budgets::Order", foreign_key: "decidim_order_id"
      belongs_to :project, class_name: "Decidim::Budgets::Project", foreign_key: "decidim_project_id"

      validates :order, uniqueness: { scope: :project }
      validate :same_budget

      def same_budget
        return unless order && project

        errors.add(:order, :invalid) unless order.budget == project.budget
      end
    end
  end
end
