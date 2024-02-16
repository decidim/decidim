# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the cost report for a proposal.
    class CostReportCell < Decidim::ViewModel
      include ProposalCellsHelper

      private

      def cost
        number_to_currency(model.cost, unit: Decidim.currency_unit)
      end

      def cost_report
        decidim_sanitize_editor(translated_attribute(model.cost_report).html_safe)
      end

      def execution_period
        decidim_sanitize_editor(translated_attribute(model.execution_period).html_safe)
      end
    end
  end
end
