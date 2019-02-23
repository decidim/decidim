# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        class Permissions < Decidim::DefaultPermissions
          def permissions
            return permission_action if permission_action.scope != :admin
            if user.organization.available_authorizations.include?("csv_census")
              allow! if permission_action.subject == Decidim::Verifications::CsvDatum
              permission_action
            end
          end
        end
      end
    end
  end
end
