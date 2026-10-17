# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentCollectionInputObject < Decidim::Api::Types::BaseInputObject
      graphql_name "AttachmentCollectionInput"
      description "A type used for mapping attachments to collections"

      argument :id, GraphQL::Types::ID, "Maps the collection using its ID", required: false
      argument :key, GraphQL::Types::String, "Maps the collection using its key", required: false

      def prepare
        id = arguments[:id]
        key = arguments[:key]

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.needs_key_or_id") if id.blank? && key.blank?
        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.needs_key_or_id_once") if id.present? && key.present?
        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.empty_key") if !key.nil? && key.empty?

        super
      end

      def id_value
        return arguments[:id].to_i if arguments[:id].present?

        key = arguments[:key]
        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.empty_key") if key.blank?
        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.outside_object_context") if context[:current_object].blank?

        parent = context[:current_object].object
        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.specific.outside_record_context") unless parent

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.attachment_collections.not_supported") unless parent.respond_to?(:attachment_collections)

        collection = parent.attachment_collections.find_by(key: key.strip)
        raise Decidim::Api::Errors::NotFoundError, I18n.t("decidim.api.errors.attachment_collections.not_found") unless collection

        collection.id
      end
    end
  end
end
