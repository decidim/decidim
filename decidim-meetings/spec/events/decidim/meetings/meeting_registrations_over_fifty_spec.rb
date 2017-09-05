# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::MeetingRegistrationsOverFifty do
  describe "types" do
    subject { described_class }

    it "supports the notification type" do
      expect(subject.types).to include :notification
    end

    it "supports the email type" do
      expect(subject.types).to include :email
    end
  end
end
