# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class ApplicationRecord < ActiveRecord::Base
        self.abstract_class = true
        @resource_classes = []
        @participatory_space_classes = []

        def self.with(organization)
          @organization = organization
          self
        end

        class << self
          attr_reader :organization
        end

        attr_reader :organization

        def self.all_in_org
          where(decidim_organization_id: @organization.id)
        end

        def self.participatory_space_classes
          @participatory_space_classes.map(&:safe_constantize).compact_blank
        end

        def self.participatory_space_models(classes)
          @participatory_space_classes = classes
        end

        def self.resource_classes
          @resource_classes.map(&:safe_constantize).compact_blank
        end

        def self.resource_models(classes)
          @resource_classes = classes
        end

        def self.add_resource_class(klass)
          @resource_classes ||= []
          @resource_classes << klass
        end

        def resource_title(resource)
          if resource.respond_to?(:full_name)
            resource.full_name
          elsif resource.respond_to?(:title)
            resource.title
          elsif resource.respond_to?(:name)
            resource.name
          else
            resource.to_s
          end
        end

        def resource_name(resource)
          title = resource_title(resource)
          if title.is_a?(Hash)
            title[I18n.locale.to_s]
          else
            title
          end
        end

        def self.all_taxonomies
          raise NotImplementedError
        end

        def self.all_filters
          raise NotImplementedError
        end

        def self.to_taxonomies
          return [] unless all_taxonomies.any?

          {
            root_taxonomy_name => to_h
          }
        end

        def self.to_h
          {
            taxonomies: all_taxonomies,
            filters: all_filters
          }
        end
      end
    end
  end
end
