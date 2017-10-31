# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::NotificationEvent do
    class TestEvent < Decidim::Events::BaseEvent
      include Events::NotificationEvent
    end

    describe ".types" do
      subject { TestEvent }

      it "adds `:notification` to the types array" do
        expect(subject.types).to include :notification
      end
    end
  end
end
