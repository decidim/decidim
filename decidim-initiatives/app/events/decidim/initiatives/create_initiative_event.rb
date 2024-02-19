# frozen_string_literal: true

module Decidim
  module Initiatives
    class CreateInitiativeEvent < Decidim::Events::SimpleEvent
      def i18n_scope = "decidim.initiatives.events.create_initiative_event"

      def i18n_options
        {
          author_name:,
          author_nickname:,
          author_path:,
          participatory_space_title:,
          participatory_space_url:,
          resource_path:,
          resource_title:,
          resource_url:,
          scope: i18n_scope
        }
      end

      private

      def author_nickname = author.nickname

      def author_name = author.name

      def author_path = author.profile_path

      def author
        @author ||= Decidim::UserPresenter.new(resource.author)
      end
    end
  end
end
