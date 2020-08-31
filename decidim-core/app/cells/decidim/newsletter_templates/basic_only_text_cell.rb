# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NewsletterTemplates
    class BasicOnlyTextCell < BaseCell
      def show
        render :show
      end

      def body
        parse_interpolations(uninterpolated_body, recipient_user, newsletter.id)
      end

      def uninterpolated_body
        translated_attribute(model.settings.body)
      end
    end
  end
end
