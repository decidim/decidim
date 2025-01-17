# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "upgrade decidim evaluators"
    task decidim_update_evaluators: :environment do
      Decidim::ParticipatoryProcessUserRole.where(role: "evaluator").update_all(role: "evaluator") if Decidim.module_installed?(:participatory_processes)
      Decidim::AssemblyUserRole.where(role: "valuator").update_all(role: "evaluator") if Decidim.module_installed?(:assemblies)
      Decidim::ConferenceUserRole.where(role: "evaluator").update_all(role: "evaluator") if Decidim.module_installed?(:conferences)
    end
  end
end
