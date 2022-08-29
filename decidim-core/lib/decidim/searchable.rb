# frozen_string_literal: true

require "active_support/concern"
require "decidim/search_resource_fields_mapper"

module Decidim
  # A concern with the features needed when you want a model to be searchable.
  #
  # A Searchable should include this concern and declare its `searchable_fields`.
  # You'll also need to define it as `searchable` in its resource manifest,
  # otherwise it won't appear as possible results.
  #
  # The indexing of Searchables is managed through:
  # - after_create callback configurable via `index_on_create`.
  # - after_update callback configurable via `index_on_update`.
  # - searchable_resources are destroyed when the Searchable is destroyed.
  #
  module Searchable
    extend ActiveSupport::Concern

    # Public: a Hash of searchable resources where keys are class names, and values
    #   are the class instance for the resources.
    def self.searchable_resources
      Decidim.resource_manifests.select(&:searchable).inject({}) do |searchable_resources, manifest|
        searchable_resources.update(manifest.model_class_name => manifest.model_class)
      end
    end

    def self.searchable_resources_of_type_participant
      searchable_resources.slice("Decidim::User", "Decidim::UserGroup")
    end

    def self.searchable_resources_of_type_participatory_space
      searchable_resources.select { |r| r.constantize.reflect_on_association(:components).present? }
    end

    def self.searchable_resources_of_type_component
      searchable_resources.select { |r| r.constantize.ancestors.include?(Decidim::HasComponent) }
    end

    def self.searchable_resources_of_type_comment
      searchable_resources.select { |r| r == "Decidim::Comments::Comment" }
    end

    included do
      # Always access to this association scoping by_organization
      clazz = self
      has_many :searchable_resources, -> { where(resource_type: clazz.name) },
               class_name: "Decidim::SearchableResource",
               inverse_of: :resource,
               foreign_key: :resource_id do
        def by_organization(org_id)
          where(decidim_organization_id: org_id)
        end
      end

      after_touch do |searchable|
        remove_from_index(searchable) if searchable.respond_to?(:hidden?) && searchable.hidden?
      end

      after_destroy do |searchable|
        remove_from_index(searchable) if self.class.search_resource_fields_mapper
      end
      # after_create and after_update callbacks are dynamically setted in `searchable_fields` method.

      # Public: after_create callback to index the model as a SearchableResource, if configured so.
      #
      def try_add_to_index_as_search_resource
        return unless self.class.searchable_resource?(self) && self.class.search_resource_fields_mapper.index_on_create?(self)

        add_to_index_as_search_resource
      end

      def remove_from_index(searchable)
        org = self.class.search_resource_fields_mapper.retrieve_organization(searchable)
        searchable.searchable_resources.by_organization(org.id).destroy_all
      end

      # Forces the model to be indexed for the first time.
      def add_to_index_as_search_resource
        fields = self.class.search_resource_fields_mapper.mapped(self)
        fields[:i18n].keys.each do |locale|
          Decidim::SearchableResource.create!(contents_to_searchable_resource_attributes(fields, locale))
        end
      end

      # Public: after_update callback to update index information of the model.
      #
      def try_update_index_for_search_resource
        return unless self.class.searchable_resource?(self)

        org = self.class.search_resource_fields_mapper.retrieve_organization(self)
        return unless org

        searchables_in_org = searchable_resources.by_organization(org.id)

        if self.class.search_resource_fields_mapper.index_on_update?(self)
          if searchables_in_org.empty?
            add_to_index_as_search_resource
          else
            fields = self.class.search_resource_fields_mapper.mapped(self)
            searchables_in_org.find_each do |sr|
              next if sr.blank?

              sr.update(contents_to_searchable_resource_attributes(fields, sr.locale))
            end
          end
        elsif searchables_in_org.any?
          searchables_in_org.destroy_all
        end

        find_and_update_descendants
      end

      private

      def find_and_update_descendants
        Decidim::FindAndUpdateDescendantsJob.perform_later(self)
      end

      def contents_to_searchable_resource_attributes(fields, locale)
        contents = fields[:i18n][locale]
        content_a = I18n.transliterate(contents[:A] || "")
        content_b = I18n.transliterate(contents[:B] || "")
        content_c = I18n.transliterate(contents[:C] || "")
        content_d = I18n.transliterate(contents[:D] || "")
        {
          content_a:, content_b:, content_c:, content_d:,
          locale:,
          datetime: fields[:datetime],
          decidim_scope_id: fields[:decidim_scope_id],
          decidim_participatory_space_id: fields[:decidim_participatory_space_id],
          decidim_participatory_space_type: fields[:decidim_participatory_space_type],
          decidim_organization_id: fields[:decidim_organization_id],
          resource_id: id,
          resource_type: self.class.name
        }
      end
    end

    class_methods do
      def search_resource_fields_mapper
        raise "`searchable_fields` should be declared when including Searchable" unless defined?(@search_resource_indexable_fields)

        @search_resource_indexable_fields
      end

      def order_by_id_list(id_list)
        return ApplicationRecord.none if id_list.to_a.empty?

        values_clause = id_list.each_with_index.map { |id, i| "(#{id}, #{i})" }.join(", ")
        joins(Arel.sql("JOIN (VALUES #{values_clause}) AS #{table_name}_id_order(id, ordering) ON #{table_name}.id = #{table_name}_id_order.id").to_s)
          .order(Arel.sql("#{table_name}_id_order.ordering").to_s)
      end

      # Declares the searchable fields for this instance and, optionally, some conditions.
      # `declared_fields` must be a Hash that follow the following format:
      # {
      #   scope_id: { scope: :id },
      #   participatory_space: { feature: :participatory_space },
      #   A: :title,
      #   B: :sub_title,
      #   C: :somehow_relevant_field,
      #   D: [:description, :address]
      # }
      #
      # `conditions` must be a Hash that only accepts a boolean or a Proc that will be evaluated on runtime and returns a boolean for the following keys:
      # - index_on_create: Whether to index, or not, the current searchabe when it is created. Defaults to true.
      # - index_on_update: Whether to index, or not, the current searchabe when it is updated. Defaults to true.
      #
      def searchable_fields(declared_fields, conditions = {})
        @search_resource_indexable_fields = SearchResourceFieldsMapper.new(declared_fields)
        conditions = { index_on_create: true, index_on_update: true }.merge(conditions)
        if conditions[:index_on_create]
          after_create :try_add_to_index_as_search_resource
          @search_resource_indexable_fields.set_index_condition(:create, conditions[:index_on_create])
        end
        if conditions[:index_on_update]
          after_update :try_update_index_for_search_resource
          @search_resource_indexable_fields.set_index_condition(:update, conditions[:index_on_update])
        end
      end

      def searchable_resource?(resource)
        Decidim::Searchable.searchable_resources.include?(resource.class.name)
      end
    end
  end
end
