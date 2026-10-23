# frozen_string_literal: true

module Decidim
  module Core
    class BlobType < Decidim::Api::Types::BaseObject
      description "A file blob"

      field :byte_size, GraphQL::Types::Int, "The byte size of this blob", null: false
      field :checksum, GraphQL::Types::String, "The checksum of this blob", null: false
      field :content_type, GraphQL::Types::String, "The content type of this blob", null: false
      field :created_at, Decidim::Core::DateTimeType, "When this blob was created", null: true
      field :filename, GraphQL::Types::String, "The filename of this blob", null: false
      field :id, GraphQL::Types::ID, "The id of this blob", null: false
      field :key, GraphQL::Types::String, "The key of this blob", null: false
      field :metadata, GraphQL::Types::JSON, "The metadata type of this blob", null: false
      field :service_name, GraphQL::Types::String, "The service name of this blob (where the blob is stored at)", null: false
      field :signed_id, GraphQL::Types::String, "The signed id of this blob", null: false
      field :src, GraphQL::Types::String, "The url of this blob. Files requiring a private download return the url of the endpoint that authorizes every request", null: false

      def src
        attachment = private_download_attachment
        return private_download_url(attachment) if attachment

        asset_routes.rails_blob_url(object, **default_url_options)
      end

      def self.authorized?(object, context)
        super && context[:current_user]&.admin?
      end

      private

      # Direct Active Storage urls are bearer credentials: anybody holding one
      # can download the file without any further authorization check. Files
      # that require a private download must always be served through the
      # private downloads controller, which authorizes every request.
      def private_download_attachment
        @private_download_attachment ||= object.attachments.find do |attachment|
          record = attachment.record
          record.respond_to?(:private_download_required?) && record.private_download_required?
        end
      end

      # Returned as an absolute url so external API clients can use it
      # directly. Private downloads are served by the application itself,
      # never by the storage CDN host, so the organization host is always used.
      def private_download_url(attachment)
        Decidim::Core::Engine.routes.url_helpers.private_download_url(
          Decidim::PrivateDownload.for(attachment.record, attachment_name: attachment.name).token,
          **app_url_options
        )
      end

      def asset_routes
        @asset_routes ||=
          if default_url_options.present?
            Rails.application.routes.url_helpers
          else
            EngineRouter.new("main_app", {})
          end
      end

      def default_url_options
        @default_url_options ||= remote_storage_options.presence || app_url_options
      end

      def app_url_options
        @app_url_options ||= url_option_resolver.options.tap do |opts|
          opts[:host] = default_host if default_host
        end
      end

      def default_host
        @default_host ||= context[:current_organization]&.host
      end

      def url_option_resolver
        @url_option_resolver ||= UrlOptionResolver.new
      end

      def remote_storage_options
        @remote_storage_options ||= {
          host: Rails.application.credentials.dig(:storage, :cdn_host)
        }.compact
      end
    end
  end
end
