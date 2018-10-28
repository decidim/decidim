# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budget project card for an instance of a project
    # the default size is the Medium Card (:m)
    class ProjectCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/budgets/project_m"
      end
    end
  end
end
