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
    # @option kwargs [Boolean] :route_name the route name to which the short
    #   link should link to
    # @option kwargs [Float] :params the URL query parameters that should be
    #   included in the URL where the short link redirects to
    # @return [String] The short URL
    def short_url(**kwargs)
      target = respond_to?(:current_component) && current_component
      target ||= respond_to?(:current_participatory_space) && current_participatory_space
      target ||= respond_to?(:current_organization) && current_organization
      target ||= Rails.application

      mounted_engine = EngineResolver.new(_routes).mounted_name
      ShortLink.to(target, mounted_engine, **kwargs).short_url
    end
  end
end
