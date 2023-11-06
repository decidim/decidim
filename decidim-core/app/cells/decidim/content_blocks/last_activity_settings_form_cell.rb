# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class LastActivitySettingsFormCell < Decidim::ViewModel
      alias form model

      def label
        I18n.t("decidim.content_blocks.last_activity_settings_form.max_last_activity_users")
      end
    end
  end
end
