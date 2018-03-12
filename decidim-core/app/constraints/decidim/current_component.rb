# frozen_string_literal: true

module Decidim
  # This class infers the current component we're scoped to by looking at the
  # request parameters and injects it into the environment.
  class CurrentComponent
    # Public: Initializes the class.
    #
    # manifest - The manifest of the component to check against.
    def initialize(manifest)
      @manifest = manifest
    end

    # Public: Matches the request against a component and injects it into the
    #         environment.
    #
    # request - The request that holds the current component relevant information.
    #
    # Returns a true if the request matched, false otherwise
    def matches?(request)
      env = request.env

      @participatory_space = env["decidim.current_participatory_space"]
      return false unless @participatory_space

      current_component(env, request.params) ? true : false
    end

    private

    def current_component(env, params)
      env["decidim.current_component"] ||= detect_current_component(params)
    end

    def detect_current_component(params)
      @participatory_space.components.find do |component|
        params["component_id"] == component.id.to_s && component.manifest_name == @manifest.name.to_s
      end
    end
  end
end
