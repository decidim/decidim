# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsDigestPresenter, type: :presenter do
    subject { described_class.new(user) }

    context "with a user with daily sending frequency" do
      let(:user) { create(:user, notifications_sending_frequency: :daily) }

      describe "the methods needed in the mail" do
        it "returns the strings formated according to the daily frequency" do
          expect(subject.subject).to eq("This is your mail digest")
          expect(subject.header).to eq("Daily Notification Digest")
          expect(subject.formated_date(Time.parse("Wed, 1 Sep 2021 21:00:00 UTC +00:00").in_time_zone)).to eq("September 01, 2021 21:00")
          expect(subject.greeting).to eq("Hello #{user.name},")
          expect(subject.intro).to eq("These are the notifications from the last day based on the activity you are following:")
          expect(subject.outro).to eq("You have received these notifications because you are following this content or its authors. You can unfollow them from their respective pages.")
          expect(subject.see_more).to eq("See more notifications")
        end
      end
    end

    context "with a user with weekly sending frequency" do
      let(:user) { create(:user, notifications_sending_frequency: :weekly) }

      describe "#date_time" do
        it "returns the strings formated according to the daily frequency" do
          expect(subject.subject).to eq("This is your mail digest")
          expect(subject.header).to eq("Weekly Notification Digest")
          expect(subject.formated_date(Time.parse("Wed, 1 Sep 2021 21:00:00 UTC +00:00").in_time_zone)).to eq("September 01, 2021 21:00")
          expect(subject.greeting).to eq("Hello #{user.name},")
          expect(subject.intro).to eq("These are the notifications from the last week based on the activity you are following:")
          expect(subject.outro).to eq("You have received these notifications because you are following this content or its authors. You can unfollow them from their respective pages.")
          expect(subject.see_more).to eq("See more notifications")
        end
      end
    end
  end
end
