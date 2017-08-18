require "spec_helper"

describe Decidim::Meetings::UpdateMeetingEvent do
  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end
  end
end
