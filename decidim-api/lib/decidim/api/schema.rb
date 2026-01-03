# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    class Schema < GraphQL::Schema
      mutation(MutationType)
      query(QueryType)

      default_max_page_size Decidim::Api.schema_max_per_page
      max_depth Decidim::Api.schema_max_depth
      max_complexity Decidim::Api.schema_max_complexity

      query_analyzer AliasAnalyzer

      orphan_types(Api.orphan_types)

      def self.unauthorized_object(error)
        # Add a top-level error to the response instead of returning nil:
        raise Decidim::Api::Errors::UnauthorizedObjectError, I18n.t("decidim.api.errors.unauthorized_object", type: error.type.graphql_name)
      end

      def self.unauthorized_field(error)
        # Add a top-level error to the response instead of returning nil:
        raise Decidim::Api::Errors::UnauthorizedFieldError, I18n.t("decidim.api.errors.unauthorized_field", type: error.type.graphql_name, field: error.field.graphql_name)
      end

      rescue_from(ActiveRecord::RecordNotFound) do |_err, _obj, _args, _ctx, field|
        raise Decidim::Api::Errors::NotFoundError, I18n.t("decidim.api.errors.not_found", type: field.type.unwrap.graphql_name)
      end

      rescue_from(Decidim::PermissionAction::PermissionNotSetError) do |_err, _obj, _args, _ctx, field|
        raise Decidim::Api::Errors::PermissionNotSetError, I18n.t("decidim.api.errors.permission_not_set", type: field.type.unwrap.graphql_name)
      end

      rescue_from(I18n::InvalidLocale) do |_err, _obj, _args, _ctx, _field|
        raise Decidim::Api::Errors::InvalidLocaleError, I18n.t("decidim.api.errors.invalid_locale")
      end

      rescue_from(I18n::ArgumentError) do |err, _obj, _args, _ctx, _field|
        raise Decidim::Api::Errors::LocaleError, I18n.t("decidim.api.errors.locale_argument_error", message: err.message)
      end
    end
  end
end
