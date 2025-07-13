# frozen_string_literal: true

module Decidim
  module Accountability
    # This cell renders metadata for an instance of a Result
    class ResultMetadataCell < Decidim::CardMetadataCell
      include Decidim::Accountability::Engine.routes.url_helpers

      delegate :start_date, :end_date, :status, :parent, :reference, to: :model

      alias result model

      def show
        render template
      end

      def initialize(*)
        super

        @items.prepend(*result_items)
      end

      private

      def result_items
        return [dates_item, status_item, status_description] if template == :project_aside
        return [reference, versions] if template == :show_footer

        [dates_item_compact, status_item_compact] + taxonomy_items
      end

      def template
        @template ||= options[:template] || :show
      end

      def dates_item_compact
        return if start_date.blank?

        {
          text: date_values(format: :decidim_with_month_name_short).join(" - "),
          icon: "calendar-todo-line"
        }
      end

      def reference
        { text: resource_reference(result) }
      end

      def versions_count
        @versions_count ||= result.versions_count
      end

      def versions
        return if result.versions.blank?

        { partial: :versions }
      end

      def status_item_compact
        return if status.blank?

        {
          text: decidim_escape_translated(status.name),
          icon: "focus-2-line"
        }
      end

      def dates_item
        return if start_date.blank?

        date_title = [
          *(t("models.result.fields.start_date", scope: "decidim.accountability") if start_date),
          *(t("models.result.fields.end_date", scope: "decidim.accountability") if end_date)
        ].join(" / ")

        {
          text: date_title,
          icon: "calendar-todo-line",
          value: date_values.join(" / ")
        }
      end

      def date_values(format: :decidim_short_with_month_name_short)
        @date_values ||= [
          *(l(start_date, format:) if start_date),
          *(l(end_date, format:) if end_date)
        ]
      end

      def status_item
        return if status.blank?

        {
          text: t("models.result.fields.status", scope: "decidim.accountability"),
          icon: "focus-2-line",
          value: decidim_escape_translated(status.name)
        }
      end

      def status_description
        return unless status.present? && (description = decidim_escape_translated(status.description)).present?

        {
          text: t("models.status.fields.description", scope: "decidim.accountability"),
          icon: "file-text-line",
          value: description
        }
      end

      def percentage_item
        {
          text: display_percentage(result.progress)
        }
      end

      def items_for_map
        [percentage_item].compact_blank.map do |item|
          {
            text: item[:text].to_s.html_safe,
            icon: item[:icon].present? ? icon(item[:icon]).html_safe : nil
          }
        end
      end

      def has_dates?
        start_date.present? && end_date.present?
      end
    end
  end
end
