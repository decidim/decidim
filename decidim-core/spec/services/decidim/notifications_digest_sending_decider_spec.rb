# frozen_string_literal: true

require "spec_helper"

describe Decidim::NotificationsDigestSendingDecider do
  subject { described_class }

  context "with a user who has never received a notifications digest mail" do
    let(:user) { build :user, notifications_sending_frequency: :daily, digest_sent_at: nil }

    describe "must_notify?" do
      it "returns true" do
        expect(subject.must_notify?(user)).to be(true)
      end
    end
  end

  context "when frequency is set to none" do
    let(:user) { build :user, notifications_sending_frequency: :none, digest_sent_at: Time.now.utc }

    describe "must_notify?" do
      it "returns false" do
        expect(subject.must_notify?(user)).to be(false)
      end
    end
  end

  context "when frequency is set to daily" do
    context "with a user who has receive a notifications digest mail in the same day" do
      let(:current_time) { Time.now.utc }
      let(:user) { build :user, notifications_sending_frequency: :daily, digest_sent_at: current_time - 1.hour }

      describe "must_notify?" do
        it "returns false" do
          expect(subject.must_notify?(user, time: current_time)).to be(false)
        end
      end
    end

    context "with a user who has receive a notifications digest mail two days ago" do
      let(:current_time) { Time.now.utc }
      let(:user) { build :user, notifications_sending_frequency: :daily, digest_sent_at: current_time - 2.days }

      describe "must_notify?" do
        it "returns true" do
          expect(subject.must_notify?(user, time: current_time)).to be(true)
        end
      end
    end
  end

  context "when frequency is set to weekly" do
    context "with a user who has receive a notifications digest mail in the same week" do
      let(:current_time) { Time.now.utc }
      let(:user) { build :user, notifications_sending_frequency: :weekly, digest_sent_at: current_time - 1.day }

      describe "must_notify?" do
        it "returns false" do
          expect(subject.must_notify?(user, time: current_time)).to be(false)
        end
      end
    end

    context "with a user who has receive a notifications digest mail two weeks ago" do
      let(:current_time) { Time.now.utc }
      let(:user) { build :user, notifications_sending_frequency: :weekly, digest_sent_at: current_time - 2.weeks }

      describe "must_notify?" do
        it "returns true" do
          expect(subject.must_notify?(user, time: current_time)).to be(true)
        end
      end
    end
  end
end
