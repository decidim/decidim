# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Notification do
    subject { notification }

    let(:notification) { build(:notification) }

    it { is_expected.to be_valid }

    describe "validations" do
      context "without user" do
        let(:notification) { build(:notification, user: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without resource" do
        let(:notification) { build(:notification, resource: nil) }

        it { is_expected.not_to be_valid }
      end
    end

    describe ".daily" do
      subject { described_class.daily(time:).order(:id) }

      let(:time) { Time.now.utc }
      let(:resource) { create(:dummy_resource) }
      let!(:correct_notifications) do
        Array.new(5) do
          create(:notification, resource:, created_at: (time - 1.day).beginning_of_day + rand(1..23).hours)
        end + [
          create(:notification, resource:, created_at: (time - 1.day).beginning_of_day),
          create(:notification, resource:, created_at: (time - 1.day).end_of_day)
        ]
      end
      let!(:incorrect_notifications) do
        Array.new(20) do
          modifier = rand(2..365).days
          create(:notification, resource:, created_at: (time - modifier).beginning_of_day + rand(1..23).hours)
        end + [
          create(:notification, resource:, created_at: (time - 2.days).end_of_day),
          create(:notification, resource:, created_at: time.beginning_of_day)
        ]
      end

      it "returns only the notifications within the whole previous day" do
        expect(subject).to eq(correct_notifications)
      end
    end

    describe ".weekly" do
      subject { described_class.weekly(time:).order(:id) }

      let(:time) { Time.now.utc }
      let(:resource) { create(:dummy_resource) }
      let!(:correct_notifications) do
        Array.new(5) do
          create(:notification, resource:, created_at: (time - 1.day - 1.week).beginning_of_day + rand(1..7).days)
        end + [
          create(:notification, resource:, created_at: (time - 1.day - 1.week).beginning_of_day),
          create(:notification, resource:, created_at: (time - 1.day).end_of_day)
        ]
      end
      let!(:incorrect_notifications) do
        Array.new(20) do
          modifier = rand(8..365).days
          create(:notification, resource:, created_at: (time - modifier).beginning_of_day + rand(1..23).hours)
        end + [
          create(:notification, resource:, created_at: (time - 1.week - 2.days).end_of_day),
          create(:notification, resource:, created_at: time.beginning_of_day)
        ]
      end

      it "returns only the notifications within the whole previous week" do
        expect(subject).to eq(correct_notifications)
      end
    end
  end
end
