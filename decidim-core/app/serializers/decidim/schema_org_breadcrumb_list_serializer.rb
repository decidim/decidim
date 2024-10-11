# frozen_string_literal: true

require "uri"

module Decidim
  class SchemaOrgBreadcrumbListSerializer < Decidim::Exporters::Serializer
    include Decidim::SanitizeHelper

    # Public: Initializes the serializer with a list of breadcrumb items.
    def initialize(options)
      @breadcrumb_items = options[:breadcrumb_items]
      @base_url = options[:base_url]
    end

    # Serializes a breadcrumb items list for the Schema.org BreadcrumbList type
    #
    # @see https://schema.org/BreadcrumbList
    # @see https://developers.google.com/search/docs/appearance/structured-data/breadcrumb?hl=en
    def serialize
      {
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        itemListElement: breadcrumb_items_serialized
      }
    end

    private

    attr_reader :breadcrumb_items, :base_url

    def breadcrumb_items_serialized
      all_items = []

      breadcrumb_items.each_with_index do |item, index|
        all_items << {
          "@type": "ListItem",
          position: index + 1,
          name: decidim_sanitize_translated(item[:label]),
          item: URI.join(base_url, item[:url]).to_s
        }
      end

      all_items
    end
  end
end
