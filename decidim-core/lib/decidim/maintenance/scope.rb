# frozen_string_literal: true

module Decidim
  module Maintenance
    class Scope < ApplicationRecord
      RESOURCE_CLASSES = %w(Decidim::Assembly Decidim::ParticipatoryProcess Decidim::Conference Decidim::InitiativesTypeScope
                            Decidim::ActionLog Decidim::Dev::DummyResource
                            Decidim::Accountability::Result
                            Decidim::Budgets::Budget Decidim::Budgets::Project
                            Decidim::Debates::Debate
                            Decidim::Meetings::Meeting
                            Decidim::Proposals::CollaborativeDraft Decidim::Proposals::Proposal).freeze
      self.table_name = "decidim_scopes"
      belongs_to :parent,
                 class_name: "Decidim::Maintenance::Scope",
                 inverse_of: :children,
                 optional: true

      has_many :children,
               foreign_key: "parent_id",
               class_name: "Decidim::Maintenance::Scope",
               inverse_of: :parent

      def parent_ids
        @parent_ids ||= parent_id ? parent.parent_ids + [parent_id] : []
      end

      def all_children
        @all_children ||= children.map do |child|
          child.name[I18n.locale.to_s] = "#{name[I18n.locale.to_s]} > #{resource_name(child)}"
          [child] + child.all_children
        end.flatten
      end

      def children_taxonomies
        return children.map(&:taxonomies) if parent_ids.count < 2

        # next level is going to be too deep, we transform the children into sibilings
        all_children.map do |child|
          {
            name: child.name,
            children: [],
            resources: child.resources
          }
        end
      end

      def taxonomies
        {
          name:,
          children: children_taxonomies,
          resources:
        }
      end

      def resources
        RESOURCE_CLASSES.each_with_object({}) do |type, hash|
          if (klass = type.safe_constantize)
            items = if type == "Decidim::InitiativesTypeScope"
                      klass.where(decidim_scopes_id: id)
                    else
                      klass.where(decidim_scope_id: id)
                    end
            hash.merge!(items.to_h { |resource| [resource.to_global_id.to_s, resource_name(resource)] })
          else
            Rails.logger.error("Resource class not found while converting scopes to taxonomies: #{klass}")
          end
        end
      end

      def filters
        Scope.participatory_spaces.each_with_object({}) do |space_class, hash|
          # 1 filter per participatory space as space_filter=true
          hash[I18n.t("decidim.scopes.scopes")] = {
            space_filter: true,
            space_manifest: space_class.to_s.underscore.pluralize,
            items: all_children.map { |child| [child.name[I18n.locale.to_s]] },
            components: []
          }
          # 1 filter per component as space_filter=false on those with scopes, suffix: "Component Name"
          # Only for components with scopes
          space_class.where(organization:).each do |space|
            space.components.each do |component|
              scopes_enabled = component.settings[:scopes_enabled]
              next unless scopes_enabled

              scope = find_by(id: component.settings[:scope_id]) || (space.scopes_enabled? && Scope.find_by(id: space.decidim_scope_id))
              list = scope ? scope.all_children : Scope.all

              hash["#{I18n.t("decidim.scopes.scopes")}: #{component.name[I18n.locale.to_s]}"] = {
                space_filter: false,
                space_manifest: space.to_s.underscore.pluralize,
                items: list.map { |child| [child.name[I18n.locale.to_s]] },
                components: [component.to_global_id.to_s]
              }
            end
          end
        end
      end

      def self.to_taxonomies
        {
          I18n.t("decidim.scopes.scopes") => to_a
        }
      end

      def self.to_a
        {
          taxonomies: all_in_org.to_h { |type| [type.name[I18n.locale.to_s], type.taxonomies] },
          filters: all_in_org.to_h { |type| [type.name[I18n.locale.to_s], type.filters] }
        }
      end
    end
  end
end
