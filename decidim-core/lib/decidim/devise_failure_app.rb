# frozen_string_literal: true

module Decidim
  # We've provided a custom class in order to be able to deactivate the
  # script_name hack that doesn't seem to be affecting us (it is actually
  # introducing a bug).
  class DeviseFailureApp < ::Devise::FailureApp
    def scope_url
      opts = {}

      # Initialize script_name with nil to prevent infinite loops in
      # authenticated mounted engines in rails 4.2 and 5.0

      # The line below is what we commented LOL ^^
      # opts[:script_name] = nil

      route = route(scope)

      opts[:locale] = params[:locale] if params[:locale]
      opts[:format] = request_format unless skip_format?

      opts[:script_name] = relative_url_root if relative_url_root?

      router_name = ::Devise.mappings[scope].router_name || ::Devise.available_router_name
      context = send(router_name)

      if context.respond_to?(route)
        context.send(route, opts)
      elsif respond_to?(:root_url)
        root_url(opts)
      else
        "/"
      end
    end
  end
end
