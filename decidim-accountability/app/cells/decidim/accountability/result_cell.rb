# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the result card for an instance of a Result
    class ResultCell < Decidim::ViewModel
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper
      include ActiveSupport::NumberHelper

      delegate :start_date, :end_date, :status, :category, :parent, to: :model

      def show
        render
      end

      private

      def items
        [dates_item, status_item, status_description].compact
      end

      def category_item
        return if inherited_category.blank?

        {
          text: translated_attribute(inherited_category.name),
          icon: "price-tag-3-line"
        }
      end

      def inherited_category
        return category if category.present?

        parent&.category
      end

      def dates_item
        return if start_date.blank?

        date_title = [
          *(t("models.result.fields.start_date", scope: "decidim.accountability") if result.start_date),
          *(t("models.result.fields.end_date", scope: "decidim.accountability") if result.end_date)
        ].join(" / ")

        date_values = [
          *(l(result.start_date, format: :decidim_short_with_month_name_short) if result.start_date),
          *(l(result.end_date, format: :decidim_short_with_month_name_short) if result.end_date)
        ].join(" / ")

        {
          text: date_title,
          icon: "calendar-todo-line",
          value: date_values
        }
      end

      def status_item
        return if status.blank?

        {
          text: t("models.result.fields.status", scope: "decidim.accountability"),
          icon: "focus-2-line",
          value: translated_attribute(status.name)
        }
      end

      def status_description
        return unless status.present? && (description = translated_attribute(status.description)).present?

        {
          text: t("models.status.fields.description", scope: "decidim.accountability"),
          icon: "file-text-line",
          value: description
        }
      end

      def has_dates?
        start_date.present? && end_date.present?
      end
    end
  end
end
