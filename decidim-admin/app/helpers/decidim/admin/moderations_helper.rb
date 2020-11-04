# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show moderation in admin
    module ModerationsHelper
      # Public: Renders an extract of the content reported in a text format.
      def reported_content_excerpt_for(reportable, options = {})
        I18n.with_locale(options.fetch(:locale, I18n.locale)) do
          reportable_content = reportable.reported_attributes.map do |attribute_name|
            attribute_value = reportable.attributes.with_indifferent_access[attribute_name]
            next translated_attribute(attribute_value) if attribute_value.is_a? Hash

            attribute_value
          end
          reportable_content.filter(&:present?).join(". ").truncate(options.fetch(:limit, 100))
        end
      end
    end
  end
end
