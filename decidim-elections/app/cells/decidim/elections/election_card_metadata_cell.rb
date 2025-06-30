# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders metadata for an instance of a Meeting
    class ElectionCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper
      include ActionView::Helpers::DateHelper

      alias election model

      delegate :start_at, :end_and, to: :election

      def initialize(*)
        super

        @items.prepend(*election_items)
      end

      def election_items
        [label]
      end

      def label
        {
          text: content_tag("span", t(label_string, scope: "decidim.elections.elections.show"), class: "#{label_class} label")
        }
      end

      def label_string
        case election.current_status
        when :ongoing
          "ongoing"
        when :not_started
          "not_started"
        else
          "ended"
        end
      end

      def label_class
        case election.current_status
        when :ongoing
          "success"
        when :not_started
          "warning"
        else
          "alert"
        end
      end
    end
  end
end
