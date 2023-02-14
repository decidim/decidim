# frozen_string_literal: true

require "cell/partial"

module Decidim
  module ParticipatoryProcesses
    # This cell renders the List (:l) process card
    # for an instance of a ParricipatoryProcess
    class ProcessMetadataCell < Decidim::CardMetadataCell
      def initialize(*)
        super

        @items.prepend(*process_items)
      end

      private

      def process_items
        []
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
