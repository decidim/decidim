# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessPresenter < ResourcePresenter
      include Decidim::ResourceHelper
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

      def hero_image_url
        process.attached_uploader(:hero_image).url
      end

      def area_name
        return if process.area.blank?

        Decidim::AreaPresenter.new(process.area).translated_name_with_type
      end

      def title(html_escape: false, all_locales: false)
        return unless process

        super(process.title, html_escape, all_locales)
      end

      def description(links: nil, strip_tags: false, all_locales: false)
        return unless process
        raise "Links are being defined" unless links.nil?

        content_handle_locale(process.description, all_locales, links, strip_tags)
      end

      def editor_description(all_locales: false)
        return unless process

        editor_locales(process.description, all_locales)
      end

      def short_description(links: nil, strip_tags: false, all_locales: false)
        return unless process
        raise "Links are being defined" unless links.nil?

        content_handle_locale(process.short_description, all_locales, links, strip_tags)
      end

      def editor_short_description(all_locales: false)
        return unless process

        editor_locales(process.short_description, all_locales)
      end

      def process
        __getobj__
      end
    end
  end
end
