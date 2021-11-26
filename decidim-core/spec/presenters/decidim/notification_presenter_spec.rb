# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationPresenter, type: :presenter do
    include ActiveSupport::Testing::TimeHelpers
    let(:creating_date) { Time.parse("Wed, 1 Sep 2021 21:00:00 UTC +00:00").in_time_zone }
    let(:notification) { instance_double("Decidim::Notification", created_at: creating_date) }
    let(:subject) { described_class.new(notification) }

    context "with a valid notification" do
      describe "#created_at_in_words" do
        context "when created_at is between zero and 59 seconds" do
          it "returns the date formated" do
            travel_to(creating_date) { expect(subject.created_at_in_words).to eq("right now") }
            travel_to(creating_date + 1.second) { expect(subject.created_at_in_words).to eq("1 sec. ago") }
            travel_to(creating_date + 10.seconds) { expect(subject.created_at_in_words).to eq("10 sec. ago") }
            travel_to(creating_date + 59.seconds) { expect(subject.created_at_in_words).to eq("59 sec. ago") }
          end
        end

        context "when created_at is between 1 minute and 59 minutes" do
          it "returns the date formated" do
            travel_to(creating_date + 1.minute) { expect(subject.created_at_in_words).to eq("60 sec. ago") }
            travel_to(creating_date + 59.minutes) { expect(subject.created_at_in_words).to eq("59 min. ago") }
          end
        end

        context "when created_at is between 1 hour and 24 hours" do
          it "returns the date formated" do
            travel_to(creating_date + 1.hour) { expect(subject.created_at_in_words).to eq("60 min. ago") }
            travel_to(creating_date + 12.hours) { expect(subject.created_at_in_words).to eq("12 hours ago") }
            travel_to(creating_date + 23.hours) { expect(subject.created_at_in_words).to eq("23 hours ago") }
          end
        end

        context "when created_at is between 1 day and 1 month" do
          it "returns the date formated" do
            travel_to(creating_date + 1.day) { expect(subject.created_at_in_words).to eq("24 hours ago") }
            travel_to(creating_date + 30.days) { expect(subject.created_at_in_words).to eq("30 days ago") }
          end
        end

        context "when created_at is longer than a month but in the current year" do
          it "returns the date formated" do
            travel_to(creating_date + 31.days) { expect(subject.created_at_in_words).to eq("01.09") }
            travel_to(creating_date + 2.months) { expect(subject.created_at_in_words).to eq("01.09") }
          end
        end

        context "when created_at is longer than a month and in the current year" do
          it "returns the date formated" do
            travel_to(creating_date + 6.months) { expect(subject.created_at_in_words).to eq("01.09.2021") }
            travel_to(creating_date + 23.months) { expect(subject.created_at_in_words).to eq("01.09.2021") }
            travel_to(creating_date + 50.years) { expect(subject.created_at_in_words).to eq("01.09.2021") }
          end
        end
      end
    end
  end
end
