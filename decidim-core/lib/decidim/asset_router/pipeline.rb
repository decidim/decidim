# frozen_string_literal: true

module Decidim
  module AssetRouter
    # The pipeline asset router provides global access to the asset routers for
    # assets that are precompiled through the Rails assets pipeline (or webpack)
    # and stored locally or in a remote CDN. This handles the configuration
    # options for the asset routes so that they don't have to be always manually
    # created.
    class Pipeline
      # Initializes the router.
      #
      # @param asset [String] The asset to route to
      # @param model [ActiveRecord::Base, nil] The model that provides the
      #   organizational context. When nil, the host will be included in the URL
      #   when it is available through other configurations. Otherwise, the host
      #   will not be part of the URL.
      def initialize(asset, model: nil)
        @asset = asset
        @model = model
      end

      # Generates the correct URL to the asset with the provided options.
      #
      # @param options [Hash] The options for the URL that are the normal route
      #   options Rails route helpers accept
      # @return [String] The full URL to the asset or when host cannot be
      #   resolved, the asset path.
      def url(**options)
        path = ActionController::Base.helpers.asset_pack_path(asset, **options)
        "#{asset_host}#{path}"
      end

      private

      attr_reader :asset, :model

      # Fetches the organization from the model or returns the model itself if
      # it is an organization.
      #
      # @return [Decidim::Organization]
      def organization
        @organization ||=
          if model.is_a?(Decidim::Organization)
            model
          else
            model.try(:organization)
          end
      end

      # Resolves the full asset host with the resolved options and also adds the
      # port at the end of the URL unless it is the default port 80 or 443.
      #
      # @return [String] The hostname with protocol and port or an empty string
      #   when the host cannot be resolved.
      def asset_host
        return "" if default_options[:host].blank?

        base_host = ActionController::Base.helpers.compute_asset_host("", **default_options)
        return "" if base_host.blank?
        return base_host if option_resolver.default_port?

        "#{base_host}:#{option_resolver.port}"
      end

      # Determines the default options to be passed to the route helper.
      #
      # @return [Hash] The default options hash to pass to the route helper
      def default_options
        @default_options ||= option_resolver.options.tap do |opts|
          opts[:host] = default_host if default_host
        end
      end

      # Determines the default host for the pipeline assets. Either the
      # configured assets host or the organization host when available. When the
      # default host is not available, the host returned by the
      # UrlOptionResolver will be used.
      #
      # @return [String, nil]
      def default_host
        @default_host ||= Rails.configuration.action_controller.asset_host || organization&.host
      end

      # Stores an instance of UrlOptionResolver for convenience.
      #
      # @return [Decidim::UrlOptionResolver]
      def option_resolver
        @option_resolver ||= UrlOptionResolver.new
      end
    end
  end
end
