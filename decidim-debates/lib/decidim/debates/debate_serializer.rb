# frozen_string_literal: true

module Decidim
  module Debates
    # This class serializes a Debate so can be exported to CSV, JSON or other
    # formats.
    class DebateSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        {
          id: resource.id,
          author: {
            **author_fields
          },
          title: resource.title,
          description: resource.description,
          instructions: resource.instructions,
          start_time: resource.start_time,
          end_time: resource.end_time,
          information_updates: resource.information_updates,
          taxonomies:,
          participatory_space: {
            id: resource.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(resource.participatory_space).url
          },
          component: { id: component.id },
          reference: resource.reference,
          comments: resource.comments_count,
          follows_count: resource.follows_count,
          url: Decidim::ResourceLocatorPresenter.new(resource).url,
          last_comment_at: resource.last_comment_at,
          last_comment_by: {
            **last_comment_by_fields
          },
          comments_enabled: resource.comments_enabled,
          conclusions: resource.conclusions,
          closed_at: resource.closed_at,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          likes_count: resource.likes_count
        }
      end

      private

      def last_comment_by_fields
        return {} unless resource.last_comment_by
        return {} if resource.last_comment_by.respond_to?(:deleted?) && resource.last_comment_by.deleted?

        {
          id: resource.last_comment_by.id,
          name: user_name(resource.last_comment_by),
          url: user_url(resource.last_comment_by)
        }
      end

      def author_fields
        return {} if resource.author.respond_to?(:deleted?) && resource.author.deleted?

        {
          id: resource.author.id,
          name: user_name(resource.author),
          url: user_url(resource.author)
        }
      end

      def user_name(author)
        translated_attribute(author.name)
      end

      def user_url(author)
        if author.respond_to?(:nickname)
          profile_url(author) # is a Decidim::User
        else
          root_url # is a Decidim::Organization
        end
      end
    end
  end
end
