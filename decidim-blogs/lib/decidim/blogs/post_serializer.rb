# frozen_string_literal: true

module Decidim
  module Blogs
    # This class serializes a Post so can be exported to CSV, JSON or other
    # formats.
    class PostSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a post.
      def initialize(post)
        @post = post
      end

      # Public: Exports a hash with the serialized data for this post.
      def serialize
        {
          id: post.id,
          author: {
            **author_fields
          },
          title: post.title,
          body: post.body,
          created_at: post.created_at,
          updated_at: post.updated_at,
          published_at: post.published_at,
          endorsements_count: post.endorsements_count,
          comments_count: post.comments_count,
          follows_count: post.follows_count,
          participatory_space: {
            id: post.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(post.participatory_space).url
          },
          component: { id: component.id },
          url:
        }
      end

      private

      attr_reader :post
      alias resource post

      def url
        Decidim::ResourceLocatorPresenter.new(post).url
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
