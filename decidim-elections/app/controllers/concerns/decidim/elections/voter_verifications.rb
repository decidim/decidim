# frozen_string_literal: true

module Decidim
  module Elections
    module VoterVerifications
      extend ActiveSupport::Concern

      included do
        helper_method :voter_verified?, :valid_voter?
      end

      def voter_verified?
        return false unless current_user

        required_authorizations = census_authorize_methods.map(&:name)

        return true if election.internal_census? && required_authorizations.empty?

        required_authorizations.all? { |auth| user_authorizations.include?(auth) }
      end

      def census_authorize_methods
        @census_authorize_methods ||= available_verification_workflows.select do |workflow|
          election.verification_types.include?(workflow.name)
        end
      end

      def user_authorizations
        @user_authorizations ||= Decidim::Verifications::Authorizations
                                 .new(organization: current_organization, user: current_user, granted: true)
                                 .query
                                 .pluck(:name)
      end

      def available_verification_workflows
        Decidim::Verifications::Adapter.from_collection(current_organization.available_authorizations & Decidim.authorization_workflows.map(&:name))
      end

      def valid_voter?(email, token)
        Decidim::Elections::Voter.with_email(email).find_by(election_id: election.id)&.then { |v| v.token == token }
      end
    end
  end
end
