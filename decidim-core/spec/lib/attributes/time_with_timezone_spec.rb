# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::TimeWithZone do
    describe "#type" do
      it "returns :\"decidim/attributes/time_with_zone\"" do
        expect(subject.type).to be(:"decidim/attributes/time_with_zone")
      end
    end

    describe "#cast" do
      subject { described_class.new.cast(value) }

      context "when given a Time" do
        let(:value) { Time.current }

        it "returns the time" do
          expect(subject).to be(value)
        end
      end

      shared_context "with date and time parsing" do
        context "and timezone offset" do
          it "parses the String in the correct timezone" do
            Time.use_zone("CET") do
              expect(subject.utc.to_s).to eq(expected_time_with_offset)
            end
          end
        end

        context "and no timezone offset" do
          it "parses the String in the correct timezone" do
            expect(subject.utc.to_s).to eq(expected_time_without_offset)
          end
        end
      end

      context "when given a String" do
        context "with formatted DateTime" do
          let(:expected_time_without_offset) { "2017-02-01 15:00:00 UTC" }

          context "without specifying the timezone" do
            let(:expected_time_with_offset) { "2017-02-01 14:00:00 UTC" }

            context "when d/m/Y HH:mm" do
              let(:value) { "01/02/2017 15:00" }

              include_context "with date and time parsing"
            end

            context "when Y-m-d HH:MM" do
              let(:value) { "2017-02-01 15:00" }

              include_context "with date and time parsing"
            end

            context "when Y-m-d HH:MM:SS" do
              let(:value) { "2017-02-01 15:00:00" }

              include_context "with date and time parsing"
            end

            context "when Y-m-d HH:MM:SS.N" do
              let(:value) { "2017-02-01 15:00:00.000000" }

              include_context "with date and time parsing"
            end

            context "when Y-m-dTHH:MM" do
              let(:value) { "2017-02-01T15:00" }

              include_context "with date and time parsing"
            end

            context "when Y-m-dTHH:MM:SS" do
              let(:value) { "2017-02-01T15:00:00" }

              include_context "with date and time parsing"
            end

            context "when Y-m-dTHH:MM:SS.N" do
              let(:value) { "2017-02-01T15:00:00.000000" }

              include_context "with date and time parsing"
            end
          end

          context "with specifying the timezone" do
            let(:expected_time_with_offset) { "2017-02-01 15:00:00 UTC" }

            context "when Y-m-d HH:MM:SS TZ" do
              let(:value) { "2017-02-01 16:00:00 +01:00" }

              include_context "with date and time parsing"
            end

            context "when %Y-%m-%d %H:%M:%S.%N %z" do
              let(:value) { "2017-02-01 16:00:00.000000000 +0100" }

              include_context "with date and time parsing"
            end
          end
        end

        context "with the correct format" do
          let(:value) { "01 :> 02 () 2017 !! 15:00" }

          around do |example|
            I18n.available_locales += ["fake_locale"]

            I18n.backend.store_translations(:fake_locale, time: { formats: { decidim_short: "%d :> %m () %Y !! %H:%M" } })

            I18n.with_locale(:fake_locale) do
              example.run
            end

            I18n.available_locales -= ["fake_locale"]
          end

          it "parses the String in the correct format" do
            expect(subject.utc.to_s).to eq("2017-02-01 15:00:00 UTC")
          end
        end

        context "with incorrect format" do
          let(:value) { "foo" }

          it "returns nil" do
            expect(subject).to be_nil
          end
        end

        context "with serialized ISO 8601 datetime format" do
          let(:value) { "2017-02-01T15:00:00.000Z" }

          it "parses the String in the correct format" do
            expect(subject.utc.to_s).to eq("2017-02-01 15:00:00 UTC")
          end
        end
      end
    end
  end
end
