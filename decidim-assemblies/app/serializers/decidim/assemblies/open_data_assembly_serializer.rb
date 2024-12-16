# frozen_string_literal: true

module Decidim
  module Assemblies
    # This class serializes an Assembly so it can be exported to CSV for the Open Data feature.
    class OpenDataAssemblySerializer < Decidim::Exporters::ParticipatorySpaceSerializer
      # Public: Exports a hash with the serialized data for this assembly.
      #
      def serialize
        super.merge(
          {
            url: EngineRouter.main_proxy(resource).assembly_url(resource),
            subtitle: resource.subtitle,
            remote_hero_image_url: Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.new(resource).hero_image_url,
            remote_banner_image_url: Decidim::Assemblies::AssemblyPresenter.new(resource).banner_image_url,
            announcement: resource.announcement,
            developer_group: resource.developer_group,
            local_area: resource.local_area,
            meta_scope: resource.meta_scope,
            participatory_scope: resource.participatory_scope,
            purpose_of_action: resource.purpose_of_action,
            composition: resource.composition,
            duration: resource.duration,
            participatory_structure: resource.participatory_structure,
            target: resource.target,
            decidim_scope_id: resource.decidim_scope_id,
            area: {
              id: resource.area.try(:id),
              name: resource.area.try(:name) || empty_translatable
            },
            scope: {
              id: resource.scope.try(:id),
              name: resource.scope.try(:name) || empty_translatable
            },
            scopes_enabled: resource.scopes_enabled,
            included_at: resource.included_at,
            closing_date: resource.closing_date,
            created_by: resource.created_by,
            creation_date: resource.creation_date,
            closing_date_reason: resource.closing_date_reason,
            internal_organisation: resource.internal_organisation,
            is_transparent: resource.is_transparent,
            special_features: resource.special_features,
            twitter_handler: resource.twitter_handler,
            instagram_handler: resource.instagram_handler,
            facebook_handler: resource.facebook_handler,
            youtube_handler: resource.youtube_handler,
            github_handler: resource.github_handler,
            created_by_other: resource.created_by_other,
            assembly_type: {
              id: resource.assembly_type.try(:id),
              title: resource.assembly_type.try(:title) || empty_translatable
            }
          }
        )
      end
    end
  end
end
