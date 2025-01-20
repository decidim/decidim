# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class Scope < ApplicationRecord
        resource_models [
          "Decidim::Assembly", "Decidim::ParticipatoryProcess", "Decidim::Conference", "Decidim::InitiativesTypeScope",
          "Decidim::ActionLog",
          "Decidim::Accountability::Result",
          "Decidim::Budgets::Budget", "Decidim::Budgets::Project",
          "Decidim::Debates::Debate",
          "Decidim::Meetings::Meeting",
          "Decidim::Proposals::CollaborativeDraft", "Decidim::Proposals::Proposal"
        ]
        participatory_space_models ["Decidim::Assembly", "Decidim::ParticipatoryProcess", "Decidim::Conference", "Decidim::Initiative"]

        self.table_name = "decidim_scopes"

        def self.root_taxonomy_name = "~ #{I18n.t("decidim.admin.titles.scopes")}"

        belongs_to :parent,
                   class_name: "Decidim::Maintenance::ImportModels::Scope",
                   inverse_of: :children,
                   optional: true

        has_many :children,
                 foreign_key: "parent_id",
                 class_name: "Decidim::Maintenance::ImportModels::Scope",
                 inverse_of: :parent

        attr_writer :full_name

        def full_name
          return @full_name if defined?(@full_name)

          @full_name ||= name.dup
          @full_name[I18n.locale.to_s] = "#{parent.full_name[I18n.locale.to_s]} > #{@full_name[I18n.locale.to_s]}" if parent_ids.count > 2
          @full_name
        end

        def parent_ids
          @parent_ids ||= parent_id ? parent.parent_ids + [parent_id] : []
        end

        def all_names
          names = parent_ids.map do |id|
            Scope.find_by(id:).name[I18n.locale.to_s]
          end + [name[I18n.locale.to_s]]

          return names if names.count < 4

          names[0..1] + [names[2..].join(" > ")]
        end

        def all_children
          @all_children ||= children.map do |child|
            [child] + child.all_children
          end.flatten
        end

        def children_taxonomies
          # next level is going to be too deep, we transform the children into siblings
          return sibling_taxonomies if parent_ids.count.positive?

          children.to_h { |child| [child.full_name[I18n.locale.to_s], child.taxonomies] }
        end

        def sibling_taxonomies
          all_children.to_h do |child|
            [
              child.full_name[I18n.locale.to_s],
              {
                name: child.full_name,
                origin: child.to_global_id.to_s,
                children: {},
                resources: child.resources
              }
            ]
          end
        end

        def taxonomies
          {
            name:,
            origin: to_global_id.to_s,
            children: children_taxonomies,
            resources:
          }
        end

        def resources
          Scope.resource_classes.each_with_object({}) do |klass, hash|
            items = if klass.to_s == "Decidim::InitiativesTypeScope"
                      klass.where(decidim_scopes_id: id)
                    else
                      klass.where(decidim_scope_id: id)
                    end
            hash.merge!(items.to_h { |resource| [resource.to_global_id.to_s, resource_name(resource)] })
          end
        end

        def self.filter_item_for_space_manifest(space_manifest)
          items = []
          all_in_org.where(parent_id: nil).find_each do |scope|
            items << [scope.name[I18n.locale.to_s]]
            scope.all_children.map(&:all_names).each do |names|
              items << names
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

        def self.filter_item_for_component(component, space, space_manifest)
          return unless component.settings.respond_to?(:taxonomy_filters)

          scopes_enabled = component.settings[:scopes_enabled]
          return unless scopes_enabled

          scope = find_by(id: component.settings[:scope_id]) || (space.scopes_enabled? && find_by(id: space.decidim_scope_id))
          list = scope ? [scope] + scope.all_children : all

          {
            space_filter: false,
            space_manifest:,
            name: root_taxonomy_name,
            internal_name: "#{root_taxonomy_name}: #{component.name[I18n.locale.to_s]}",
            items: list.map(&:all_names),
            components: [component.to_global_id.to_s]
          }
        end

        def self.all_filters
          Scope.participatory_space_classes.each_with_object([]) do |space_class, hash|
            space_manifest = space_class.to_s.split("::").last.underscore.pluralize
            # 1 filter per participatory space as space_filter=true
            hash << filter_item_for_space_manifest(space_manifest)
            # 1 filter per component as space_filter=false on those with scopes, suffix: "Component Name"
            # Only for components with scopes
            space_class.where(organization:).each do |space|
              space.components.each do |component|
                component_filter = filter_item_for_component(component, space, space_manifest)
                hash << component_filter if component_filter
              end
            end
          end
        end

        def self.all_taxonomies
          all_in_org.where(parent_id: nil).to_h { |scope| [scope.name[I18n.locale.to_s], scope.taxonomies] }
        end
      end
    end
  end
end
