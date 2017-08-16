# frozen_string_literal: true

module Decidim
  module Assemblies
    # This class infers the current assembly we're scoped to by
    # looking at the request parameters and the organization in the request
    # environment, and injects it into the environment.
    class CurrentAssembly
      # Public: Matches the request against an assembly and injects it
      #         into the environment.
      #
      # request - The request that holds the assembly relevant
      #           information.
      #
      # Returns a true if the request matched, false otherwise
      def matches?(request)
        env = request.env

        @organization = env["decidim.current_organization"]
        return false unless @organization

        current_assembly(env, request.params) ? true : false
      end

      private

      def current_assembly(env, params)
        env["decidim.current_participatory_space"] ||=
          detect_current_assembly(params)
      end

      def detect_current_assembly(params)
        OrganizationAssemblies.new(@organization).query.find_by_id(params["assembly_id"])
      end
    end
  end
end
