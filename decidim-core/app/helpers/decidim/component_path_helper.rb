# frozen_string_literal: true

module Decidim
  # A helper to get the root path for a component.
  module ComponentPathHelper
    # Returns the defined root path for a given component.
    #
    # component - the Component we want to find the root path for.
    #
    # Returns a relative url.
    def main_component_path(component)
      current_params = try(:params) || {}
      EngineRouter.main_proxy(component).root_path(locale: current_params[:locale])
    end

    # Returns the defined root url for a given component.
    #
    # component - the Component we want to find the root path for.
    #
    # Returns an absolute url.
    def main_component_url(component)
      current_params = try(:params) || {}
      EngineRouter.main_proxy(component).root_url(locale: current_params[:locale])
    end

    # Returns the defined admin root path for a given component.
    #
    # component - the Component we want to find the root path for.
    #
    # Returns a relative url.
    def manage_component_path(component)
      current_params = try(:params) || {}
      EngineRouter.admin_proxy(component).root_path(locale: current_params[:locale])
    end
  end
end
