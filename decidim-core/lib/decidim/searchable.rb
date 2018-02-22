# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the features needed when you want a model to be searchable.
  module Searchable
    extend ActiveSupport::Concern

    included do
      has_one :searchable_rsrc, class_name: "Decidim::SearchableRsrc", inverse_of: :resource
      after_create :index_as_search_rsrc
      after_update :index_as_search_rsrc
      after_destroy :unindex_from_search_rsrc
    end

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
      raise "#{self.class.name}#search_doc_indexable_fields is abstract and should be overriden"
    end

    def index_as_search_rsrc
      fields = search_rsrc_indexable_fields
      fields[:i18n].each_pair do |locale, contents|
        content_a = contents[:A]&.join(" ")
        content_b = contents[:B]&.join(" ")
        content_c = contents[:C]&.join(" ")
        content_d = contents[:D]&.join(" ")
        Decidim::SearchableRsrc.create(
          content_a: content_a, content_b: content_b, content_c: content_c, content_d: content_d,
          locale: locale,
          decidim_scope_id: fields[:decidim_scope_id],
          decidim_participatory_space_id: fields[:decidim_participatory_space_id],
          decidim_participatory_space_type: fields[:decidim_participatory_space_type],
          decidim_organization_id: fields[:decidim_organization_id],
          resource: self
        )
      end
    end
  end
end
