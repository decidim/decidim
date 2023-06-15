# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent
    end
  end
end
