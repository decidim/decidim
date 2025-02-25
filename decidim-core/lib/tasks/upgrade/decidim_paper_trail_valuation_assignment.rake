# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Upgrade PaperTrail model's attribute item_type from ValuationAssignment to EvaluationAssignment"
    task decidim_paper_trail_valuation_assignment: :environment do
      old_type = "Decidim::Proposals::ValuationAssignment"
      new_type = "Decidim::Proposals::EvaluationAssignment"

      PaperTrail::Version.where(item_type: old_type).update_all(item_type: new_type) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
