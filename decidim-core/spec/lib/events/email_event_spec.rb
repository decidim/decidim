# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::EmailEvent do
    class TestEvent < Decidim::Events::BaseEvent
      include Events::EmailEvent
    end

    describe ".types" do
      subject { TestEvent }

      it "adds `:email` to the types array" do
        expect(subject.types).to include :email
      end
    end
  end
end
