# frozen_string_literal: true
module Decidim
  module Budgets
    # The data store for a LineItem in the Decidim::Budgets component. It describes an
    # association between an order and a project.
    class LineItem < Budgets::ApplicationRecord
      belongs_to :order, class_name: Decidim::Budgets::Order, foreign_key: "decidim_order_id"
      belongs_to :project, class_name: Decidim::Budgets::Project, foreign_key: "decidim_project_id"

      validates :order, presence: true, uniqueness: { scope: :project }
      validates :project, presence: true
      validate :same_feature

      def same_feature
        return unless order && project
        errors.add(:order, :invalid) unless order.feature == project.feature
      end
    end
  end
end
