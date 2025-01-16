# frozen_string_literal: true

namespace :decidim_proposals do
  namespace :upgrade do
    desc "Assigns category to emendations based on amendable category"
    task set_categories: :environment do
      Decidim::Proposals::Proposal.includes(:category).find_each do |proposal|
        next if proposal.category.blank?
        next unless proposal.amendable?

        proposal.emendations.each do |emendation|
          emendation.category = proposal.category
          emendation.save(validate: false)
        end
      end
    end

    desc "Removes all proposal valuator records of which the role assignment does not exists"
    task remove_evaluator_orphan_records: :environment do
      if Decidim.module_installed?("participatory_processes")
        Decidim::Proposals::ValuationAssignment
          .where(evaluator_role_type: "Decidim::ParticipatoryProcessUserRole")
          .where
          .not(evaluator_role_id: Decidim::ParticipatoryProcessUserRole.pluck(:id))
          .destroy_all
      end

      if Decidim.module_installed?("assemblies")
        Decidim::Proposals::ValuationAssignment
          .where(evaluator_role_type: "Decidim::AssemblyUserRole")
          .where
          .not(evaluator_role_id: Decidim::AssemblyUserRole.pluck(:id))
          .destroy_all
      end

      if Decidim.module_installed?("conferences")
        Decidim::Proposals::ValuationAssignment
          .where(evaluator_role_type: "Decidim::ConferenceUserRole")
          .where
          .not(evaluator_role_id: Decidim::ConferenceUserRole.pluck(:id))
          .destroy_all
      end
    end
  end
end
