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
        let(:value) { "2017-02-01T15:00:00" }

        context "and in a different timezone" do
          it "parses the String in the correct timezone" do
            Time.use_zone("CET") do
              expect(subject.utc.to_s).to eq("2017-02-01 14:00:00 UTC")
            end
          end
        end

        context "and it is not valid" do
          let(:value) { "foo" }

          it "returns nil" do
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end
end
