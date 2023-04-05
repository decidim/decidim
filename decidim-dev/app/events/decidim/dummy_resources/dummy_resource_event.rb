# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceEvent < Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent
    end
  end
end
