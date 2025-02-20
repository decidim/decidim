# frozen_string_literal: true

namespace :paper_trail do
  desc "Update item_type from ValuationAssignment to EvaluationAssignment"
  task update_item_type: :environment do
    old_type = "Decidim::Proposals::ValuationAssignment"
    new_type = "Decidim::Proposals::EvaluationAssignment"

    PaperTrail::Version.where(item_type: old_type).update_all(item_type: new_type) # rubocop:disable Rails/SkipsModelValidations
  end
end
