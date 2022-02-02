# frozen_string_literal: true

require "spec_helper"

describe Decidim::SendPushNotification do
  subject { described_class.new }

  context "with a user that doesn't allow push notifications" do
    describe "#perform" do
      let(:user) { create(:user, allow_push_notifications: false) }
      let(:notification) { create :notification, user: user }

      it "returns false" do
        expect(subject.perform(notification)).to be_falsy
      end
    end
  end

  context "without subscription" do
    describe "#perform" do
      let(:user) { create(:user, allow_push_notifications: true) }
      let(:notification) { create :notification, user: user }

      it "returns false" do
        expect(subject.perform(notification)).to be_falsy
      end
    end
  end

  context "with subscription" do
    let(:user) { create(:user, allow_push_notifications: true) }
    let(:notification) { create :notification, user: user }
    let(:subscription) { build(:notifications_subscription) }

    before do
      user.notifications_subscriptions << subscription
    end

    describe "#perform" do
      it "returns true" do
        allow(Webpush).to receive(:payload_send).and_return(double("result", message: "Created", code: "201"))

        expect(subject.perform(notification).code).to eq("201")
        expect(subject.perform(notification).message).to eq("Created")
      end
    end
  end
end
