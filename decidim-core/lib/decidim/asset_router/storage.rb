# frozen_string_literal: true

module Decidim
  module AssetRouter
    # Storage asset router provides global access to the asset routes for assets
    # saved through ActiveStorage. This handles the different cases for routing
    # to the remote routes when using an assets CDN or to local routes when
    # using the local disk storage driver.
    #
    # Note that when the assets are stored in a remote storage service, such as
    # Amazon S3, Google Cloud Storage or Azure Storage, this generates the asset
    # URL directly to the storage service itself bypassing the Rails server and
    # saving CPU time from serving the asset redirect requests. This causes a
    # significant performance improvement on pages that display a lot of images.
    # It will also produce a less significant performance improvement when using
    # the local disk storage because in this situation, the images are served
    # using one request instead of two when served directly from the storage
    # service rather than through the asset redirect URL.
    #
    # When implementing changes to the logic, please keep the remote storage
    # options and performance implications in mind because the specs for this
    # utility do not cover the remote storage options because the extra
    # configuration needed to test, the service itself needed for testing and
    # the extra dependency overhead for adding these remote storage gems when
    # they are not needed.
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
      def url(**)
        case asset
        when ActiveStorage::Attached
          blob_url(asset.blob, **)
        when ActiveStorage::Blob
          blob_url(asset, **)
        else # ActiveStorage::VariantWithRecord, ActiveStorage::Variant
          representation_url(**)
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

      def blob_url(blob, **options)
        if options[:only_path] || remote?
          routes.rails_blob_url(blob, **default_options.merge(options))
        else
          blob.url(**options)
        end
      end

      # Returns a representation URL for the asset either directly through the
      # storage service or through the Rails representation URL in case the
      # path URL is requested or if the asset variant hasn't been processed yet
      # and is not therefore yet stored at the storage service.
      #
      # @return [String] The representation URL for the image variant
      def representation_url(**options)
        return rails_representation_url(**options) if options[:only_path] || remote?

        representation_url = variant_url(**options)
        return representation_url if representation_url.present?

        # In case the representation hasn't been processed yet, it may not have
        # a representation URL yet and it therefore needs to be served through
        # the local representation URL for the first time (or until it has been
        # processed).
        representation_url(**options.merge(only_path: true))
      end

      # Returns the local Rails representation URL meaning that the asset will
      # be served through the service itself. This may be necessary if the asset
      # variant (e.g. a thumbnail) hasn't been processed yet because the variant
      # representation hasn't been requested before.
      #
      # Due to performance reasons it is advised to avoid requesting the assets
      # through the Rails representation URLs when possible because that causes
      # a lot of requests to the Rails backend and slowness to the service under
      # heavy loads.
      #
      # Converts the variation URLs last part to the correct file extension in
      # case the variation has a different format than the original image. The
      # conversion needs to be only done for the Rails representation URLs
      # because once the image is stored at the storage service, it already has
      # the correct file extension.
      #
      # @return [String] The converted representation URL
      def rails_representation_url(**options)
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

      # Fetches the image variant's URL at the storage service if the variant
      # has already been processed and is stored at the storage service. If the
      # variant hasn't been processed yet, returns `nil` in which case the
      # variant has to be served through the service's own representation URL
      # causing it to be processed and stored at the storage service.
      #
      # @return [String, nil] The variant URL at the storage service or `nil` if
      #   the variant hasn't been processed yet and does not yet exist at the
      #   storage service
      def variant_url(**)
        case asset
        when ActiveStorage::VariantWithRecord
          # This is used when `ActiveStorage.track_variants` is enabled through
          # `config.active_storage.track_variants`. In case the variant hasn't
          # been processed yet, the `#url` method would return nil.
          asset.url(**) if asset.processed?
        else # ActiveStorage::Variant
          # Check whether the variant exists at the storage service before
          # returning its URL. Otherwise the URL would be returned even when the
          # variant is not yet processed causing 404 errors for the images on
          # the page.
          asset.url(**) if asset.service.exist?(asset.key)
        end
      end
    end
  end
end
