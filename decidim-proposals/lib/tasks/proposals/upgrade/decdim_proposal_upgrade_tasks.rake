# frozen_string_literal: true

namespace :decidim do
  namespace :proposals do
    namespace :upgrade do
      desc "Removes all proposal valuator records of which the role assignment does not exists"
      task remove_valuator_orphan_records: :environment do
        if Decidim.module_installed?("participatory_processes")
          Decidim::Proposals::ValuationAssignment
            .where(valuator_role_type: "Decidim::ParticipatoryProcessUserRole")
            .where
            .not(valuator_role_id: Decidim::ParticipatoryProcessUserRole.pluck(:id))
            .destroy_all
        end

        if Decidim.module_installed?("assemblies")
          Decidim::Proposals::ValuationAssignment
            .where(valuator_role_type: "Decidim::AssemblyUserRole")
            .where
            .not(valuator_role_id: Decidim::AssemblyUserRole.pluck(:id))
            .destroy_all
        end

        if Decidim.module_installed?("conferences")
          Decidim::Proposals::ValuationAssignment
            .where(valuator_role_type: "Decidim::ConferenceUserRole")
            .where
            .not(valuator_role_id: Decidim::ConferenceUserRole.pluck(:id))
            .destroy_all
        end
      end

      desc "Migrates the withdrawn fields on proposals"
      task migrate_proposal_withdrawn_fields: :environment do
        class CustomProposal < Decidim::Proposals::ApplicationRecord
          self.table_name = "decidim_proposals_proposals"
          STATES = { not_answered: 0, evaluating: 10, accepted: 20, rejected: -10, withdrawn: -20 }.freeze
          enum state: STATES, _default: "not_answered"
        end

        CustomProposal.withdrawn.find_each do |proposal|
          proposal.withdrawn_at = proposal.updated_at
          proposal.save!
        end
      end
    end
  end
end
