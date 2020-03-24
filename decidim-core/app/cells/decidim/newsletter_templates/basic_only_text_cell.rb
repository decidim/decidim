# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NewsletterTemplates
    class BasicOnlyTextCell < Decidim::ViewModel
      include Decidim::SanitizeHelper
      include Cell::ViewModel::Partial
      include Decidim::NewslettersHelper

      def show
        render :show
      end

      def body
        parse_interpolations(uninterpolated_body, recipient_user, newsletter.id)
      end

      def uninterpolated_body
        translated_attribute(model.settings.body)
      end

      def organization
        options[:organization]
      end
      alias current_organization organization

      def newsletter
        options[:newsletter]
      end

      def recipient_user
        options[:recipient_user]
      end
    end
  end
end
