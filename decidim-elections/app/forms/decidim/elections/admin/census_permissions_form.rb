# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class CensusPermissionsForm < Decidim::Form
        attribute :verification_types, Array[String]

        def data
          valid_types = context.current_organization.available_authorizations

          verification_types.select! { |type| valid_types.include?(type) }

          users = context.current_organization.users.not_deleted.not_blocked.confirmed
          if verification_types.present?
            verified_users = Decidim::Authorization.select(:decidim_user_id)
                                                   .where(decidim_user_id: users.select(:id))
                                                   .where.not(granted_at: nil)
                                                   .where(name: verification_types)
                                                   .group(:decidim_user_id)
                                                   .having("COUNT(distinct name) = ?", verification_types.count)
            users = users.where(id: verified_users)
          end

          users
        end

        def imported_count
          data.count
        end

        def errors_data
          return [] if valid?

          errors.full_messages
        end
      end
    end
  end
end
