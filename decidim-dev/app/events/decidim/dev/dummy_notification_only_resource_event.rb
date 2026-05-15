# frozen_string_literal: true

module Decidim
  module Dev
    class DummyNotificationOnlyResourceEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent
    end
  end
end
