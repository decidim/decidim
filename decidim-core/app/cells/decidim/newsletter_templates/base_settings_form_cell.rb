# frozen_string_literal: true

module Decidim
  module NewsletterTemplates
    class BaseSettingsFormCell < Decidim::ViewModel
      alias form model

      def content_block
        options[:content_block]
      end
    end
  end
end
