# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceHeroCell < Decidim::ContentBlocks::BaseCell
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper
      include Decidim::TwitterSearchHelper

      attr_reader :cta_text, :cta_path

      delegate :title, :subtitle, :attached_uploader, :hashtag, to: :resource

      def title_text
        translated_attribute(title)
      end

      def subtitle_text
        translated_attribute(subtitle)
      end

      def image_path
        attached_uploader(:banner_image).path
      end

      def has_hashtag?
        @has_hashtag ||= hashtag.present?
      end

      def has_cta?
        [cta_text, cta_path].all?
      end

      def escaped_hashtag
        return unless has_hashtag?

        @escaped_hashtag ||= decidim_html_escape(hashtag)
      end
    end
  end
end
