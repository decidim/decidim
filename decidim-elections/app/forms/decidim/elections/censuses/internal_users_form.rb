# frozen_string_literal: true

module Decidim
  module Elections
    module Censuses
      # This class presents data for logging into the system with census data.
      class InternalUsersForm < Decidim::Form
        validate :user_authenticated

        def voter_uid
          @voter_uid ||= election.census.users(election).find_by(id: current_user&.id)&.to_global_id&.to_s
        end

        def election
          @election ||= context.election
        end

        def current_user
          @current_user ||= context.current_user
        end

        def current_organization
          @current_organization ||= election.organization
        end

        def adapters
          @required_authorizations ||= Decidim::Verifications::Adapter.from_collection(
            authorization_handlers.keys & current_organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
          )
        end

        def authorization_handlers
          election.census_settings["authorization_handlers"] || {}
        end

        def authorizations
          @authorizations ||= adapters.map do |adapter|
            [
              adapter,
              Decidim::Verifications::Authorizations.new(
                organization: current_organization,
                user: current_user,
                name: adapter.name
              ).first
            ]
          end
        end

        def in_census?
          voter_uid.present?
        end

        private

        def user_authenticated
          return errors.add(:base, I18n.t("decidim.elections.censuses.internal_users_form.invalid")) unless in_census?

          invalid = authorizations.filter_map do |adapter, authorization|
            if !authorization.granted?
              ["not_granted", adapter]
            elsif adapter.authorize(authorization, authorization_handlers.dig(adapter.name, "options"), election.component, election)&.first != :ok
              ["not_authorized", adapter]
            end
          end

          return if invalid.empty?

          errors.add(:base, I18n.t("decidim.elections.censuses.internal_users_form.invalid"))
          invalid.each do |error, adapter|
            errors.add(:base, I18n.t("decidim.elections.censuses.internal_users_form.#{error}", adapter: adapter.fullname))
          end
        end
      end
    end
  end
end
