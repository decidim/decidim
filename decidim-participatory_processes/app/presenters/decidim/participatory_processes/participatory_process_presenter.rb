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

      def title(links: nil, extras: nil, html_escape: false, all_locales: false)
        return unless process

        raise "Extras has been set" unless extras.nil?
        raise "Links have been set" unless links.nil?

        super(process.title, nil, html_escape, all_locales)
      end

      def description(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless process

        content_handle_locale(process.description, all_locales, extras, links, strip_tags)
      end

      def editor_description(extras: true, all_locales: false)
        return unless process

        editor_locales(process.description, all_locales, extras:)
      end

      def short_description(links: false, extras: true, strip_tags: false, all_locales: false)
        return unless process

        content_handle_locale(process.short_description, all_locales, extras, links, strip_tags)
      end

      def editor_short_description(extras: true, all_locales: false)
        return unless process

        editor_locales(process.short_description, all_locales, extras:)
      end

      def process
        __getobj__
      end
    end
  end
end
