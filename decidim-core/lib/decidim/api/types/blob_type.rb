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
      field :src, GraphQL::Types::String, "The url of this blob", null: false

      def src
        asset_routes.rails_blob_url(object, **default_url_options)
      end

      def self.authorized?(object, context)
        super && context[:current_user]&.admin?
      end

      private

      def asset_routes
        @asset_routes ||=
          if default_url_options.present?
            Rails.application.routes.url_helpers
          else
            EngineRouter.new("main_app", {})
          end
      end

      def default_url_options
        @default_url_options ||= remote_storage_options.presence || url_option_resolver.options.tap do |opts|
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
          host: Rails.application.secrets.dig(:storage, :cdn_host)
        }.compact
      end
    end
  end
end
