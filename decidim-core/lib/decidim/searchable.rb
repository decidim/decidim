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
      after_create :add_to_index_as_search_resource
      after_update :update_index_for_search_rersource

      # Public: after_create callback to index the model as a SearchableResource.
      #
      def add_to_index_as_search_resource
        fields = self.class.search_rsrc_fields_mapper.mapped(self)
        fields[:i18n].keys.each do |locale|
          Decidim::SearchableResource.create(contents_to_searchable_rsrc_attrs(fields, locale))
        end
      end

      # Public: after_update callback to update index information of the model.
      #
      def update_index_for_search_resource
        fields = self.class.search_rsrc_fields_mapper.mapped(self)
        searchable_resources.each do |sr|
          sr.update(contents_to_searchable_rsrc_attrs(fields, sr.locale))
        end
      end

      private

      def contents_to_searchable_rsrc_attrs(fields, locale)
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
      def search_rsrc_fields_mapper
        raise "`searchable_fields` should be declared when including Searchable" unless defined?(@search_rsrc_indexable_fields)
        @search_rsrc_indexable_fields
      end

      # Declares the searchable fields for this instance.
      # Must be a Hash that follow the following format:
      # {
      #   scope_id: { scope: :id },
      #   participatory_space: { feature: :participatory_space },
      #   A: :title,
      #   B: :sub_title,
      #   C: :somehow_relevant_field,
      #   D: [:description, :address]
      # }
      def searchable_fields(declared_fields)
        @search_rsrc_indexable_fields = SearchResourceFieldsMapper.new(declared_fields)
        Decidim::Searchable.searchable_resources[name] = self unless Decidim::Searchable.searchable_resources.has_key?(name)
      end
    end
  end
end
