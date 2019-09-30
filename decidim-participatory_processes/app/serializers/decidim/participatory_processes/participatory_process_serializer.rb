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
          #hero_image: participatory_process.hero_image.url,
          #banner_image: participatory_process.banner_image.url,
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
          participatory_process_group:{
            id: participatory_process.participatory_process_group.try(:id),
            name: participatory_process.participatory_process_group.try(:name) || empty_translatable,
            description: participatory_process.participatory_process_group.try(:description) || empty_translatable,
            # image: participatory_process.participatory_process_group.image.url
          },
          scope: {
            id: participatory_process.scope.try(:id),
            name: participatory_process.scope.try(:name) || empty_translatable
          },
          private_space: participatory_process.private_space,
          promoted: participatory_process.promoted,
          scopes_enabled: participatory_process.scopes_enabled,
          show_statistics: participatory_process.show_statistics,
        }
      end

      private

      attr_reader :participatory_process

    end
  end
end
