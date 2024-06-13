# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NotificationActions
    class BaseCell < Decidim::NotificationCell
      def data
        model&.event_class_instance&.action_data
      end
    end
  end
end
