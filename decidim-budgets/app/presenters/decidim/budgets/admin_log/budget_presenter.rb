# frozen_string_literal: true

module Decidim
  module Budgets
    module AdminLog
      # This class holds the logic to present a `Decidim::Budgets::Budget`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    BudgetPresenter.new(action_log, view_helpers).present
      class BudgetPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.budgets.admin_log.budget.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            title: :i18n,
            weight: :integer,
            description: :i18n,
            total_budget: :currency
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.budget"
        end
      end
    end
  end
end
