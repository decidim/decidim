# frozen_string_literal: true

module Decidim
  module Debates
    # This class serializes a debate so can be exported to CSV, JSON or other
    # formats.
    class DebateSerializer < Decidim::Exporters::Serializer
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a debate.
      def initialize(debate)
        @debate = debate
      end

      # Public: Exports a hash with the serialized data for this debate.
      def serialize
        {
          id: @debate.id,
          author_id: @debate.author.try(:id),
          title: @debate.title,
          description: @debate.description,
          comments: @debate.comments.count,
          created_at: @debate.created_at,
          url: url,
          component: { id: component.id }
        }
      end

      private

      attr_reader :debate

      def component
        debate.component
      end

      def url
        Decidim::ResourceLocatorPresenter.new(debate).url
      end
    end
  end
end
