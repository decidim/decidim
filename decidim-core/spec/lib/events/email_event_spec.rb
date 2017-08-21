require "spec_helper"

describe Decidim::Events::EmailEvent do
  class TestEvent < Decidim::Events::BaseEvent
    include Decidim::Events::EmailEvent
  end

  describe ".types" do
    subject { TestEvent }

    it "adds `:email` to the types array" do
      expect(subject.types).to include :email
    end
  end
end
