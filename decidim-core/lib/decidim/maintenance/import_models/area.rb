# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class Area < ApplicationRecord
        resource_models ["Decidim::Assembly", "Decidim::ParticipatoryProcess", "Decidim::Initiative", "Decidim::ActionLog"]
        participatory_space_models ["Decidim::Assembly", "Decidim::ParticipatoryProcess", "Decidim::Initiative"]

        self.table_name = "decidim_areas"
        belongs_to :area_type, class_name: "Decidim::Maintenance::ImportModels::AreaType", inverse_of: :areas, optional: true

        def self.root_taxonomy_name = "~ #{I18n.t("decidim.admin.titles.areas")}"

        def resources
          Area.resource_classes.each_with_object({}) do |klass, hash|
            items = klass.where(decidim_area_id: id)
            hash.merge!(items.to_h { |resource| [resource.to_global_id.to_s, resource_name(resource)] })
          end
        end

        def taxonomies
          {
            name:,
            origin: to_global_id.to_s,
            children: {},
            resources:
          }
        end

        def self.filter_item_for_space_manifest(space_manifest)
          items = all_in_org.map do |area|
            if area.area_type
              [
                area.area_type.name[I18n.locale.to_s],
                area.name[I18n.locale.to_s]
              ]
            else
              [area.name[I18n.locale.to_s]]
            end
          end

          {
            space_filter: true,
            space_manifest:,
            name: root_taxonomy_name,
            items:,
            components: []
          }
        end

        def self.plain_areas
          all_in_org.where(area_type_id: nil).to_h { |area| [area.name[I18n.locale.to_s], area.taxonomies] }
        end

        def self.areas_with_type
          AreaType.with(organization).all_in_org.to_h do |type|
            [
              type.plural[I18n.locale.to_s],
              {
                name: type.plural,
                origin: type.to_global_id.to_s,
                children: type.areas.to_h { |area| [area.name[I18n.locale.to_s], area.taxonomies] },
                resources: {}
              }
            ]
          end
        end

        def self.all_taxonomies
          plain_areas.merge(areas_with_type)
        end

        def self.all_filters
          Area.participatory_space_classes.each_with_object([]) do |space_class, hash|
            space_manifest = space_class.to_s.split("::").last.underscore.pluralize
            # 1 filter per participatory space as space_filter=true
            hash << filter_item_for_space_manifest(space_manifest)
          end
        end
      end
    end
  end
end
