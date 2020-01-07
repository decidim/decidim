# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LocalDateTimeAttrReaders do
    SOME_DATE = Date.current
    UTC_TIME = SOME_DATE.in_time_zone("UTC").to_s
    LOCAL_TIME = SOME_DATE.in_time_zone("International Date Line West").to_s

    let(:time_zone) { "UTC" }
    let(:organization) { create(:organization, time_zone: time_zone) }

    let(:klass) do
      Class.new do
        include Decidim::LocalDateTimeAttrReaders

        local_datetime_attr_reader :one_hour_ago

        def one_hour_ago
          SOME_DATE
        end
      end
    end

    let(:subject) do
      klass.new
    end

    context "when no organization is available" do
      context "and Rails is configured in UTC" do
        it "local suffix returns utc date" do
          expect(subject.one_hour_ago.in_time_zone.to_s).to eq(UTC_TIME)
          expect(subject.one_hour_ago_local.to_s).to eq(UTC_TIME)
        end
      end

      context "and Rails is configured in non-UTC", tz: "International Date Line West" do
        it "local suffix returns utc date" do
          expect(subject.one_hour_ago.in_time_zone.to_s).to eq(LOCAL_TIME)
          expect(subject.one_hour_ago_local.to_s).to eq(LOCAL_TIME)
        end
      end
    end

    context "when organization is available" do
      before do
        allow(subject).to receive(:organization).and_return(organization)
      end

      context "when organization time zone is in UTC" do
        context "and Rails is configured in UTC" do
          it "local suffix returns utc date" do
            expect(subject.one_hour_ago.in_time_zone.to_s).to eq(UTC_TIME)
            expect(subject.one_hour_ago_local.to_s).to eq(UTC_TIME)
          end
        end

        context "and Rails is configured in non-UTC", tz: "International Date Line West" do
          it "local suffix returns utc date" do
            expect(subject.one_hour_ago.in_time_zone.to_s).to eq(LOCAL_TIME)
            expect(subject.one_hour_ago_local.to_s).to eq(UTC_TIME)
          end
        end
      end

      context "when organization time zone is personalized" do
        let(:time_zone) { "International Date Line West" }

        context "and Rails is configured in UTC" do
          it "local suffix returns utc date" do
            expect(subject.one_hour_ago.in_time_zone.to_s).to eq(UTC_TIME)
            expect(subject.one_hour_ago_local.to_s).to eq(LOCAL_TIME)
          end
        end

        context "and Rails is configured in non-UTC", tz: "International Date Line West" do
          it "local suffix returns utc date" do
            expect(subject.one_hour_ago.in_time_zone.to_s).to eq(LOCAL_TIME)
            expect(subject.one_hour_ago_local.to_s).to eq(LOCAL_TIME)
          end
        end
      end
    end
  end
end
