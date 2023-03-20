# frozen_string_literal: true

namespace :decidim do
  namespace :proposals do
    namespace :upgrade do
      desc "Removes all proposal valuator records of which the role assignment does not exists"
      task remove_orphan_records: :environment do
        Decidim::Proposals::ValuationAssignment
          .where(valuator_role_type: "Decidim::ParticipatoryProcessUserRole")
          .where
          .not(valuator_role_id: Decidim::ParticipatoryProcessUserRole.pluck(:id))
          .destroy_all

        Decidim::Proposals::ValuationAssignment
          .where(valuator_role_type: "Decidim::AssemblyUserRole")
          .where
          .not(valuator_role_id: Decidim::AssemblyUserRole.pluck(:id))
          .destroy_all

        Decidim::Proposals::ValuationAssignment
          .where(valuator_role_type: "Decidim::ConferenceUserRole")
          .where
          .not(valuator_role_id: Decidim::ConferenceUserRole.pluck(:id))
          .destroy_all
      end
    end
  end
end
