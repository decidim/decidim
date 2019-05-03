# frozen_string_literal: true

module Decidim
  module Debates
    # This class serializes a debate so can be exported to CSV, JSON or other
    # formats.
    class DebateSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a debate.
      def initialize(debate)
        @debate = debate
      end

      # Public: Exports a hash with the serialized data for this debate.
      def serialize
        {
          id: debate.id,
          title: present(debate).title,
          description: present(debate).description,
          comments: debate.comments.count,
          url: url,
          category: {
            id: debate.category.try(:id),
            name: debate.category.try(:name) || empty_translatable
          },
          component: { id: component.id },
          participatory_space: {
            id: debate.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(debate.participatory_space).url
          },
          created_at: debate.created_at,
          start_time: debate.start_time,
          end_time: debate.end_time,
          author_url: Decidim::UserPresenter.new(debate.author).try(:profile_url)
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
