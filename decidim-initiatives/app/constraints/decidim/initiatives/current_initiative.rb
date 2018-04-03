# frozen_string_literal: true

module Decidim
  module Initiatives
    # This class infers the current initiative we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentInitiative
      include InitiativeSlug

      # Public: Matches the request against an initative and injects it
      #         into the environment.
      #
      # request - The request that holds the initiative relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_initiative(env, request.params) ? true : false
      end

      private

      def current_initiative(env, params)
        env["decidim.current_participatory_space"] ||= Initiative.find_by(id: id_from_slug(params[:initiative_slug]))
      end
    end
  end
end
