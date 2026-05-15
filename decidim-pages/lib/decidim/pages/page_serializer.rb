# frozen_string_literal: true

module Decidim
  module Pages
    # This class serializes a Page so can be exported to CSV, JSON or other
    # formats.
    class PageSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a page.
      def initialize(page)
        @page = page
      end

      # Public: Exports a hash with the serialized data for this page.
      def serialize
        {
          id: page.id,
          title: page.title,
          body: page.body,
          created_at: page.created_at,
          updated_at: page.updated_at,
          participatory_space: {
            id: page.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(page.participatory_space).url
          },
          component: { id: component.id },
          url:
        }
      end

      private

      attr_reader :page
      alias resource page

      def url
        Decidim::ResourceLocatorPresenter.new(page).url
      end

      def author_fields
        {
          id: resource.author.id,
          name: author_name(resource.author),
          url: author_url(resource.author)
        }
      end

      def author_name(author)
        translated_attribute(author.name)
      end

      def author_url(author)
        if author.respond_to?(:nickname)
          profile_url(author) # is a Decidim::User
        else
          root_url # is a Decidim::Organization
        end
      end
    end
  end
end
