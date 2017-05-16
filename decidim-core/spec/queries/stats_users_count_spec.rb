# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe StatsUsersCount do
    let(:organization) { create(:organization) }
    let(:start_at) { nil }
    let(:end_at) { nil }
    subject { described_class.new(organization, start_at, end_at) }

    context "without start and end date" do
      it "returns the number of confirmed users" do
        create(:user, :confirmed)
        create(:user, :confirmed, organization: organization)
        create(:user, organization: organization)

        expect(subject.query).to eq(1)
      end
    end

    context "with start date" do
      let(:start_at) { 1.week.ago }

      it "returns the number of confirmed user created equal or after this date" do
        create(:user, :confirmed, organization: organization, created_at: 2.weeks.ago)
        create(:user, :confirmed, organization: organization)

        expect(subject.query).to eq(1)
      end
    end

    context "with end date" do
      let(:end_at) { 1.week.from_now }

      it "returns the number of confirmed user created equal or after this date" do
        create(:user, :confirmed, organization: organization, created_at: 2.weeks.from_now)
        create(:user, :confirmed, organization: organization)

        expect(subject.query).to eq(1)
      end
    end
  end
end
