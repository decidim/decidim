# frozen_string_literal: true

require "active_support/concern"
require "decidim/search_resource_fields_mapper"

module Decidim
  # A concern with the features needed when you want a model to be searchable.
  module Searchable
    extend ActiveSupport::Concern

    # Public: an Array of searchable resources
    def self.searchable_resources
      @searchable_resources ||= []
      @searchable_resources.uniq
    end

    included do
      has_many :searchable_rsrcs, class_name: "Decidim::SearchableRsrc", inverse_of: :resource, foreign_key: :resource_id, dependent: :destroy
      after_create :add_to_index_as_search_rsrc
      after_update :update_index_for_search_rsrc

      # Public: after_create callback to index the model as a SearchableRsrc.
      #
      def add_to_index_as_search_rsrc
        fields = self.class.search_rsrc_fields_mapper.mapped(self)
        fields[:i18n].keys.each do |locale|
          Decidim::SearchableRsrc.create(contents_to_searchable_rsrc_attrs(fields, locale))
        end
      end

      # Public: after_update callback to update index information of the model.
      #
      def update_index_for_search_rsrc
        fields = self.class.search_rsrc_fields_mapper.mapped(self)
        searchable_rsrcs.each do |sr|
          sr.update(contents_to_searchable_rsrc_attrs(fields, sr.locale))
        end
      end

      #------------------------------------------------------------------

      private

      #------------------------------------------------------------------
      def contents_to_searchable_rsrc_attrs(fields, locale)
        contents = fields[:i18n][locale]
        content_a = contents[:A]
        content_b = contents[:B]
        content_c = contents[:C]
        content_d = contents[:D]
        {
          content_a: content_a, content_b: content_b, content_c: content_c, content_d: content_d,
          locale: locale,
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

      # Declare the searchable fields for this instance.
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
        @searchable_resources ||= []
        @searchable_resources << name
      end
    end
  end
end
