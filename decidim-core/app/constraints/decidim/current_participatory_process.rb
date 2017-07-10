# frozen_string_literal: true

module Decidim
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
      env["decidim.current_participatory_process"] ||=
        detect_current_participatory_process(params)
    end

    def detect_current_participatory_process(params)
      @organization.participatory_processes.find_by_id(params["participatory_process_id"])
    end
  end
end
