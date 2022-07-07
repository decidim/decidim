# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FriendlyDates do
    include ActiveSupport::Testing::TimeHelpers

    let(:enhanced_class) do
      Class.new do
        include FriendlyDates

        def initialize(date)
          @created_at = date
        end

        attr_accessor :created_at
      end
    end

    let(:enhanced_instance) { enhanced_class.new(date) }

    describe "#friendly_created_at" do
      around do |example|
        travel_to Time.zone.local(1945, 2, 6) do
          example.run
        end
      end

      describe "when in the same day" do
        let(:date) { Time.current.beginning_of_day + 1.minute }

        it "returns hour only" do
          expect(enhanced_instance.friendly_created_at).to eq("00:01")
        end
      end

      describe "when in the same week" do
        let(:date) { Time.current.beginning_of_week + 1.minute }

        it "returns the day of the week" do
          expect(enhanced_instance.friendly_created_at).to eq("Mon")
        end
      end

      describe "when in the same year" do
        let(:date) { Time.current.beginning_of_year + 1.minute }

        it "returns the date in short format" do
          expect(enhanced_instance.friendly_created_at).to eq("Jan 01")
        end
      end

      describe "when in previous years" do
        let(:date) { 1.year.ago }

        it "returns the full date" do
          expect(enhanced_instance.friendly_created_at).to eq("06.02.44")
        end
      end
    end
  end
end
