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
          author: {
            **author_fields
          },
          title: debate.title,
          description: debate.description,
          instructions: debate.instructions,
          start_time: debate.start_time,
          end_time: debate.end_time,
          information_updates: debate.information_updates,
          taxonomies:,
          participatory_space: {
            id: debate.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(debate.participatory_space).url
          },
          component: { id: component.id },
          reference: debate.reference,
          comments: debate.comments_count,
          follows_count: debate.follows_count,
          url:,
          last_comment_at: debate.last_comment_at,
          last_comment_by: {
            **last_comment_by_fields
          },
          comments_enabled: debate.comments_enabled,
          conclusions: debate.conclusions,
          closed_at: debate.closed_at,
          created_at: debate.created_at,
          updated_at: debate.updated_at,
          endorsements_count: debate.endorsements_count
        }
      end

      private

      attr_reader :debate
      alias resource debate

      def last_comment_by_fields
        return {} unless debate.last_comment_by

        {
          id: debate.last_comment_by.id,
          name: user_name(debate.last_comment_by),
          url: user_url(debate.last_comment_by)
        }
      end

      def component
        debate.component
      end

      def url
        Decidim::ResourceLocatorPresenter.new(debate).url
      end

      def author_fields
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
          profile_url(author) # is a Decidim::User or Decidim::UserGroup
        else
          root_url # is a Decidim::Organization
        end
      end

      def profile_url(author)
        return "" if author.respond_to?(:deleted?) && author.deleted?

        Decidim::Core::Engine.routes.url_helpers.profile_url(author.nickname, host:)
      end

      def root_url
        Decidim::Core::Engine.routes.url_helpers.root_url(host:)
      end

      def host
        resource.organization.host
      end
    end
  end
end
