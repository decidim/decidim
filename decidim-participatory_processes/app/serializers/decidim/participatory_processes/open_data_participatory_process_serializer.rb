# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class serializes a ParticipatoryProcess so it can be exported to CSV for the Open Data feature.
    class OpenDataParticipatoryProcessSerializer < Decidim::Exporters::ParticipatorySpaceSerializer
      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        super.merge(
          {
            url: EngineRouter.main_proxy(resource).participatory_process_url(resource),
            subtitle: resource.subtitle,
            remote_hero_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.new(resource).hero_image_url,
            announcement: resource.announcement,
            start_date: resource.start_date,
            end_date: resource.end_date,
            developer_group: resource.developer_group,
            local_area: resource.local_area,
            meta_scope: resource.meta_scope,
            participatory_scope: resource.participatory_scope,
            participatory_structure: resource.participatory_structure,
            target: resource.target,
            area: {
              id: resource.area.try(:id),
              name: resource.area.try(:name) || empty_translatable
            },
            participatory_process_group: {
              id: resource.participatory_process_group.try(:id),
              title: resource.participatory_process_group.try(:title) || empty_translatable,
              description: resource.participatory_process_group.try(:description) || empty_translatable,
              remote_hero_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupPresenter.new(resource.participatory_process_group).hero_image_url
            },
            scope: {
              id: resource.scope.try(:id),
              name: resource.scope.try(:name) || empty_translatable
            },
            scopes_enabled: resource.scopes_enabled,
            participatory_process_type: {
              id: resource.participatory_process_type.try(:id),
              title: resource.participatory_process_type.try(:title) || empty_translatable
            }
          }
        )
      end
    end
  end
end
