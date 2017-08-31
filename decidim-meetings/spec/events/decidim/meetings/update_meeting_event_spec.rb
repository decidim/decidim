# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::UpdateMeetingEvent do
  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports notifications" do
      expect(subject.types).to include :email
    end
  end
end
