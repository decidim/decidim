# frozen_string_literal: true

module Decidim
  module AssetRouter
    # Storage asset router provides global access to the asset routes for assets
    # saved through ActiveStorage. This handles the different cases for routing
    # to the remote routes when using an assets CDN or to local routes when
    # using the local disk storage driver.
    class Storage
      # Initializes the router.
      #
      # @param [ActiveStorage::Attached, ActiveStorage::Blob] The asset to route
      #   to
      def initialize(asset)
        @asset = asset
      end

      # Generates the correct URL to the asset with the provided options.
      #
      # @param options The options for the URL that are the normal route options
      #   Rails route helpers accept
      def url(**options)
        if asset.is_a? ActiveStorage::Attached
          routes.rails_blob_url(asset.blob, **default_options.merge(options))
        else
          representation_url(**options)
        end
      end

      private

      attr_reader :asset

      # Provides the route helpers depending on whether the URL is generated to
      # the local host or an external CDN (remote).
      #
      # @return [Module, Decidim::EngineRouter] The correct route helpers based
      #   on the configuration
      def routes
        @routes ||=
          if remote?
            Rails.application.routes.url_helpers
          else
            EngineRouter.new("main_app", {})
          end
      end

      # Determines whether the assets call should be to a remote CDN or to the
      # local server based on the storage options.
      #
      # @return [Boolean] A boolean indicating whether the assets are served
      #   through a remote CDN
      def remote?
        remote_storage_options.present?
      end

      # Determines the default options to be passed to the route helper. For the
      # remote storage, returns the remote storage options and for the local
      # disk storage returns an empty hash.
      #
      # @return [Hash] The default options hash to pass to the route helper
      def default_options
        @default_options ||=
          if remote?
            remote_storage_options
          else
            {}
          end
      end

      # The remote storage options when using a remote CDN. An empty hash in
      # case using the local disk storage.
      #
      # @return [Hash] The remote storage options hash
      def remote_storage_options
        @remote_storage_options ||= {
          host: Rails.application.secrets.dig(:storage, :cdn_host)
        }.compact
      end

      # Converts the variation URLs last part to the correct file extension in
      # case the variation has a different format than the original image.
      #
      # @return [String] The converted representation URL
      def representation_url(**options)
        representation_url = routes.rails_representation_url(asset, **default_options.merge(options))
        variation = asset.try(:variation)
        return representation_url unless variation

        format = variation.try(:format)
        return representation_url unless format

        original_ext = File.extname(asset.blob.filename.to_s)
        return representation_url if original_ext == ".#{format}"

        basename = File.basename(asset.blob.filename.to_s, original_ext)
        representation_url.sub(/#{basename}\.#{original_ext.tr(".", "")}$/, "#{basename}.#{format}")
      end
    end
  end
end
