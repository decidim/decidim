# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be searchable.
  module Searchable
    extend ActiveSupport::Concern

    included do
      has_many :searchable_rsrcs, class_name: "Decidim::SearchableRsrc", inverse_of: :resource, foreign_key: :resource_id, dependent: :destroy
      after_create :add_to_index_as_search_rsrc
      after_update :update_index_for_search_rsrc
    end

    #
    # Protected: callback that Searchable invokes when indexing or re-indexing a model to obtain the information to be added to the index.
    #
    # Model will be inferred with `resource= self`.
    # @returns A Hash with the content in the form:
    # {
    #   decidim_scope_id: 1234,
    #   decidim_participatory_space_id: 1234,
    #   decidim_participatory_space_type: 'Decidim::Processes',
    #   decidim_organization_id: 1234,
    #   i18n: {ca:{A:[],B:[],C:[],D:[]},en:{ca:{A:[],B:[],C:[],D:[]},es:{ca:{A:[],B:[],C:[],D:[]}}
    # }
    #
    def search_rsrc_indexable_fields
      raise "#{self.class.name}#search_rsrc_indexable_fields is abstract and should be overriden"
    end

    # Public: after_create callback to index the model as a SearchableRsrc.
    #
    def add_to_index_as_search_rsrc
      fields = search_rsrc_indexable_fields
      fields[:i18n].keys.each do |locale|
        Decidim::SearchableRsrc.create(contents_to_searchable_rsrc_attrs(fields, locale))
      end
    end

    # Public: after_update callback to update index information of the model.
    #
    def update_index_for_search_rsrc
      fields = search_rsrc_indexable_fields
      searchable_rsrcs.each do |sr|
        sr.update(contents_to_searchable_rsrc_attrs(fields, sr.locale))
      end
    end

    #------------------------------------------------------------------

    private

    #------------------------------------------------------------------
    def contents_to_searchable_rsrc_attrs(fields, locale)
      contents = fields[:i18n][locale]
      content_a = contents[:A]&.join(" ")
      content_b = contents[:B]&.join(" ")
      content_c = contents[:C]&.join(" ")
      content_d = contents[:D]&.join(" ")
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
end
