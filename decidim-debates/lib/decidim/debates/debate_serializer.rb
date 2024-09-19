# frozen_string_literal: true

module Decidim
  module Debates
    # This class serializes a Debate so can be exported to CSV, JSON or other
    # formats.
    class DebateSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a debate.
      def initialize(debate)
        @debate = debate
      end

      # Public: Exports a hash with the serialized data for this debate.
      def serialize
        {
          id: debate.id,
          # author: {
          #   **author_fields
          # },
          title: debate.title,
          description: debate.description,
          instructions: debate.instructions,
          start_time: debate.start_time,
          end_time: debate.end_time,
          information_updates: debate.information_updates,
          category: {
            id: debate.category.try(:id),
            name: debate.category.try(:name)
          },
          scope: {
            id: debate.scope.try(:id),
            name: debate.scope.try(:name)
          },
          participatory_space: {
            id: debate.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(debate.participatory_space).url
          },
          component: { id: component.id },
          reference: debate.reference,
          comments: debate.comments_count,
          followers: debate.follows.size,
          url:,
          conclusions: debate.conclusions,
          closed_at: debate.closed_at,
          last_comment_at: debate.last_comment_at,
          comments_enabled: debate.comments_enabled
        }
      end

      private

      attr_reader :debate
      alias resource debate

      def component
        debate.component
      end

      def url
        Decidim::ResourceLocatorPresenter.new(debate).url
      end

      def author_fields
        # FIXME: adapt from proposals with single author
        is_author_user_group = resource.coauthorships.map(&:decidim_user_group_id).any?

        {
          id: resource.authors.map(&:id),
          name: resource.authors.map do |author|
            author_name(is_author_user_group ? resource.coauthorships.first.user_group : author)
          end,
          url: resource.authors.map do |author|
            author_url(is_author_user_group ? resource.coauthorships.first.user_group : author)
          end
        }
      end

      def author_name(author)
        translated_attribute(author.name)
      end

      def author_url(author)
        if author.respond_to?(:nickname)
          profile_url(author.nickname) # is a Decidim::User or Decidim::UserGroup
        else
          root_url # is a Decidim::Organization
        end
      end
    end
  end
end
