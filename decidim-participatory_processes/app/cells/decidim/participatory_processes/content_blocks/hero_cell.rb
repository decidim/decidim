# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class HeroCell < Decidim::ContentBlocks::BaseCell
        include Decidim::ApplicationHelper
        include Decidim::SanitizeHelper
        include Decidim::TranslationsHelper
        include Decidim::TwitterSearchHelper
        include ParticipatorySpaceContentBlocksHelper

        attr_reader :cta_text, :cta_path

        delegate :title, :subtitle, :attached_uploader, :hashtag, :active_step, to: :resource

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
          return if active_step.blank?

          @cta_text ||= translated_attribute(active_step.cta_text).presence
          @cta_path ||= active_step.cta_path.presence && step_cta_url(resource)

          [cta_text, cta_path].all?
        end

        def escaped_hashtag
          return unless has_hashtag?

          @escaped_hashtag ||= decidim_html_escape(hashtag)
        end
      end
    end
  end
end
