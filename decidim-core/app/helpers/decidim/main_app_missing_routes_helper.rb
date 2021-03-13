# frozen_string_literal: true

module Decidim
  # A helper to get paths from main_app routes if cannot be found in the
  # current engine
  module MainAppMissingRoutesHelper
    def method_missing(method_name, *args, &block)
      super unless route_helper?(method_name) && main_app.respond_to?(method_name)

      main_app.send(method_name, *args)
    end

    def respond_to_missing?(method_name, include_private = false)
      route_helper?(method_name) || super
    end

    def route_helper?(method_name)
      method_name.to_s.match?(/_(url|path)$/)
    end
  end
end
