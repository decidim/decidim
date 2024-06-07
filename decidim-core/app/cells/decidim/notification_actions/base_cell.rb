# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NotificationActions
    class BaseCell < Decidim::NotificationCell
      def data
        action && action["data"]
      end
    end
  end
end
