# frozen_string_literal: true

module Decidim
  module Blogs
    class SchemaOrgBlogPostingPostSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper
      include Decidim::SanitizeHelper
      include ActionView::Helpers::UrlHelper

      # Public: Initializes the serializer with a post.
      def initialize(post)
        @post = post
      end

      # Serializes a post for the Schema.org Event type
      #
      # @see https://schema.org/BlogPosting
      # @see https://developers.google.com/search/docs/appearance/structured-data/article?hl=en
      def serialize
        attributes = {
          "@context": "https://schema.org",
          "@type": "BlogPosting",
          headline: decidim_escape_translated(post.title),
          author:
        }

        attributes = attributes.merge(image:) if post.photos.any?
        attributes = attributes.merge(datePublished: published) if post.published?
        attributes
      end

      private

      attr_reader :post
      alias resource post

      def author
        case post.author.class.name
        when "Decidim::Organization"
          author_organization
        when "Decidim::User"
          author_user
        end
      end

      def author_organization
        {
          "@type": "Organization",
          name: decidim_escape_translated(post.author.name),
          url: EngineRouter.new("decidim", router_options).root_url
        }
      end

      def author_user
        {
          "@type": "Person",
          name: decidim_escape_translated(post.author.name),
          url: profile_url(post.author)
        }
      end

      def router_options = { host: post.organization.host }

      def image = post.photos.map(&:thumbnail_url)

      def published
        post.published_at.iso8601
      end
    end
  end
end
