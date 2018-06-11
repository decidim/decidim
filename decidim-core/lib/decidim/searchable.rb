# frozen_string_literal: true

require "active_support/concern"
require "decidim/search_resource_fields_mapper"

module Decidim
  # A concern with the features needed when you want a model to be searchable.
  module Searchable
    extend ActiveSupport::Concern

    @searchable_resources = {}

    # Public: a Hash of searchable resources where keys are class names, and values
    #   are the class instance for the resources.
    def self.searchable_resources
      @searchable_resources
    end

    included do
      has_many :searchable_resources, class_name: "Decidim::SearchableResource", inverse_of: :resource, foreign_key: :resource_id, dependent: :destroy
      # after_create and after_update callbacks are dynamically setted in `searchable_fields` method.

      # Public: after_create callback to index the model as a SearchableResource, if configured so.
      #
      def try_add_to_index_as_search_resource
        return unless self.class.search_resource_fields_mapper.index_on_create?(self)
        add_to_index_as_search_resource
      end

      # Forces the model to be indexed for the first time.
      def add_to_index_as_search_resource
        fields = self.class.search_resource_fields_mapper.mapped(self)
        fields[:i18n].keys.each do |locale|
          Decidim::SearchableResource.create(contents_to_searchable_resource_attributes(fields, locale))
        end
      end

      # Public: after_update callback to update index information of the model.
      #
      def try_update_index_for_search_resource
        if self.class.search_resource_fields_mapper.index_on_update?(self)
          if searchable_resources.empty?
            add_to_index_as_search_resource
          else
            fields = self.class.search_resource_fields_mapper.mapped(self)
            searchable_resources.each do |sr|
              sr.update(contents_to_searchable_resource_attributes(fields, sr.locale))
            end
          end
        elsif searchable_resources.any?
          searchable_resources.clear
        end
      end

      private

      def contents_to_searchable_resource_attributes(fields, locale)
        contents = fields[:i18n][locale]
        content_a = I18n.transliterate(contents[:A] || "")
        content_b = I18n.transliterate(contents[:B] || "")
        content_c = I18n.transliterate(contents[:C] || "")
        content_d = I18n.transliterate(contents[:D] || "")
        {
          content_a: content_a, content_b: content_b, content_c: content_c, content_d: content_d,
          locale: locale,
          datetime: fields[:datetime],
          decidim_scope_id: fields[:decidim_scope_id],
          decidim_participatory_space_id: fields[:decidim_participatory_space_id],
          decidim_participatory_space_type: fields[:decidim_participatory_space_type],
          decidim_organization_id: fields[:decidim_organization_id],
          resource: self
        }
      end
    end

    class_methods do
      def search_resource_fields_mapper
        raise "`searchable_fields` should be declared when including Searchable" unless defined?(@search_resource_indexable_fields)
        @search_resource_indexable_fields
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
        Decidim::Searchable.searchable_resources[name] = self unless Decidim::Searchable.searchable_resources.has_key?(name)
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
    end
  end
end
