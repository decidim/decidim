# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class infers the current participatory process we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentParticipatoryProcess
      # Public: Matches the request against a participatory process and injects it
      #         into the environment.
      #
      # request - The request that holds the participatory process relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_participatory_process(env, request.params) ? true : false
      end

      private

      def current_participatory_process(env, params)
        env["decidim.current_participatory_space"] ||=
          detect_current_participatory_process(params)
      end

      def detect_current_participatory_process(params)
        organization_processes.where(slug: params["participatory_process_slug"]).or(
          organization_processes.where(id: params["participatory_process_slug"])
        ).first!
      end

      def organization_processes
        @organization_processes ||= OrganizationParticipatoryProcesses.new(@organization).query
      end
    end
  end
end
