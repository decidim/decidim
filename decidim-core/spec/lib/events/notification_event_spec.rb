# frozen_string_literal: true

require "spec_helper"

describe Decidim::Events::NotificationEvent do
  class TestEvent < Decidim::Events::BaseEvent
    include Decidim::Events::NotificationEvent
  end

  describe ".types" do
    subject { TestEvent }

    it "adds `:notification` to the types array" do
      expect(subject.types).to include :notification
    end
  end
end
