# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This cell renders the Budgets Group header
      class BudgetsGroupHeaderCell < BaseCell
        delegate :title, :description, to: :model
      end
    end
  end
end
