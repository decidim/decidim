# frozen_string_literal: true

module Decidim
  module Conferences
    # This class infers the current conference we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentConference
      # Public: Matches the request against an conference and injects it
      #         into the environment.
      #
      # request - The request that holds the conference relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_conference(env, request.params) ? true : false
      end

      private

      def current_conference(env, params)
        env["decidim.current_participatory_space"] ||=
          detect_current_conference(params)
      end

      def detect_current_conference(params)
        organization_conferences.where(slug: params["conference_slug"]).or(
          organization_conferences.where(id: params["conference_slug"])
        ).first!
      end

      def organization_conferences
        @organization_conferences ||= OrganizationConferences.new(@organization).query
      end
    end
  end
end
