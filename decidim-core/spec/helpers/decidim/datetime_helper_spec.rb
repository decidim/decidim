# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DatetimeHelper do
    include ActiveSupport::Testing::TimeHelpers

    describe "#simple_date" do
      around do |example|
        travel_to Time.zone.local(1945, 2, 6) do
          example.run
        end
      end

      describe "when in the same day" do
        let(:date) { Time.zone.now.beginning_of_day + 1.minute }

        it "returns hour only" do
          expect(helper.simple_date(date)).to eq("00:01")
        end
      end

      describe "when in the same week" do
        let(:date) { Time.zone.now.beginning_of_week + 1.minute }

        it "returns the day of the week" do
          expect(helper.simple_date(date)).to eq("Mon")
        end
      end

      describe "when in the same year" do
        let(:date) { Time.zone.now.beginning_of_year + 1.minute }

        it "returns the date in short format" do
          expect(helper.simple_date(date)).to eq("Jan 01")
        end
      end

      describe "when in previous years" do
        let(:date) { Time.zone.now - 1.year }

        it "returns the full date" do
          expect(helper.simple_date(date)).to eq("06.02.44")
        end
      end
    end
  end
end
