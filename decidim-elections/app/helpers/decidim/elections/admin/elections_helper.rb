# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module ElectionsHelper
        include Decidim::ApplicationHelper

        def formatted_verification_types
          if election.verification_types.empty?
            I18n.t("internal_census_fields.no_additional_authorizations", scope: "decidim.elections.admin.census")
          else
            election.verification_types.map do |type|
              I18n.t("decidim.authorization_handlers.#{type}.name").downcase
            end.join(", ")
          end
        end
      end
    end
  end
end
