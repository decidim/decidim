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
        case @options[:size]
        when :s
          "decidim/budgets/project_s"
        else
          "decidim/budgets/project_l"
        end
      end
    end
  end
end
