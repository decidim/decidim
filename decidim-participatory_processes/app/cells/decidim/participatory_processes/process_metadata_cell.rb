# frozen_string_literal: true

require "cell/partial"

module Decidim
  module ParticipatoryProcesses
    class ProcessMetadataCell < Decidim::CardMetadataCell
      delegate :active_step, to: :model

      def initialize(*)
        super

        @items.prepend(*process_items)
      end

      private

      def process_items
        [progress_item, active_step_item].compact
      end

      def active_step_item
        return if active_step.blank?

        {
          text: translated_attribute(active_step.title),
          icon: "direction-line"
        }
      end

      def start_date
        return if model.try(:start_date).blank?

        @start_date ||= model.start_date.to_time
      end

      def end_date
        return if model.try(:end_date).blank?

        @end_date ||= model.end_date.to_time
      end
    end
  end
end
