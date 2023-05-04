# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Conferences
    class ConferenceMetadataCell < Decidim::CardMetadataCell
      delegate :start_date, :end_date, to: :model

      def items
        [dates_metadata_item].compact
      end

      def dates_metadata_item
        {
          title: [
            t("start_date", scope: "activemodel.attributes.participatory_process_step"),
            t("end_date", scope: "activemodel.attributes.participatory_process_step")
          ].join(" / "),
          icon: "calendar-todo-line",
          text: [
            start_date.present? ? l(start_date, format: :decidim_short_with_month_name_short) : "?",
            end_date.present? ? l(end_date, format: :decidim_short_with_month_name_short) : "?"
          ].join(" → ")
        }
      end
    end
  end
end
