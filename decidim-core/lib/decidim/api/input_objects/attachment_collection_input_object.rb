# frozen_string_literal: true

module Decidim
  module Core
    class AttachmentCollectionInputObject < Decidim::Api::Types::BaseInputObject
      graphql_name "AttachmentCollectionInput"
      description "A type used for mapping attachments to collections"

      argument :id, GraphQL::Types::ID, "Maps the collection using its ID", required: false
      argument :key, GraphQL::Types::String, "Maps the collection using its key", required: false
      argument :slug, GraphQL::Types::String, "DEPRECATED: Use 'key' instead", required: false

      def prepare
        id = arguments[:id]
        key = arguments[:key].presence || arguments[:slug]

        raise GraphQL::ExecutionError, "Either id or key needs to be provided." if id.blank? && key.blank?
        raise GraphQL::ExecutionError, "Only one of id or key can be provided at a time." if id.present? && key.present?
        raise GraphQL::ExecutionError, "The key cannot be empty." if !key.nil? && key.empty?

        super
      end

      def id_value
        return arguments[:id].to_i if arguments[:id].present?

        key = arguments[:key].presence || arguments[:slug]
        raise GraphQL::ExecutionError, "The key cannot be empty." if key.blank?
        raise GraphQL::ExecutionError, "Outside of object context." if context[:current_object].blank?

        parent = context[:current_object].object
        raise GraphQL::ExecutionError, "Outside of record context." unless parent

        collection = parent.attachment_collections.find_by(key: key.strip)
        raise GraphQL::ExecutionError, "Key not found within the record's collections." unless collection

        collection.id
      end
    end
  end
end
