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
        @blob =
          case asset
          when ActiveStorage::Blob
            asset
          else
            asset&.blob
          end
      end

      # Generates the correct URL to the asset with the provided options.
      #
      # @param options The options for the URL that are the normal route options
      #   Rails route helpers accept
      # @return [String] The URL of the asset
      def url(**)
        case asset
        when ActiveStorage::Attached
          ensure_current_host(asset.record, **)
          blob_url(**)
        when ActiveStorage::Blob
          blob_url(**)
        else # ActiveStorage::VariantWithRecord, ActiveStorage::Variant
          if blob && blob.attachments.any?
            ensure_current_host(blob.attachments.first&.record, **)
            representation_url(**)
          else
            ensure_current_host(nil, **)
            representation_url(**, only_path: true)
          end
        end
      end

      private

      attr_reader :asset, :blob

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
        @remote_storage_options ||= { host: Decidim.storage_cdn_host }.compact_blank
      end

      # Most of the times the current host should be set through the controller
      # already when the logic below is unnecessary. This logic is needed e.g.
      # for serializers where the request context is not available.
      #
      # @param record The record for which to check the organization
      # @param opts Options for building the URL
      # @return [void]
      def ensure_current_host(record, **opts)
        return if asset_url_available?

        options = remote? ? remote_storage_options : routes.default_url_options
        options = options.merge(opts)

        if opts[:host].blank? && record.present?
          organization = organization_for(record)
          options[:host] = organization.host if organization
        end

        uri =
          if options[:protocol] == "https" || options[:scheme] == "https"
            URI::HTTPS.build(options)
          else
            URI::HTTP.build(options)
          end

        ActiveStorage::Current.url_options = { host: uri.to_s }
      end

      # Determines the organization for the passed record.
      #
      # @param record The record for which to fetch the organization
      # @return [Decidim::Organization, nil] The organization for the record or
      #   `nil` if the organization cannot be determined
      def organization_for(record)
        if record.is_a?(Decidim::Organization)
          record
        elsif record.respond_to?(:organization)
          record.organization
        end
      end

      # Returns the URL for the given blob object.
      #
      # @param blob The blob object
      # @param options Options for building the URL
      # @return [String, nil] The URL to the blob object or `nil` if the blob is
      #   not defined.
      def blob_url(**options)
        return unless blob

        if options[:only_path] || remote? || !asset_url_available?
          routes.rails_blob_url(blob, **default_options, **options)
        else
          blob.url(**options)
        end
      end

      # Returns a representation URL for the asset either directly through the
      # storage service or through the Rails representation URL in case the
      # path URL is requested or if the asset variant has not been processed yet
      # and is not therefore yet stored at the storage service.
      #
      # @return [String] The representation URL for the image variant
      def representation_url(**options)
        return rails_representation_url(**options) if options[:only_path] || remote?

        representation_url = variant_url(**options)
        return representation_url if representation_url.present?

        # In case the representation has not been processed yet, it may not have
        # a representation URL yet and it therefore needs to be served through
        # the local representation URL for the first time (or until it has been
        # processed).
        if options[:host]
          rails_representation_url(**options)
        else
          representation_url(**options, only_path: true)
        end
      end

      # Returns the local Rails representation URL meaning that the asset will
      # be served through the service itself. This may be necessary if the asset
      # variant (e.g. a thumbnail) has not been processed yet because the
      # variant representation has not been requested before.
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
      # @param options The options for building the URL
      # @return [String, nil] The converted representation URL or `nil` if the
      #   asset is not defined.
      def rails_representation_url(**)
        return unless asset

        representation_url = routes.rails_representation_url(asset, **default_options, **)

        variation = asset.try(:variation)
        return representation_url unless variation

        format = variation.try(:format)
        return representation_url unless format
        return unless blob

        original_ext = File.extname(blob.filename.to_s)
        return representation_url if original_ext == ".#{format}"

        basename = File.basename(blob.filename.to_s, original_ext)
        representation_url.sub(/#{basename}\.#{original_ext.tr(".", "")}$/, "#{basename}.#{format}")
      end

      # Fetches the image variant's URL at the storage service if the variant
      # has already been processed and is stored at the storage service. If the
      # variant has not been processed yet, returns `nil` in which case the
      # variant has to be served through the service's own representation URL
      # causing it to be processed and stored at the storage service.
      #
      # @param options The options for building the URL
      # @return [String, nil] The variant URL at the storage service or `nil` if
      #   the variant has not been processed yet and does not yet exist at the
      #   storage service or `nil` when the asset is not defined
      def variant_url(**options)
        return unless asset
        return unless asset_url_available?
        return unless asset_exist?

        case asset
        when ActiveStorage::VariantWithRecord
          # This is used when `ActiveStorage.track_variants` is enabled through
          # `config.active_storage.track_variants`. In case the variant has not
          # been processed yet, the `#url` method would return nil.
          #
          # Note that if the `asset.processed?` returns `true`, the variant
          # record has been created in the database but it does not mean that
          # it has been uploaded to the storage service yet. Likely a bug in
          # ActiveStorage but to be sure that the asset is uploaded to the
          # storage service, we also check that.
          asset.url(**options) if asset.processed?
        else # ActiveStorage::Variant
          # Check whether the variant exists at the storage service before
          # returning its URL. Otherwise the URL would be returned even when the
          # variant is not yet processed causing 404 errors for the images on
          # the page.
          #
          # Note that the `ActiveStorage::Variant#url` method only accepts
          # certain keyword arguments where as the other objects allow any
          # keyword arguments.
          possible_kwargs = asset.method(:url).parameters.select { |p| p[0] == :key }.map { |p| p[1] }
          asset.url(**options.slice(*possible_kwargs))
        end
      end

      # Determines if the asset exists at the storage service.
      #
      # @return [Boolean] A boolean answering the question "does this asset
      # exist at the storage service?".
      def asset_exist?
        return false if asset.key.blank?

        blob.service.exist?(asset.key)
      end

      # Determines if the current host is required to build the asset URL.
      #
      # @return [Boolean] A boolean indicating if the current host is required
      #   to build the asset URL.
      def current_host_required?
        return false unless blob
        return false unless defined?(ActiveStorage::Service::DiskService)

        blob.service.is_a?(ActiveStorage::Service::DiskService)
      end

      # Determines if the asset URL can be generated.
      #
      # @return [Boolean] A boolean indicating if the asset URL can be
      #   generated.
      def asset_url_available?
        # If the service is an external service, the URL can be generated
        # regardless of the current host being set.
        return true unless current_host_required?

        # For the disk service, the URL can be only generated if the current
        # host has been set.
        ActiveStorage::Current.url_options&.dig(:host).present?
      end
    end
  end
end
