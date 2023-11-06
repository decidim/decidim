# frozen_string_literal: true

module Decidim
  module Pages
    # This class serializes the specific data in each Page. This is the page
    # data outside of the component settings.
    class DataSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      # Serializes the page data for this component.
      #
      # @return [Hash] The serialized data
      def serialize
        page = Page.find_by(component: resource)

        {
          body: page&.body || empty_translatable
        }
      end
    end
  end
end
