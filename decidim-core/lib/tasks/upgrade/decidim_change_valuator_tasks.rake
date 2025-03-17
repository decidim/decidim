# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Upgrade evaluators roles in Spaces"
    task decidim_update_valuators: :environment do
      Decidim::ParticipatoryProcessUserRole.where(role: "valuator").update_all(role: "evaluator") if Decidim.module_installed?(:participatory_processes) # rubocop:disable Rails/SkipsModelValidations
      Decidim::AssemblyUserRole.where(role: "valuator").update_all(role: "evaluator") if Decidim.module_installed?(:assemblies) # rubocop:disable Rails/SkipsModelValidations
      Decidim::ConferenceUserRole.where(role: "valuator").update_all(role: "evaluator") if Decidim.module_installed?(:conferences) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
