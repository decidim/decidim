# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NotificationActions
    class CalloutCell < BaseCell
      def show
        return unless data && data.present?

        render :show
      end

      def classes
        "callout #{action["class"]}"
      end
    end
  end
end
