# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::TimeWithZone do
    describe "coerce" do
      subject { described_class.build(Attributes::TimeWithZone, {}).coerce(value) }

      context "when given a Time" do
        let(:value) { Time.current }

        it "returns the time" do
          expect(subject).to eq(value)
        end
      end

      context "when given a String" do
        let(:value) { "01/02/2017 15:00" }

        context "and in a different timezone" do
          it "parses the String in the correct timezone" do
            Time.use_zone("CET") do
              expect(subject.utc.to_s).to eq("2017-02-01 14:00:00 UTC")
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

        context "and an incorrect format" do
          let(:value) { "foo" }

          it "returns nil" do
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end
end
