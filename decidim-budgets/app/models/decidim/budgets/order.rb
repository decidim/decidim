# frozen_string_literal: true
module Decidim
  module Budgets
    # The data store for a Order in the Decidim::Budgets component. It is unique for each
    # user and feature and contains a collection of projects
    class Order < Budgets::ApplicationRecord
      belongs_to :user, class_name: Decidim::User, foreign_key: "decidim_user_id"
      belongs_to :feature, class_name: Decidim::Feature, foreign_key: "decidim_feature_id"

      has_many :projects, through: :line_items, class_name: Decidim::Budgets::Project, foreign_key: "decidim_project_id"
      has_many :line_items, class_name: Decidim::Budgets::LineItem, foreign_key: "decidim_order_id", dependent: :destroy

      validates :user, presence: true, uniqueness: { scope: :feature }
      validates :feature, presence: true

      # Public: Returns the sum of project budgets
      def total_budget
        projects.sum(&:budget)
      end
    end
  end
end
