# frozen_string_literal: true

module Decidim
  module Exporters
    # This class serves as the base class for the serializers that export
    # participatory spaces.
    class ParticipatorySpaceSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a resource
      def initialize(resource)
        @resource = resource
      end

      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        {
          id: resource.id,
          title: resource.title,
          slug: resource.slug,
          reference: resource.reference,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          published_at: resource.published_at,
          follows_count: resource.follows_count,
          short_description: resource.short_description,
          description: resource.description,
          promoted: resource.promoted
        }
      end

      private

      attr_reader :resource

      def serialize_categories
        return unless resource.categories.first_class.any?

        resource.categories.first_class.map do |category|
          {
            id: category.try(:id),
            name: category.try(:name),
            description: category.try(:description),
            parent_id: category.try(:parent_id),
            subcategories: serialize_subcategories(category.subcategories)
          }
        end
      end

      def serialize_subcategories(subcategories)
        return unless subcategories.any?

        subcategories.map do |subcategory|
          {
            id: subcategory.try(:id),
            name: subcategory.try(:name),
            description: subcategory.try(:description),
            parent_id: subcategory.try(:parent_id)
          }
        end
      end

      def serialize_attachment_collections
        return unless resource.attachment_collections.any?

        resource.attachment_collections.map do |collection|
          {
            id: collection.try(:id),
            name: collection.try(:name),
            weight: collection.try(:weight),
            description: collection.try(:description)
          }
        end
      end

      def serialize_attachments
        return unless resource.attachments.any?

        resource.attachments.map do |attachment|
          {
            id: attachment.try(:id),
            title: attachment.try(:title),
            weight: attachment.try(:weight),
            description: attachment.try(:description),
            attachment_collection: {
              name: attachment.attachment_collection.try(:name),
              weight: attachment.attachment_collection.try(:weight),
              description: attachment.attachment_collection.try(:description)
            },
            remote_file_url: Decidim::AttachmentPresenter.new(attachment).attachment_file_url
          }
        end
      end

      def serialize_components
        serializer = Decidim::Exporters::ParticipatorySpaceComponentsSerializer.new(resource)
        serializer.run
      end
    end
  end
end
