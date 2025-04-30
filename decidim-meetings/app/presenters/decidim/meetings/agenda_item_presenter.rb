# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for agenda items
    #
    class AgendaItemPresenter < Decidim::ResourcePresenter
      include Decidim::ResourceHelper
      include Decidim::SanitizeHelper

      def agenda_item
        __getobj__
      end

      def description(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless agenda_item

        content_handle_locale(agenda_item.description, all_locales, extras, links, strip_tags)
      end

      def editor_description(all_locales: false, extras: true)
        return unless agenda_item

        editor_locales(agenda_item.description, all_locales, extras:)
      end
    end
  end
end
