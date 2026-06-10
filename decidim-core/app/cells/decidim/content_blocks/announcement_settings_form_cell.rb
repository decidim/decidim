# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class AnnouncementSettingsFormCell < Decidim::ViewModel
      alias form model

      def content_block
        options[:content_block]
      end

      def label
        I18n.t("decidim.content_blocks.announcement.body")
      end
    end
  end
end
