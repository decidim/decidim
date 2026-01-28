# frozen_string_literal: true

module Decidim
  module Elections
    module Censuses
      # This class presents data for logging into the system with census data.
      class InternalUsersForm < Decidim::Form
        validate :user_authenticated

        delegate :election, :current_user, to: :context
        delegate :organization, to: :current_user

        attr_reader :authorization_status

        def voter_uid
          @voter_uid ||= election.census.users(election).find_by(id: current_user&.id)&.to_global_id&.to_s
        end

        def adapters
          @required_authorizations ||= Decidim::Verifications::Adapter.from_collection(authorization_handlers.keys)
        end

        def authorization_handlers
          @authorization_handlers ||= election.census_settings&.fetch("authorization_handlers", {})&.slice(*organization.available_authorizations)
        end

        def authorizations
          @authorizations ||= adapters.map do |adapter|
            [
              adapter,
              Decidim::Verifications::Authorizations.new(
                organization: organization,
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

          @authorization_status = Decidim::ActionAuthorizer::AuthorizationStatusCollection.new(authorization_handlers, current_user, election.component, election)

          return if @authorization_status.ok?

          errors.add(:base, I18n.t("decidim.elections.censuses.internal_users_form.invalid"))
        end
      end
    end
  end
end
