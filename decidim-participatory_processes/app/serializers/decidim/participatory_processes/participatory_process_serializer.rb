# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class serializes a ParticipatoryProcesses so can be exported to CSV, JSON or other
    # formats.
    class ParticipatoryProcessSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a participatory_process.
      def initialize(participatory_process)
        @participatory_process = participatory_process
      end

      # Public: Exports a hash with the serialized data for this participatory_process.
      def serialize
        {
          id: participatory_process.id,
          title: participatory_process.title,
          subtitle: participatory_process.subtitle,
          slug: participatory_process.slug,
          hashtag: participatory_process.hashtag,
          short_description: participatory_process.short_description,
          description: participatory_process.description,
          announcement: participatory_process.announcement,
          start_date: participatory_process.start_date,
          end_date: participatory_process.end_date,
          remote_hero_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.new(participatory_process).hero_image_url,
          remote_banner_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.new(participatory_process).banner_image_url,
          developer_group: participatory_process.developer_group,
          local_area: participatory_process.local_area,
          meta_scope: participatory_process.meta_scope,
          participatory_scope: participatory_process.participatory_scope,
          participatory_structure: participatory_process.participatory_structure,
          target: participatory_process.target,
          area: {
            id: participatory_process.area.try(:id),
            name: participatory_process.area.try(:name) || empty_translatable
          },
          participatory_process_group: {
            id: participatory_process.participatory_process_group.try(:id),
            title: participatory_process.participatory_process_group.try(:title) || empty_translatable,
            description: participatory_process.participatory_process_group.try(:description) || empty_translatable,
            remote_hero_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupPresenter.new(participatory_process.participatory_process_group).hero_image_url
          },
          scope: {
            id: participatory_process.scope.try(:id),
            name: participatory_process.scope.try(:name) || empty_translatable
          },
          private_space: participatory_process.private_space,
          promoted: participatory_process.promoted,
          scopes_enabled: participatory_process.scopes_enabled,
          show_metrics: participatory_process.show_metrics,
          show_statistics: participatory_process.show_statistics,
          participatory_process_steps: serialize_participatory_process_steps,
          participatory_process_categories: serialize_categories,
          attachments: {
            attachment_collections: serialize_attachment_collections,
            files: serialize_attachments
          },
          components: serialize_components
        }
      end

      private

      attr_reader :participatory_process

      def serialize_participatory_process_steps
        return unless participatory_process.steps.any?

        participatory_process.steps.map do |step|
          {
            id: step.try(:id),
            title: step.try(:title),
            description: step.try(:description),
            start_date: step.try(:start_date),
            end_date: step.try(:end_date),
            cta_path: step.try(:cta_path),
            cta_text: step.try(:cta_text),
            active: step.active,
            position: step.position
          }
        end
      end

      def serialize_categories
        return unless participatory_process.categories.first_class.any?

        participatory_process.categories.first_class.map do |category|
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
        return unless participatory_process.attachment_collections.any?

        participatory_process.attachment_collections.map do |collection|
          {
            id: collection.try(:id),
            name: collection.try(:name),
            weight: collection.try(:weight),
            description: collection.try(:description)
          }
        end
      end

      def serialize_attachments
        return unless participatory_process.attachments.any?

        participatory_process.attachments.map do |attachment|
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
        serializer = Decidim::Exporters::ParticipatorySpaceComponentsSerializer.new(@participatory_process)
        serializer.serialize
      end
    end
  end
end
