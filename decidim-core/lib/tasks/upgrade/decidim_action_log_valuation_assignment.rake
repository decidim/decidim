# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Upgrade the ActionLog model's attribute resource_type from ValuationAssignment to EvaluationAssignment"
    task decidim_action_log_valuation_assignment: :environment do
      old_type = "Decidim::Proposals::ValuationAssignment"
      new_type = "Decidim::Proposals::EvaluationAssignment"

      Decidim::ActionLog.where(resource_type: old_type).update_all(resource_type: new_type) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
