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
    end
  end
end
