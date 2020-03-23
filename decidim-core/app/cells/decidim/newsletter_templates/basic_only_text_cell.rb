# frozen_string_literal: true

module Decidim
  module NewsletterTemplates
    class BasicOnlyTextCell < Decidim::ViewModel
      include Decidim::SanitizeHelper

      def translated_body
        translated_attribute(model.settings.body)
      end
    end
  end
end
