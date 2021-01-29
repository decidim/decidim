# frozen_string_literal: true

module Decidim
  module Votings
    # This class infers the current voting we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentVoting
      # Public: Matches the request against an voting and injects it
      #         into the environment.
      #
      # request - The request that holds the voting relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_voting(env, request.params).present?
      end

      private

      def current_voting(env, params)
        env["decidim.current_participatory_space"] ||=
          detect_current_voting(params)
      end

      def detect_current_voting(params)
        organization_votings.where(slug: params["voting_slug"]).or(
          organization_votings.where(id: params["voting_slug"])
        ).first!
      end

      def organization_votings
        @organization_votings ||= OrganizationVotings.new(@organization).query
      end
    end
  end
end
