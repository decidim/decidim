# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Update resource_type from ValuationAssignment to EvaluationAssignment"
    task update_resource_type: :environment do
      old_type = "Decidim::Proposals::ValuationAssignment"
      new_type = "Decidim::Proposals::EvaluationAssignment"

      ActionLog.where(resource_type: old_type).update_all(resource_type: new_type) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
