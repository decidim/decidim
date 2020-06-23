# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a budget in the Decidim::Budgets component.
    class Budget < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Traceable
      include Loggable

      component_manifest_name "budgets"

      delegate :participatory_space, :manifest, :settings, to: :component

      def self.log_presenter_class_for(_log)
        Decidim::Budgets::AdminLog::BudgetPresenter
      end
    end
  end
end
