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

      # Public: Finds the type and name of the participatory space the given
      # `reportable` object is associated to.
      #
      # Returns a String, or `nil` if the space is not found.
      def participatory_space_title_for(reportable, options = {})
        space = reportable.try(:participatory_space)
        return unless space

        I18n.with_locale(options.fetch(:locale, I18n.locale)) do
          title = translated_attribute(space.try(:title) || space.try(:name))
          type = space.class.model_name.human
          [type, title].compact.join(": ").truncate(options.fetch(:limit, 100))
        end
      end
    end
  end
end
