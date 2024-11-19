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
          child.name[I18n.locale.to_s] = "#{name[I18n.locale.to_s]} > #{child.name[I18n.locale.to_s]}"
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

      # TODO: check what happens with components, scope defined in settings
      def resources
        RESOURCE_CLASSES.each_with_object({}) do |type, hash|
          if klass = type.safe_constantize
            hash.merge!(klass.where(scope: id).to_h { |resource| [resource.to_global_id.to_s, resource.title[I18n.locale.to_s]] })
          else
            Rails.logger.error("Resource class not found while converting scopes to taxonomies: #{klass}")
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
          taxonomies: all.to_h { |type| [type.name[I18n.locale.to_s], type.taxonomies] },
          filters: {
            I18n.t("decidim.scopes.scopes") => {
              space_filter: true,
              space_manifest: "assemblies",
              items: all.map { |type| [type.name[I18n.locale.to_s]] },
              components: []
            }
          }
        }
      end
    end
  end
end
