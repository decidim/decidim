# frozen_string_literal: true

module Decidim
  # This helper includes some methods to help with generating short links within
  # the Decidim engine views.
  module ShortLinkHelper
    # A helper method to get a short URL in the current context where this
    # method is called from. This helper automatically fetches the "target" for
    # the short link, such as the component or the participatory process. This
    # also resolves the current mounted route name to make it possible to refer
    # to the same context when redirecting the short URL to correct full URL.
    #
    # Accepts keyword arguments such as:
    #   - `route_name`: the route name to link to
    #   - `params`: query parameters for the redirect
    #
    # @return [String] The short URL.
    def short_url(**)
      target = respond_to?(:current_component) && current_component
      target ||= respond_to?(:current_participatory_space) && current_participatory_space
      target ||= respond_to?(:current_organization) && current_organization
      target ||= Rails.application

      mounted_engine = target.try(:mounted_engine) || EngineResolver.new(_routes).mounted_name
      ShortLink.to(target, mounted_engine, **).short_url
    end
  end
end
